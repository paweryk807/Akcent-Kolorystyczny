#include "JAProjekt.h"

typedef void (*akcentC) (unsigned char* bmp, int offset, int size, int r, int g, int b, int range, int stride, int lineWidth);
typedef DWORD(*akcentASM) (unsigned char* bmp, int offset, int size, int r, int g, int b, int range, int stride, int lineWidth);

char* readBMP(BITMAPFILEHEADER* &bfh, BITMAPINFOHEADER* &bih, std::string& filename, int& size) {
	char* tmp; 
	std::ifstream input(&filename[0], std::ios::binary);
	if (input.is_open()) {
		tmp = new char [sizeof(BITMAPFILEHEADER)];
		input.read(tmp, sizeof(BITMAPFILEHEADER));
		bfh = (BITMAPFILEHEADER*)tmp;
		tmp = new char[sizeof(BITMAPINFOHEADER)];
		input.read(tmp, sizeof(BITMAPINFOHEADER));
		bih = (BITMAPINFOHEADER*)tmp;
		input.seekg((bfh->bfOffBits), std::ios::beg); // Początek obrazu

		int width = ((int)bih->biWidth) * 3;
		if (width % 4)
			width += 4 - (width % 4);
		size = (width * bih->biHeight);
		// width = width * 3;
		tmp = new char[size];
		input.read(tmp, size);
		input.close();
		return tmp;
	}
	else {
		throw std::exception("Source file error exception");
	}
	return nullptr;
}

void writeBMP(unsigned char* bmp, BITMAPFILEHEADER* bfh, BITMAPINFOHEADER* bih, std::string& filename, int size) {
	std::ofstream output(&filename[0], std::ios::binary);
 	if (output.is_open()) {
		output.write((char*) bfh, sizeof(BITMAPFILEHEADER));
		output.write((char*) bih, sizeof(BITMAPINFOHEADER));
		char *tmp = (char*)bmp;
		output.write(tmp, size);
		output.close();
	}
	else {
		throw std::exception("Destination file error exception");
	}
}

bool validateThreadsCount(int threads) {
	if (threads > 0 && threads < 65)
		return true;
	return false;
}

bool validateRange(int range) {
	if (range > 0 && range < 256)
		return true;
	return false;
}

void start(bool ASM, int threads, int range, int r, int g, int b) {
	
}

int main()
{	HINSTANCE handlerLib;
	akcentC functionC;
	akcentASM functionASM;

	BITMAPFILEHEADER* bfh = nullptr;
	BITMAPINFOHEADER* bih = nullptr;

	unsigned char* bmp = nullptr;

	std::string sourcePath = R"(C:\Users\bambe\Desktop\testCarBIG.bmp)",
		destinationPath = R"(C:\Users\bambe\Desktop\test_tulipany_C.bmp)"; // ścieżki do pliku/miejsca zapisu

	int range = 150;
	int r = 224;// 79;// 218;//137;
	int g = 22;// 29;// 212;// 28;
	int b = 2;// 52;// 2;// 36;

	int offset = 0;

	const unsigned int processor_count = std::thread::hardware_concurrency();
	std::cout << "Na Twoim komputerze program powinno wykonywac sie na : " << processor_count << " watkach." << std::endl;
	

	int threads = 8; 
	std::vector<std::thread> threads_vector;
	bool ASM = 0;

	/*
	std::cout << "Z jakiej biblioteki chcesz skorzystac?" << std::endl
		<< " 0 - C " << std::endl
		<< " 1 - ASM " << std::endl;
	std::cin >> ASM;
	while (std::cin.fail()) {
		std::cin.clear();
		std::cin.ignore();
		std::cout << "\x1B[2J\x1B[H";
		std::cout << "Niepoprawnie wybrano bibliotekę. Wybierz ponownie:"<<std::endl
				  << " 0 - C " << std::endl
				  << " 1 - ASM " << std::endl;
		std::cin >> ASM;
	}
	
	std::cout << "Ile watkow chcesz wyorzystac?  ( 0 - 64 )" << std::endl;
	std::cin >> threads;
	while (!validateThreadsCount(threads) || std::cin.fail()) {
		std::cin.clear();
		std::cin.ignore();
		std::cout << "\x1B[2J\x1B[H";
		std::cout << "Podano bledna liczbe watkow. ( 0 - 64 ) Wybierz ponownie:" << std::endl;
		std::cin >> threads;
	}	
	
	std::cout << "Podaj wartosci r g b wybranego przez Ciebie koloru oraz zakres akcentowania sumy wartosci " << std::endl
			  << "bezwzglednych roznic miedzy wybrana barwa a odcieniami obrazu." << std::endl
		      << "Zakres dla kazdej ze skladowych to 0 - 255"<<std::endl;
	std::cout << "Podaj wartosc skladowej czerwieni : "<<std::endl;
	std::cin >> r;
	while (!validateRange(r) || std::cin.fail()) {

	}

	*/
	try {
	int size = 0;
	int rows = 0;
	bmp = (unsigned char*)readBMP(bfh, bih, sourcePath, size); // Wczytanie obrazu 

	int lineWidth = (bih->biWidth) * 3;
	int stride = size / bih->biHeight;
	int leftover = (bih->biHeight % threads);
	int offset = bih->biHeight / threads;
	int linesToProcess =  offset;

	

	if (!ASM) {
		handlerLib = LoadLibrary(L"DLL_C.dll");
		if (handlerLib) {
			functionC = (akcentC)GetProcAddress(handlerLib, "colorAccent");
			if (functionC) {

				auto start = std::chrono::steady_clock::now();
				for (int i = 0; i < threads; i++) {
					if (i == threads - 1) {
						linesToProcess += leftover;
					}
					rows = offset*i + linesToProcess;
					threads_vector.push_back(std::thread(functionC, bmp, offset * i, rows, r, g, b, range, stride, lineWidth));
				}

				for (int i = 0; i < threads; i++)
					threads_vector[i].join();
			
				auto end = std::chrono::steady_clock::now();
				std::cout << "Wykonano w " << std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count() << "ms" << std::endl;
			}
			else std::cout << "Biblioteka C nie dziala poprawnie\n";
		}
	}
	else {
		handlerLib = LoadLibrary(L"DLL_ASM.dll");
		if (handlerLib) {
			functionASM = (akcentASM)GetProcAddress(handlerLib, "MyProc1");
			if (functionASM)
			{
				auto start = std::chrono::steady_clock::now();
				for (int i = 0; i < threads; i++) {
					if (i == threads - 1) {
						linesToProcess += leftover;
					}
					rows = offset * i + linesToProcess;
					threads_vector.push_back(std::thread(functionASM, bmp, offset * i, rows, r, g, b, range, stride, lineWidth));
				}

				for (int i = 0; i < threads; i++)
					threads_vector[i].join();

				auto end = std::chrono::steady_clock::now();

				std::cout << "Wykonano w " << std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count() << "ms" << std::endl;
			}
			else std::cout << "Biblioteka ASM nie dziala poprawnie\n";
		}
	}	
	writeBMP(bmp, bfh, bih, destinationPath, size);
	FreeLibrary(handlerLib);
	delete[] bmp;
	delete bfh;
	delete bih;
	}
	catch (std::exception e) {
		std::cout << e.what() << std::endl;
	}


}