#pragma once
#pragma warning(disable : 4996)
#include <iostream>
#include <fstream>
#include <windows.h>
#include <regex>
#include <chrono>
#include <thread>
#include <string>
#include <vector>
#include "framework.h"
#include "resource.h"

extern "C" void MyProc1(DWORD x, DWORD y);

struct Program_params {
	bool ASM;
	int threads;
	int range;
	int r;
	int g;
	int b;
	std::string sourcePath;
	std::string destinationPath;
	Program_params(bool _ASM, int _threads, int _range, int _r, int _g, int _b, std::string _sourcePath, std::string _destinationPath)
		: ASM(_ASM), threads(_threads), range(_range), r(_r), g(_g), b(_b), sourcePath(_sourcePath), destinationPath(_destinationPath) {};
};

struct m_Bitmap {
	unsigned char* bmp;
	int size;
	BITMAPFILEHEADER* bfh;
	BITMAPINFOHEADER* bih;
};