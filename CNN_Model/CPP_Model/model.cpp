// main.cpp
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <cmath>
#include <algorithm>
#include <nlohmann/json.hpp>
using json = nlohmann::json;

// Helpers
template<typename T>
std::vector<T> load_array(const json& node, const std::string& field) {
    return node.at(field).get<std::vector<T>>();
}

void load_qparam(const json& m, const std::string& key, float &scale, int &zp) {
    auto& node = m.at(key);
    scale = node["scale"].get<float>();
    zp    = node["zero_point"].get<int>();
}

inline float dequant(int q, float scale, int zp) {
    return (q - zp) * scale;
}
inline int requant(float r, float out_scale, int out_zp) {
    int32_t q = std::lround(r / out_scale) + out_zp;
    return std::clamp(q, -128, 127);
}

int main(){
    const std::string JSON_PATH = "data/model_dump.json";
    std::ifstream fin(JSON_PATH);
    if(!fin){ std::cerr<<"Failed to open "<<JSON_PATH<<"\n"; return 1; }
    json m; fin>>m; fin.close();

    // Tensor keys
    const std::string in_key      = "tfl.quantize";
    const std::string w_key       = "tfl.pseudo_qconst35";
    const std::string b_key       = "tfl.pseudo_qconst34";
    const std::string conv_out_key =
      "sequential_1_1/sequential_1/conv2d_1/Relu;"
      "sequential_1_1/sequential_1/conv2d_1/BiasAdd;"
      "sequential_1_1/sequential_1/conv2d_1/convolution;1";
    const std::string mul_key     = "tfl.pseudo_qconst33";
    const std::string mul_out_key =
      "sequential_1_1/sequential_1/batch_normalization_1/"
      "batchnorm/mul_1";
    const std::string add_key     = "tfl.pseudo_qconst32";
    const std::string add_out_key =
      "sequential_1_1/sequential_1/batch_normalization_1/"
      "batchnorm/add_1";

    // Load Step 1 inputs
    auto in_data  = load_array<int8_t>(m[in_key],  "data");
    float in_s; int in_z; load_qparam(m, in_key, in_s, in_z);

    auto w_data   = load_array<int8_t>(m[w_key],   "data");
    auto w_scales = load_array<float>(m[w_key],    "scales");
    auto w_zps    = load_array<int>(m[w_key],      "zero_points");

    auto b_data   = load_array<int32_t>(m[b_key],  "data");

    float out1_s; int out1_z; load_qparam(m, conv_out_key, out1_s, out1_z);

    // Precompute bias scales
    int M = w_scales.size();
    std::vector<float> bias_scales(M);
    for(int c=0;c<M;++c) bias_scales[c] = in_s * w_scales[c];

    // Convolution
    const int N=1, H=200, W=200, C=3, KH=3, KW=3, PAD=1;
    std::vector<int8_t> conv_out(N*H*W*M);
    for(int n=0;n<N;++n) for(int y=0;y<H;++y) for(int x=0;x<W;++x)
    for(int m_i=0;m_i<M;++m_i){
      float acc=0;
      for(int ky=0;ky<KH;++ky) for(int kx=0;kx<KW;++kx) for(int c=0;c<C;++c){
        int in_y=y+ky-PAD, in_x=x+kx-PAD;
        int8_t q_in=0;
        if(in_y>=0&&in_y<H&&in_x>=0&&in_x<W)
          q_in = in_data[((n*H+in_y)*W+in_x)*C + c];
        int8_t q_w = w_data[((m_i*KH+ky)*KW+kx)*C + c];
        float r_in = dequant(q_in,in_s,in_z);
        float r_w  = dequant(q_w, w_scales[m_i], w_zps[m_i]);
        acc += r_in * r_w;
      }
      acc += float(b_data[m_i]) * bias_scales[m_i];
      conv_out[((n*H+y)*W+x)*M + m_i] =
        static_cast<int8_t>(requant(acc, out1_s, out1_z));
    }

    // MUL
    auto mul_vec = load_array<int8_t>(m[mul_key], "data");
    float mul_s; int mul_z, out2_z; float out2_s;
    load_qparam(m,mul_key,mul_s,mul_z);
    load_qparam(m,mul_out_key,out2_s,out2_z);
    std::vector<int8_t> mul_out(N*H*W*M);
    for(int i=0;i<N*H*W*M;++i){
      int c = i % M;
      float r=dequant(conv_out[i],out1_s,out1_z)
             *dequant(mul_vec[c],mul_s,mul_z);
      mul_out[i] = static_cast<int8_t>(requant(r,out2_s,out2_z));
    }

    // ADD
    auto add_vec = load_array<int8_t>(m[add_key],"data");
    float add_s; int add_z, out3_z; float out3_s;
    load_qparam(m,add_key,add_s,add_z);
    load_qparam(m,add_out_key,out3_s,out3_z);
    std::vector<int8_t> add_out(N*H*W*M);
    for(int i=0;i<N*H*W*M;++i){
      int c=i%M;
      float r=dequant(mul_out[i],out2_s,out2_z)
             +dequant(add_vec[c],add_s,add_z);
      add_out[i] = static_cast<int8_t>(requant(r,out3_s,out3_z));
    }

    // Dump
    std::ofstream fout("step3_add_output.bin", std::ios::binary);
    fout.write((char*)add_out.data(), add_out.size());
    std::cout<<"Wrote step3_add_output.bin ("<<add_out.size()<<" bytes)\n";
    return 0;
}