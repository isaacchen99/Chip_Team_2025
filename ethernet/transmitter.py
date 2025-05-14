import socket
from PIL import Image
import numpy as np

class udp_transmitter:
    def __init__(self, img_path: str):
        self.img_path = img_path

    def transmit(self, host: str = "127.0.0.1", port: int = 1000):
        # Load image and convert to RGB
        img = Image.open(self.img_path).convert("RGB")
        img_array = np.array(img)
        height, width, _ = img_array.shape

        # Create UDP socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

        for row in img_array:
            # Flatten row into bytes
            row_bytes = row.tobytes()
            sock.sendto(row_bytes, (host, port))
            print(f"Sent {len(row_bytes)} bytes")

        sock.close()

if __name__ == "__main__":
    tx = udp_transmitter("input_image.bmp")  # your BMP file
    tx.transmit(host="127.0.0.1", port=1000)
