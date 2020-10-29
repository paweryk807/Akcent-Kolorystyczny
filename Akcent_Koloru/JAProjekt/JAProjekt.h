#pragma once
#pragma warning(disable : 4996)
#include <iostream>
#include <fstream>
#include <windows.h>
#include <chrono>
#include <thread>
#include <string>
#include <vector>
#include "framework.h"
#include "resource.h"

extern "C" void MyProc1(DWORD x, DWORD y);

struct Params {
	unsigned char* bmp;
	int offset;
	int rows; 
	int r;
	int g;
	int b; 
	int range;
	int stride;
	int lineWidth;
	Params(unsigned char* bitmap, int off, int row, int R, int G, int B, int Range, int Stride, int LineWidth) :
		bmp(bitmap), offset(off), rows(row), r(R), g(G), b(B), range(Range), stride(Stride), lineWidth(LineWidth) {};
};