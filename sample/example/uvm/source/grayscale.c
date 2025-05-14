#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>


struct pixel {
   unsigned char b;
   unsigned char g;
   unsigned char r;
};

// Read BMP file and extract the pixel values (store in data) and header (store in header)
// data is data[0] = BLUE, data[1] = GREEN, data[2] = RED, etc...
int read_bmp(FILE *f, unsigned char* header, int *height, int *width, struct pixel* data) 
{
    printf("reading file...\n");
    // read the first 54 bytes into the header
   if (fread(header, sizeof(unsigned char), 54, f) != 54)
   {
        printf("Error reading BMP header\n");
        return -1;
   }   

   // get height and width of image
   int w = (int)(header[19] << 8) | header[18];
   int h = (int)(header[23] << 8) | header[22];

   // Read in the image
   int size = w * h;
   if (fread(data, sizeof(struct pixel), size, f) != size){
        printf("Error reading BMP image\n");
        return -1;
   }   

   *width = w;
   *height = h;
   return 0;
}

// Write the grayscale image to disk.
void write_grayscale_bmp(const char *filename, unsigned char* header, unsigned char* data) 
{
   FILE* file = fopen(filename, "wb");

   // get height and width of image
   int width = (int)(header[19] << 8) | header[18];
   int height = (int)(header[23] << 8) | header[22];
   int size = width * height;
   struct pixel * data_temp = (struct pixel *)malloc(size*sizeof(struct pixel)); 
   
   // write the 54-byte header
   fwrite(header, sizeof(unsigned char), 54, file); 
   int y, x;
   
   // the r field of the pixel has the grayscale value. copy to g and b.
   for (y = 0; y < height; y++) {
      for (x = 0; x < width; x++) {
         (*(data_temp + y*width + x)).b = (*(data + y*width + x));
         (*(data_temp + y*width + x)).g = (*(data + y*width + x));
         (*(data_temp + y*width + x)).r = (*(data + y*width + x));
      }
   }
   
   size = width * height;
   fwrite(data_temp, sizeof(struct pixel), size, file); 
   
   free(data_temp);
   fclose(file);
}

// Determine the grayscale 8 bit value by averaging the r, g, and b channel values.
void convert_to_grayscale(struct pixel * data, int height, int width, unsigned char *grayscale_data) 
{
   for (int i = 0; i < width*height; i++) 
   {
       grayscale_data[i] = (data[i].r + data[i].g + data[i].b) / 3;
      printf("%02x = (%02x + %02x + %02x) / 3\n", grayscale_data[i], data[i].r, data[i].g, data[i].b);
   }
}


int main(int argc, char *argv[]) 
{
    struct pixel *rgb_data = (struct pixel *)malloc(720*540*sizeof(struct pixel));
    unsigned char *gs_data = (unsigned char *)malloc(720*540*sizeof(unsigned char));
    unsigned char header[64];
    int height, width;

    // Check inputs
    if (argc < 2) 
    {
        printf("Usage: grayscale <BMP filename>\n");
        return 0;
    }

    FILE * f = fopen(argv[1],"rb");
    if ( f == NULL ) return 0;

   /// Read bitmap
   read_bmp(f, header, &height, &width, rgb_data);

    /// Grayscale conversion
    convert_to_grayscale(rgb_data, height, width, gs_data);
    write_grayscale_bmp("grayscale.bmp", header, gs_data);

    return 0;
}


