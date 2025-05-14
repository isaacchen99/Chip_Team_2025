import numpy as np
import cv2

def hex_to_image(hex_file, output_image_path, width, height):
    """
    Converts a hex file to an image and saves it.

    Args:
        hex_file (str): Path to the input hex file.
        output_image_path (str): Path to save the output image.
        width (int): Width of the image.
        height (int): Height of the image.
    """
    # Read the hex file
    with open(hex_file, 'r') as f:
        hex_data = f.read().splitlines()

    # Convert hex values to integers
    pixel_values = [int(value, 16) for value in hex_data]

    # Reshape the flat list into a 2D array with the specified dimensions
    image_array = np.array(pixel_values, dtype=np.uint8).reshape((height, width))

    # Save the image
    cv2.imwrite(output_image_path, image_array)
    print(f"Image saved to {output_image_path}")

if __name__ == "__main__":
    # Example usage
    hex_file = "image_data_VL.hex"  # Input hex file
    output_image_path = "output_image_VL_bmp.bmp"  # Output image file
    width = 538  # Replace with the actual width of the image
    height = 358  # Replace with the actual height of the image

    hex_to_image(hex_file, output_image_path, width, height)
