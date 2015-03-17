#include <stdio.h>
#include <math.h>

#define CUDA_CALL(c) \
    do {                                            \
        cudaError_t res = c;                        \
        if (res != cudaSuccess) {                   \
            fprintf(stderr, "error at line %d: %s \n", __LINE__, cudaGetErrorString(res));    \
            exit(EXIT_FAILURE);                     \
        }                                           \
    } while (0)

// Problem dimension
#define STENCIL_SIZE (16 * 1024 * 1024)
#define RADIUS (3)
#define NUM_CHANNELS (4)

#define BLOCK_SIZE (32)

// Given the pixel index and channel, return the position of the
// element in the 1D array.
static __device__ __host__ int getIndex(int index, int channel)
{
    return index * NUM_CHANNELS + channel;
}

static __constant__ int weight[RADIUS * 2 + 1] = {
    1, 2, 3, 4, 3, 2, 1
};
static __constant__ int denominator = 16;

__global__ void stencilKernel(unsigned char *in,
                              int numPixels,
                              unsigned char *out)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int radius, channel;
    int outLocal[NUM_CHANNELS] = { 0 };

    if (i < RADIUS) {
        return;
    }

    if (i >= numPixels - RADIUS) {
        return;
    }

    for (radius = -RADIUS; radius <= RADIUS; ++radius) {
        for (channel = 0; channel < NUM_CHANNELS; ++channel) {
            outLocal[channel] += (int)in[getIndex(i + radius, channel)] * weight[RADIUS + radius];
        }
    }

    for (channel = 0; channel < NUM_CHANNELS; ++channel) {
        out[getIndex(i, channel)] = (unsigned char)(outLocal[channel] / denominator);
    }
}

static void stencilGpu(unsigned char *in,
                       int numPixels,
                       unsigned char *out)
{
    unsigned char *inGPU;
    unsigned char *outGPU;
    size_t arraySize;

    arraySize = numPixels * NUM_CHANNELS * sizeof(unsigned char);

    CUDA_CALL(cudaMalloc(&inGPU, arraySize));
    CUDA_CALL(cudaMalloc(&outGPU, arraySize));

    CUDA_CALL(cudaMemcpy(inGPU, in, arraySize, cudaMemcpyHostToDevice));

    stencilKernel<<<ceil((float)numPixels / BLOCK_SIZE), BLOCK_SIZE>>>(inGPU, numPixels, outGPU);
    CUDA_CALL(cudaGetLastError());
    CUDA_CALL(cudaDeviceSynchronize());

    CUDA_CALL(cudaMemcpy(out, outGPU, arraySize, cudaMemcpyDeviceToHost));

    CUDA_CALL(cudaFree(inGPU));
    CUDA_CALL(cudaFree(outGPU));
}

int main()
{
    unsigned char *in;
    unsigned char *outGPU;
    size_t arraySize = STENCIL_SIZE * NUM_CHANNELS * sizeof(unsigned char);

    in = (unsigned char *)malloc(arraySize);
    outGPU = (unsigned char *)malloc(arraySize);
    if (in == NULL || outGPU == NULL) {
        fprintf(stderr, "Allocation failed\n");
        exit(EXIT_FAILURE);
    }

    stencilGpu(in, STENCIL_SIZE, outGPU);

    free(in);
    free(outGPU);

    return 0;
}
