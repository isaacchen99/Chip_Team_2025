import numpy as np

# apply convolution on image w/ specified kernel:
#   inputs: image: 2d array of image
#           kernel: 2d array representing kernel
#
#   output: 2d array of filtered image
#

def convolve(image, kernel):
    #initialize 
    img_height, img_width = image.shape
    kernel_height, kernel_width = kernel.shape

    # floor division for ints
    padding_height = kernel_height // 2
    padding_width = kernel_width // 2


    # Padding w/ zeroes
    padded_img = np.pad(image, ((padding_height, padding_width), (padding_width, padding_height)), mode = 'constant', constant_values= 0)

    # Convolution 
    filtered_img = np.zeros_like(image)
    
    # iterate through the image w/ kernel 
    for i in range(img_height):
        for j in range(img_width):
            
            # split image into kernel-sized regions
            region = padded_img[i:i+kernel_height, j:j+kernel_width]
            
            # apply kernel
            filtered_img[i,j] = np.sum(region * kernel)

    return filtered_img




