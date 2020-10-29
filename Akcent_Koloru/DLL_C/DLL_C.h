#pragma once
#include <iostream>
#ifdef DLL_C_EXPORTS
#define DLL_C_API __declspec(dllexport)
#else
#define DLL_C_API __declspec(dllimport)
#endif
/*
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
};*/

extern "C" DLL_C_API void colorAccent(
unsigned char* bmp,
int offset,
int rows,
int r,
int g,
int b,
int range,
int stride,
int lineWidth);