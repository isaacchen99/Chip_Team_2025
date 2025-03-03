import cv2
import numpy as np
# import matplotlib.pyplot as plt
from c_filter import convolve

# Function to write data in HEX format for Verilog
def write_hex_file(filename, data):
    with open(filename, "w") as f:
        for row in data:
            hex_line = " ".join(f"{int(np.clip(pixel, 0, 255)) & 0xFF:02X}" for pixel in row)
            f.write(hex_line + "\n")

if __name__ == '__main__':
    image_path = 'peace_sign.jpg'
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

    if img is None:
        print("Error: Could not load image")
        exit()

    # Laplacian Kernel (Edge Detection)
    laplacian_kernel = np.array([
        [-1, -1, -1],
        [-1, 8, -1],
        [-1, -1, -1]
    ], dtype=np.float32)

    # Sharpening Kernel
    sharpen_kernel = np.array([
        [0, -1, 0],
        [-1, 5, -1],
        [0, -1, 0]
    ], dtype=np.float32)

    # Apply Convolution Filters
    sharpened_img = convolve(img, sharpen_kernel)
    edge_detect_img = convolve(sharpened_img, laplacian_kernel)

    # plt.figure(figsize=(10, 5))

    # plt.subplot(1, 3, 1)
    # plt.imshow(img, cmap='gray')
    # plt.title("Original Image")
    # plt.axis("off")

    # plt.subplot(1, 3 ,2)
    # plt.imshow(sharpened_img, cmap='gray')
    # plt.title("Sharpened Image")
    # plt.axis("off")

    # plt.subplot(1, 3 ,3)
    # plt.imshow(edge_detect_img, cmap='gray')
    # plt.title("Edge-Detect Image")
    # plt.axis("off")

    # plt.show()

    # Save Image Data to HEX Files
    write_hex_file("image_data.hex", img.astype(np.uint8))
    write_hex_file("sharpened_gold.hex", np.clip(sharpened_img, 0, 255).astype(np.uint8))
    write_hex_file("edge_gold.hex", np.clip(edge_detect_img, 0, 255).astype(np.uint8))
