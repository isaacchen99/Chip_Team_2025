import socket
import numpy as np
from PIL import Image
from datetime import datetime

class udp_receiver:
    def __init__(self, num_rows: int = 96, num_pixels_per_row: int = 128):
        self.num_rows = num_rows
        self.num_pixels_per_row = num_pixels_per_row
        self.img_data = []

    def receive(self, host: str = "127.0.0.1", port: int = 1000, buffer: int = 4096):
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.bind((host, port))
        print(f"Listening on {host}:{port}...")

        count = 0
        while count < self.num_rows:
            data, addr = sock.recvfrom(buffer)
            print(f"Received row {count + 1} from {addr}")
            row = np.frombuffer(data, dtype=np.uint8).reshape(self.num_pixels_per_row, 3)
            self.img_data.append(row)
            count += 1

        sock.close()
        self.save_image()

    def save_image(self):
        img_array = np.array(self.img_data, dtype=np.uint8)
        image = Image.fromarray(img_array, 'RGB')
        file_name = datetime.now().strftime("%Y-%m-%d_%H_%M_%S.bmp")
        image.save(file_name)
        print(f"Image saved as {file_name}")

if __name__ == "__main__":
    rec = udp_receiver(num_rows=96, num_pixels_per_row=128)
    rec.receive(host="127.0.0.1", port=1000)
