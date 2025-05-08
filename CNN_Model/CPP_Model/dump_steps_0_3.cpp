#include <fstream>
#include <iostream>
#include <vector>
#include <tensorflow/lite/interpreter.h>
#include <tensorflow/lite/kernels/register.h>
#include <tensorflow/lite/model.h>
#include <tensorflow/lite/c/common.h>
#include <tensorflow/lite/interpreter_builder.h>
#include <tensorflow/lite/string_util.h>
#include <tensorflow/lite/tools/public/ingestion_input_buffer.h>
#include <tensorflow/lite/tools/command_line_flags.h>
#include <tensorflow/lite/tools/logging.h>
#include <tensorflow/lite/error_reporter.h>
#include <tensorflow/lite/tools/mutable_op_resolver.h>
#include <tensorflow/lite/delegates/utils/simple_delegate.h>
#include <tensorflow/lite/kernels/register_ref.h>
#include <tensorflow/lite/kernels/op_macros.h>
#include <tensorflow/lite/kernels/kernel_util.h>
#include <tensorflow/lite/kernels/internal/tensor_ctypes.h>
#include <tensorflow/lite/kernels/internal/quantization_util.h>
#include <tensorflow/lite/kernels/internal/prepare.h>
#include <tensorflow/lite/kernels/internal/types.h>
#include <tensorflow/lite/kernels/internal/round.h>
#include <tensorflow/lite/interpreter_builder.h>

int main(int argc, char* argv[]) {
  const char* model_path = "asl_model_quantized_int8.tflite";
  const char* input_image = "asl_alphabet_test/C_test.jpg";
  
  // 1) Load the model
  auto model = tflite::FlatBufferModel::BuildFromFile(model_path);
  if (!model) { std::cerr<<"Failed to mmap model\n"; return 1; }
  
  // 2) Build the interpreter without delegates
  tflite::ops::builtin::BuiltinOpResolver resolver;
  std::unique_ptr<tflite::Interpreter> interp;
  tflite::InterpreterBuilder(*model, resolver)(&interp);
  interp->SetPreserveAllTensors(true);  // keep all intermediates
  interp->AllocateTensors();
  
  // 3) Prepare the input (load your 200×200 JPEG into uint8 buffer)
  //    Here I assume you have a raw RGB uint8 file of size 200×200×3 named "input.raw".
  //    You can easily dump one from Python: img.tobytes()
  {
    std::ifstream fin("input.raw", std::ios::binary);
    if (!fin) { std::cerr<<"Cannot open input.raw\n"; return 1; }
    uint8_t* in_ptr = interp->typed_input_tensor<uint8_t>(0);
    fin.read(reinterpret_cast<char*>(in_ptr), 200*200*3);
  }
  
  // 4) Run
  interp->Invoke();
  
  // 5) Dump tensors 38–41
  auto dump = [&](int idx, const char* fn) {
    TfLiteTensor* t = interp->tensor(idx);
    std::ofstream fo(fn, std::ios::binary);
    size_t bytes = t->bytes;
    fo.write(reinterpret_cast<char*>(t->data.uint8), bytes);
    fo.close();
    std::cout<<"Dumped tensor#"<<idx<<" to "<<fn<<" ("<<bytes<<" bytes)\n";
  };
  
  dump(38, "step0_quant.bin");
  dump(39, "step1_conv.bin");
  dump(40, "step2_mul.bin");
  dump(41, "step3_add.bin");
  
  return 0;
}
