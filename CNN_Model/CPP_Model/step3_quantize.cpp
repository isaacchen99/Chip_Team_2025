#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <algorithm>
#include <cmath>
#include <nlohmann/json.hpp>
using json = nlohmann::json;

// Load a typed vector from JSON "data" field
template<typename T>
std::vector<T> load_data(const json &node) {
  const auto &arr = node["data"];
  std::vector<T> v; v.reserve(arr.size());
  for (const auto &x : arr) v.push_back(x.get<T>());
  return v;
}

// Load scalar quant params
void load_qparam(const json &node, float &scale, int &zero_point) {
  scale      = node.at("scale").get<float>();
  zero_point = node.at("zero_point").get<int>();
}

// Compute fixed-point multiplier and shift, per TFLite reference
void QuantizeMultiplier(double real_multiplier,
                        int32_t *quantized_multiplier,
                        int *shift) {
  if (real_multiplier == 0.0) {
    *quantized_multiplier = 0;
    *shift = 0;
    return;
  }
  int exp;
  double mantissa = std::frexp(real_multiplier, &exp);
  int64_t q = static_cast<int64_t>(std::round(mantissa * (1ll << 31)));
  if (q == (1ll << 31)) { q /= 2; exp++; }
  *quantized_multiplier = static_cast<int32_t>(q);
  *shift = exp;
}

inline int32_t MultiplyByQuantizedMultiplier(int32_t x,
                                              int32_t quantized_multiplier,
                                              int shift) {
  int64_t prod = static_cast<int64_t>(x) * quantized_multiplier;
  if (shift > 0) {
    int64_t rounding = static_cast<int64_t>(1) << (shift - 1);
    prod = (prod + rounding) >> shift;
  } else {
    prod <<= -shift;
  }
  return static_cast<int32_t>(prod);
}

