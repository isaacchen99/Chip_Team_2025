// main.cpp
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <cmath>
#include <algorithm>
#include <nlohmann/json.hpp>
using json = nlohmann::json;

// Helpers to load from JSON
template<typename T>
std::vector<T> load_tensor(const json& m, const std::string& name) {
    auto& node = m.at(name);
    auto& data = node["data"];
    std::vector<T> v; v.reserve(data.size());
    for (auto &x : data) v.push_back(static_cast<T>(x.get<int>()));
    return v;
}
void load_qparams(const json& m, const std::string& name, float &scale, int &zp) {
    auto& node = m.at(name);
    scale = node["scale"].get<float>();
    zp    = node["zero_point"].get<int>();
}
// Dequant / requant
inline float dequant(int q, float scale, int zp) {
    return (q - zp) * scale;
}
inline int requant(float r, float out_scale, int out_zp) {
    int32_t q = std::lround(r / out_scale) + out_zp;
    return std::clamp(q, -128, 127);
}

int main(){
    // 1) Parse the JSON dump
    std::ifstream fin("../Python_Model/data/model_dump.json");
    if (!fin) { std::cerr<<"Cannot open model_dump.json\n"; return 1; }
    json m; fin >> m; fin.close();

    // ----- STEP 1: CONV_2D -----
    auto in_data = load_tensor<int8_t>(m, "tfl.quantize");
    auto w_data  = load_tensor<int8_t>(m, "tfl.pseudo_qconst35");
    auto b_data  = load_tensor<int32_t>(m, "tfl.pseudo_qconst34");

    float in_s, out1_s;
    int   in_z, out1_z;
    load_qparams(m, "tfl.quantize", in_s, in_z);
    load_qparams(m,
      "sequential_1_1/sequential_1/conv2d_1/Relu;sequential_1_1/sequential_1/conv2d_1/BiasAdd;sequential_1_1/sequential_1/conv2d_1/convolution;1",
      out1_s, out1_z);

    const int N=1, H=200, W=200, C=3, M=64, KH=3, KW=3, PAD=1;
    std::vector<int8_t> conv_out(N*H*W*M);

    for(int n=0;n<N;++n) for(int y=0;y<H;++y) for(int x=0;x<W;++x) for(int m_i=0;m_i<M;++m_i){
        float acc = 0.0f;
        for(int ky=0; ky<KH; ++ky) for(int kx=0; kx<KW; ++kx) for(int c=0; c<C; ++c){
            int in_y = y+ky-PAD, in_x = x+kx-PAD;
            int q_in = (in_y>=0 && in_y<H && in_x>=0 && in_x<W)
                      ? in_data[((n*H+in_y)*W+in_x)*C + c] : 0;
            int q_w  = w_data[((m_i*KH+ky)*KW+kx)*C + c];
            acc += dequant(q_in, in_s, in_z) * dequant(q_w, 1.0f, 0);
        }
        acc += b_data[m_i] * in_s;
        conv_out[((n*H+y)*W+x)*M + m_i] =
          static_cast<int8_t>(requant(acc, out1_s, out1_z));
    }

    // ----- STEP 2: MUL -----
    auto mul_vec = load_tensor<int8_t>(m, "tfl.pseudo_qconst33");
    float mul_s, out2_s;
    int   mul_z, out2_z;
    load_qparams(m, "tfl.pseudo_qconst33", mul_s, mul_z);
    load_qparams(m,
      "sequential_1_1/sequential_1/batch_normalization_1/batchnorm/mul_1",
      out2_s, out2_z);

    std::vector<int8_t> mul_out(N*H*W*M);
    for(int i=0;i<N*H*W*M;++i){
        int c = i % M;
        float r = dequant(conv_out[i], out1_s, out1_z)
                * dequant(mul_vec[c], mul_s, mul_z);
        mul_out[i] = static_cast<int8_t>(requant(r, out2_s, out2_z));
    }

    // ----- STEP 3: ADD -----
    auto add_vec = load_tensor<int8_t>(m, "tfl.pseudo_qconst32");
    float add_s, out3_s;
    int   add_z, out3_z;
    load_qparams(m, "tfl.pseudo_qconst32", add_s, add_z);
    load_qparams(m,
      "sequential_1_1/sequential_1/batch_normalization_1/batchnorm/add_1",
      out3_s, out3_z);

    std::vector<int8_t> add_out(N*H*W*M);
    for(int i=0;i<N*H*W*M;++i){
        int c = i % M;
        float r = dequant(mul_out[i], out2_s, out2_z)
                + dequant(add_vec[c], add_s,   add_z);
        add_out[i] = static_cast<int8_t>(requant(r, out3_s, out3_z));
    }

    // Dump the final output
    std::ofstream fout("step3_add_output.bin", std::ios::binary);
    fout.write(reinterpret_cast<char*>(add_out.data()), add_out.size());
    fout.close();

    std::cout<<"Done Steps 1–3; wrote step3_add_output.bin ("<<add_out.size()<<" bytes)\n";
    return 0;
}
