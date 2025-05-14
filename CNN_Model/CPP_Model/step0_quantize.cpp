// step0_fixed.cpp
#include <iostream>
#include <fstream>
#include <vector>
#include <nlohmann/json.hpp>
using json = nlohmann::json;

int main(){
  // 1) Load JSON
  std::ifstream fin("../Python_Model/data/model_dump.json");
  json j; fin >> j; fin.close();

  // 2) Read the input‐tensor (uint8) and the quantize zero_point
  auto& in_node = j.at("serving_default_keras_tensor_30:0");
  int out_zp     = j.at("tfl.quantize")["zero_point"].get<int>();  // -128

  size_t N       = in_node["data"].size();
  std::vector<uint8_t> in_data(N);
  for(size_t i=0;i<N;++i)
    in_data[i] = static_cast<uint8_t>(in_node["data"][i].get<int>());

  // 3) Apply the Quantize math: q_out = q_in + out_zp
  std::vector<int8_t> out_data(N);
  for(size_t i=0;i<N;++i)
    out_data[i] = static_cast<int8_t>(int(in_data[i]) + out_zp);

  // 4) Write the .bin
  std::ofstream fout("cpp_out/tfl_quantize_output.bin", std::ios::binary);
  fout.write(reinterpret_cast<const char*>(out_data.data()), N);
  fout.close();

  std::cout<<"First three: "
            <<int(out_data[0])<<" "
            <<int(out_data[1])<<" "
            <<int(out_data[2])<<"\n"
           <<"Last three:  "
            <<int(out_data[N-3])<<" "
            <<int(out_data[N-2])<<" "
            <<int(out_data[N-1])<<"\n";
  return 0;
}
