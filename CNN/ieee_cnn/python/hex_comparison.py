import numpy as np
import cv2

def read_hex_file(filename, img_shape):
    """Reads a HEX file and reconstructs the image."""
    with open(filename, "r") as f:
        hex_data = [line.strip().split() for line in f]

    # Convert hex strings to integers
    img_data = np.array([[int(pixel, 16) for pixel in row] for row in hex_data], dtype=np.uint8)

    # Ensure the shape matches expected dimensions
    if img_data.shape != img_shape:
        print(f"Warning: Reconstructed image shape {img_data.shape} does not match expected {img_shape}")
    
    return img_data

# Load original grayscale image
image_path = 'peace_sign.jpg'
img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

# Load reconstructed image from hex
reconstructed_img = read_hex_file("image_data.hex", img.shape)

# Display side-by-side comparison
cv2.imshow("Original Image", img)
cv2.imshow("Reconstructed Image", reconstructed_img)
cv2.waitKey(0)
cv2.destroyAllWindows()