int main() {
  // 1) Read JSON dump
  std::ifstream fin("../Python_Model/data/model_dump.json");
  if (!fin) { std::cerr << "Cannot open model_dump.json\n"; return 1; }
  json m; fin >> m; fin.close();

  // --- Step 0: QUANTIZE ---
  auto in_node    = m.at("serving_default_keras_tensor_30:0");
  auto q0_node    = m.at("tfl.quantize");
  auto in_u8      = load_data<int>(in_node);
  float  in_scale, q0_out_scale;
  int    in_zp,   q0_out_zp;
  load_qparam(q0_node,    q0_out_scale, q0_out_zp);
  // in_zp=0; in_scale == q0_out_scale
  size_t N0 = in_u8.size();
  std::vector<int8_t> q0_out(N0);
  for (size_t i = 0; i < N0; ++i) {
    int32_t q = in_u8[i] + q0_out_zp;  // q_in + out_zp
    q0_out[i] = static_cast<int8_t>(std::clamp(q, -128, 127));
  }
  std::ofstream f0("step0_quant.bin", std::ios::binary);
  f0.write(reinterpret_cast<const char*>(q0_out.data()), N0);
  f0.close();

  // --- Step 1: CONV_2D ---
  auto w_node = m.at("tfl.pseudo_qconst35");
  auto b_node = m.at("tfl.pseudo_qconst34");
  auto conv_node = m.at(
    "sequential_1_1/sequential_1/conv2d_1/Relu;"
    "sequential_1_1/sequential_1/conv2d_1/BiasAdd;"
    "sequential_1_1/sequential_1/conv2d_1/convolution;1");
  auto w_data = load_data<int8_t>(w_node);
  auto b_data = load_data<int>(b_node);
  float w_scale; int w_zp;
  load_qparam(w_node,    w_scale, w_zp);
  float conv_out_scale; int conv_out_zp;
  load_qparam(conv_node, conv_out_scale, conv_out_zp);

  // dims: N=1,H=200,W=200,C=3,M=64,KH=3,KW=3,pad=1
  const int N=1, H=200, W=200, C=3, M=64, KH=3, KW=3, PAD=1;
  std::vector<int8_t> conv0_out(N*H*W*M);

  // precompute multipliers+shifts per channel
  std::vector<int32_t> conv_mult(M);
  std::vector<int>     conv_shift(M);
  for (int m_i = 0; m_i < M; ++m_i) {
    double real_m = (q0_out_scale * w_scale) / conv_out_scale;
    QuantizeMultiplier(real_m, &conv_mult[m_i], &conv_shift[m_i]);
  }

  for (int y = 0; y < H; ++y) for (int x = 0; x < W; ++x)
  for (int m_i = 0; m_i < M; ++m_i) {
    int32_t acc = 0;
    for (int ky = 0; ky < KH; ++ky) for (int kx = 0; kx < KW; ++kx)
    for (int c = 0; c < C; ++c) {
      int in_y = y + ky - PAD;
      int in_x = x + kx - PAD;
      int8_t q_in = (in_y >= 0 && in_y < H && in_x >= 0 && in_x < W)
        ? q0_out[(in_y*W + in_x)*C + c]
        : 0;
      int8_t q_w = w_data[((m_i*KH + ky)*KW + kx)*C + c];
      acc += (static_cast<int32_t>(q_in) - q0_out_zp)
           * (static_cast<int32_t>(q_w) - w_zp);
    }
    acc += b_data[m_i];
    int32_t q = MultiplyByQuantizedMultiplier(acc,
                    conv_mult[m_i], conv_shift[m_i])
                + conv_out_zp;
    conv0_out[(y*W + x)*M + m_i] =
      static_cast<int8_t>(std::clamp(q, -128, 127));
  }
  std::ofstream f1("step1_conv.bin", std::ios::binary);
  f1.write(reinterpret_cast<const char*>(conv0_out.data()), conv0_out.size());
  f1.close();

  // --- Step 2: MUL ---
  auto mul_node    = m.at("tfl.pseudo_qconst33");
  auto mul_out_node= m.at(
    "sequential_1_1/sequential_1/batch_normalization_1/batchnorm/mul_1");
  auto mul_vec     = load_data<int8_t>(mul_node);
  float mul_scale; int mul_zp;
  load_qparam(mul_node, mul_scale, mul_zp);
  float mul_out_s; int mul_out_z;
  load_qparam(mul_out_node, mul_out_s, mul_out_z);
  std::vector<int32_t> mul_mult(M);
  std::vector<int>     mul_shift(M);
  for (int i = 0; i < M; ++i) {
    double real_m = (conv_out_scale * mul_scale) / mul_out_s;
    QuantizeMultiplier(real_m, &mul_mult[i], &mul_shift[i]);
  }
  std::vector<int8_t> mul_out(N*H*W*M);
  for (int idx = 0; idx < N*H*W*M; ++idx) {
    int c = idx % M;
    int32_t acc = (static_cast<int32_t>(conv0_out[idx]) - conv_out_zp)
                * (static_cast<int32_t>(mul_vec[c]) - mul_zp);
    int32_t q = MultiplyByQuantizedMultiplier(acc,
                   mul_mult[c], mul_shift[c])
                + mul_out_z;
    mul_out[idx] = static_cast<int8_t>(std::clamp(q, -128, 127));
  }
  std::ofstream f2("step2_mul.bin", std::ios::binary);
  f2.write(reinterpret_cast<const char*>(mul_out.data()), mul_out.size());
  f2.close();

  // --- Step 3: ADD ---
  auto add_node    = m.at("tfl.pseudo_qconst32");
  auto add_out_node= m.at(
    "sequential_1_1/sequential_1/batch_normalization_1/batchnorm/add_1");
  auto add_vec     = load_data<int8_t>(add_node);
  float add_scale; int add_zp;
  load_qparam(add_node, add_scale, add_zp);
  float add_out_s; int add_out_z;
  load_qparam(add_out_node, add_out_s, add_out_z);

  // compute add multipliers
  std::vector<int32_t> add_mult0(M), add_mult1(M);
  std::vector<int>     add_shift0(M), add_shift1(M);
  for (int i = 0; i < M; ++i) {
    double r0 = mul_out_s / add_out_s;
    double r1 = add_scale / add_out_s;
    QuantizeMultiplier(r0, &add_mult0[i], &add_shift0[i]);
    QuantizeMultiplier(r1, &add_mult1[i], &add_shift1[i]);
  }
  std::vector<int8_t> add_out(N*H*W*M);
  for (int idx = 0; idx < N*H*W*M; ++idx) {
    int c = idx % M;
    int32_t v0 = (static_cast<int32_t>(mul_out[idx]) - mul_out_z);
    int32_t v1 = (static_cast<int32_t>(add_vec[c])   - add_zp);
    int32_t s0 = MultiplyByQuantizedMultiplier(v0,
                     add_mult0[c], add_shift0[c]);
    int32_t s1 = MultiplyByQuantizedMultiplier(v1,
                     add_mult1[c], add_shift1[c]);
    int32_t res = s0 + s1 + add_out_z;
    add_out[idx] = static_cast<int8_t>(std::clamp(res, -128, 127));
  }
  std::ofstream f3("step3_add.bin", std::ios::binary);
  f3.write(reinterpret_cast<const char*>(add_out.data()), add_out.size());
  f3.close();

  std::cout<<"Finished steps 0–3, dumps: step0_quant.bin, step1_conv.bin, step2_mul.bin, step3_add.bin\n";
  return 0;
}
