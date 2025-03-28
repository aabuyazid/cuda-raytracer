#include "camera.h"
__host__ camera::camera() : img_width(512), img_height(512), 
viewport_height(2.0), vfov(90) {
    int num_pixels = img_width * img_height;
    fb_size = 3*num_pixels*sizeof(float);
    
    // allocate FB
    checkCudaErrors(cudaMallocManaged((void **)&ft_buf, fb_size));


}

__host__ camera::camera(int img_width, int img_height, 
double viewport_height, double vfov) : 
img_width(img_width), img_height(img_width), 
viewport_height(viewport_height), vfov(vfov) {
    int num_pixels = img_width * img_height;
    fb_size = 3*num_pixels*sizeof(float);
    
    // allocate FB
    checkCudaErrors(cudaMallocManaged((void **)&ft_buf, fb_size));
}

__host__ void camera::test_render() {
    dim3 blocks(img_width / tx + 1, img_height / ty + 1);
    dim3 threads(tx, ty);
    test_render_kernel<<<blocks, threads>>>(fb, img_width, img_height);
    checkCudaErrors(cudaGetLastError());
    checkCudaErrors(cudaDeviceSynchronize());


}

__global__ void camera::test_render_kernel(float* fb, int max_x, int max_y) {
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    int j = threadIdx.y + blockIdx.y * blockDim.y;
    if((i >= max_x) || (j >= max_y)) return;
    int pixel_index = j*max_x*3 + i*3;
    fb[pixel_index + 0] = float(i) / max_x;
    fb[pixel_index + 1] = float(j) / max_y;
    fb[pixel_index + 2] = 0.2;
}
