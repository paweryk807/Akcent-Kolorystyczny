#include "DLL_C.h"
#include "framework.h"
#include "pch.h"

void colorAccent(unsigned char* bmp, int offset, int rows, int r, int g, int b, int range, int stride, int lineWidth){
    for (int currentByte = offset; currentByte < rows + offset; currentByte++) {
        for (int i = 0; i < lineWidth - 2; i += 3)
        {
             int distance = abs(bmp[currentByte * stride + i] - b);
             distance += abs(bmp[currentByte * stride + i + 1] - g);
             distance += abs(bmp[currentByte * stride + i + 2] - r);
            if (distance >= range) {
                int avg = (bmp[currentByte * stride + i] + bmp[currentByte * stride + i + 1] + bmp[currentByte * stride + i + 2])/3;
                bmp[currentByte * stride + i] = avg;
                bmp[currentByte * stride + i + 1] = avg;
                bmp[currentByte * stride + i + 2] = avg;
            }
        }
    }
} 
