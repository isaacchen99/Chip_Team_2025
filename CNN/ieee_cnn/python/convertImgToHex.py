import numpy as np
import cv2

def image_to_hex(image_path, hex_file):
    """
    Converts an image to a hex file.

    Args:
        image_path (str): Path to the input image.
        hex_file (str): Path to save the output hex file.
    """
    # Read the image in grayscale
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

    if img is None:
        print("Error: Unable to read the image.")
        return

    # Flatten the image into a 1D array
    pixel_values = img.flatten()

    # Write pixel values as hex to the file
    with open(hex_file, 'w') as f:
        for pixel in pixel_values:
            hex_value = f"{pixel:02X}"  # Convert to 2-digit hex
            f.write(hex_value + "\n")

    print(f"Hex file saved to {hex_file}")

if __name__ == "__main__":
    # Example usage
    image_path = "input_image.png"  # Input image file
    hex_file = "converted_output_image.hex"  # Output hex file

    image_to_hex(image_path, hex_file)