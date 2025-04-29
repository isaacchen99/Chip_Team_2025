import cv2
import numpy as np
import matplotlib.pyplot as plt
from c_filter import convolve

### OUTPUT CONTROL ###
output_image = True
output_hex = True
### ############## ###

def write_hex_file(filename, data):
    with open(filename, "w") as f:
        for row in data:
            # Write each pixel as a 2-digit hex value.
            for pixel in row:
                hex_value = f"{int(np.clip(pixel, 0, 255)) & 0xFF:02X}"
                f.write(hex_value + "\n")


if __name__ == '__main__':
    image_path = 'peace_sign.jpg'
    #image_path = 'me-at-lake-tahoe.jpg'
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

    if img is None:
        print("Error, no image")
        exit()

    # Laplacian kernel (edge-detect)
    laplacian_kernel = np.array([
        [-1, -1, -1],
        [-1, 8, -1],
        [-1, -1, -1]
    ], dtype = np.float32)

    # Sharpen kernel
    sharpen_kernel = np.array([
        [0, -1, 0],
        [-1, 5, -1],
        [0, -1, 0]
    ], dtype = np.float32)

    sharpened_img = convolve(img, sharpen_kernel)
    convolved_img = convolve(img, laplacian_kernel)
    edge_detect_img = convolve(sharpened_img, laplacian_kernel)

    print(f"Height: {img.shape[0]} Width: {img.shape[1]}")

    if (output_image):
        plt.figure(figsize=(10, 5))

        plt.subplot(1, 3, 1)
        plt.imshow(img, cmap='gray')
        plt.title("Original Image")
        plt.axis("off")

        plt.subplot(1, 3 ,2)
        plt.imshow(sharpened_img, cmap='gray')
        plt.title("Sharpened Image")
        plt.axis("off")

        plt.subplot(1, 3 ,3)
        plt.imshow(edge_detect_img, cmap='gray')
        plt.title("Edge-Detect Image")
        plt.axis("off")

        plt.show()

# output hex files
if (output_hex):
    write_hex_file("image_data.hex", img)
    write_hex_file("sharpened_gold.hex", sharpened_img)
    write_hex_file("edge_gold.hex", edge_detect_img)
    write_hex_file("convolution_py.hex", convolved_img)

# then can use $readmemh in verilog tesbench to load the hex arrays 
