#include <opencv2/opencv.hpp>
#include <vector>
#include <cstdint>
#include <cmath>
#include <iostream>
#include <fstream>


// Quantization params from your model’s Step 0:
//   input_scale  = 1/255  (0.0039215689)
//   input_zp     =   0
//   output_scale = 1/255  (0.0039215689)
//   output_zp    = -128
static constexpr float  IN_SCALE  = 1.0f/255.0f;
static constexpr int32_t IN_ZP     = 0;
static constexpr float  OUT_SCALE = 1.0f/255.0f;
static constexpr int32_t OUT_ZP    = -128;

// Clamp to int8 range
inline int8_t clamp_int8(int32_t v){
    v = std::max<int32_t>(-128, std::min<int32_t>(127, v));
    return static_cast<int8_t>(v);
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " input.jpg\n";
    return 1;
    }

    // 1) Load & resize
    cv::Mat img = cv::imread(argv[1], cv::IMREAD_COLOR);
    if (img.empty()) {
        std::cerr << "Failed to load image.\n";
        return 1;
    }
    cv::resize(img, img, cv::Size(200, 200), 0, 0, cv::INTER_LINEAR);

    // 2) BGR → RGB
    cv::cvtColor(img, img, cv::COLOR_BGR2RGB);

    // 3) Quantize
    // Output buffer: 1×200×200×3 int8
    std::vector<int8_t> quantized;
    quantized.reserve(200 * 200 * 3);

    for (int y = 0; y < img.rows; ++y) {
        const cv::Vec3b* row = img.ptr<cv::Vec3b>(y);
        for (int x = 0; x < img.cols; ++x) {
            // read the uint8 pixel channels
            uint8_t r = row[x][0];
            uint8_t g = row[x][1];
            uint8_t b = row[x][2];

            // for each channel: float_real = pixel * IN_SCALE
            // then quant = round(float_real/OUT_SCALE) + OUT_ZP
            // since IN_SCALE==OUT_SCALE, this reduces to (pixel) + OUT_ZP
            int32_t qr = std::lround((r * IN_SCALE) / OUT_SCALE) + OUT_ZP;
            int32_t qg = std::lround((g * IN_SCALE) / OUT_SCALE) + OUT_ZP;
            int32_t qb = std::lround((b * IN_SCALE) / OUT_SCALE) + OUT_ZP;

            quantized.push_back(clamp_int8(qr));
            quantized.push_back(clamp_int8(qg));
            quantized.push_back(clamp_int8(qb));
        }
    }

    // 4) Done: quantized now holds 200*200*3 int8 values in RGB order
    std::cout << "Quantized " << quantized.size()
              << " values: [" << int(quantized[0]) << ", "
              << int(quantized[1]) << ", " << int(quantized[2])
              << ", …]\n";

    // (Optionally) write out as binary:
    std::ofstream out("input_q.bin", std::ios::binary);
    out.write(reinterpret_cast<char*>(quantized.data()),
              quantized.size() * sizeof(int8_t));

    return 0;
}