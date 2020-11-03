#include "JAProjekt.h"
/*
* Akcent Kolorystyczny
* Algorytm pozostawiający na przetworzonym obrazie wybraną przez użytkownika barwę oraz odcienie mieszczące się w podanym przez
* użytkownika zakresie. To, czy dany kolor mieści się w zakresie liczone jest na bazie sumy wartości
* bezwzględnych róznic między składowymi r, g, b barwy podanej oraz aktualnie sprawdzanego piksela w obrazie.
* Odcienie niemieszczące się w zakresie zostają przekształcone w odcienie szarości.
* Data wykonania: 31.10.2020
* Rok akademicki 2020/2021
* Autor: Paweł Rykała
* AEiI Informatyka semestr 5, grupa 6
*/
typedef void (*akcentC) (unsigned char* bmp, int offset, int rows, int r, int g, int b, int range, int stride, int lineWidth);
typedef DWORD(*akcentASM) (unsigned char* bmp, int offset, int rows, int r, int g, int b, int range, int stride, int lineWidth);

char* readBMP(m_Bitmap& bitmap, std::string& filename) {
	char* tmp; 
	std::ifstream input(&filename[0], std::ios::binary);
	if (input.is_open()) {
		tmp = new char [sizeof(BITMAPFILEHEADER)];
		input.read(tmp, sizeof(BITMAPFILEHEADER));
		bitmap.bfh = (BITMAPFILEHEADER*)tmp;
		tmp = new char[sizeof(BITMAPINFOHEADER)];
		input.read(tmp, sizeof(BITMAPINFOHEADER));
		bitmap.bih = (BITMAPINFOHEADER*)tmp;
		input.seekg((bitmap.bfh->bfOffBits), std::ios::beg); // Początek obrazu

		int width = ((int)(bitmap.bih->biWidth)) * 3;
		if (width % 4)
			width += 4 - (width % 4);
		bitmap.size = (width * (bitmap.bih->biHeight));
		if (bitmap.size < (16 * 3 * 16)) {
			throw std::exception("File size exception");
			return nullptr;
		}
		tmp = new char[bitmap.size];
		input.read(tmp, bitmap.size);
		input.close();
		return tmp;
	}
	else {
		throw std::exception("Source file error exception");
	}
	return nullptr;
}

void writeBMP(m_Bitmap& bitmap, std::string& filename) {
	std::ofstream output(&filename[0], std::ios::binary);
 	if (output.is_open()) {
		output.write((char*) bitmap.bfh, sizeof(BITMAPFILEHEADER));
		output.write((char*) bitmap.bih, sizeof(BITMAPINFOHEADER));
		char *tmp = (char*)bitmap.bmp;
		output.write(tmp, bitmap.size);
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

int program(Program_params params) {
	int time = 0;	
	int rows = 0;

	HINSTANCE handlerLib;

	akcentC functionC;
	akcentASM functionASM;

	m_Bitmap bitmap;

	std::vector<std::thread> threads_vector;

	try {
		bitmap.bmp = (unsigned char*)readBMP(bitmap,params.sourcePath); // Wczytanie obrazu 

		int lineWidth = (bitmap.bih->biWidth) * 3;
		int stride = bitmap.size / bitmap.bih->biHeight;
		int leftover = (bitmap.bih->biHeight % params.threads);
		int offset = bitmap.bih->biHeight / params.threads;
		int linesToProcess = offset;

		if (!params.ASM) {
			handlerLib = LoadLibrary(L"DLL_C.dll");
			if (handlerLib) {
				functionC = (akcentC)GetProcAddress(handlerLib, "colorAccent");
				if (functionC) {

					auto start = std::chrono::steady_clock::now();
					for (int i = 0; i < params.threads; i++) {
						if (i == params.threads - 1) {
							linesToProcess += leftover;
						}
						rows = linesToProcess;
						threads_vector.push_back(std::thread(functionC, bitmap.bmp, offset * i, rows, params.r, params.g, params.b, params.range, stride, lineWidth));
					}

					for (int i = 0; i < params.threads; i++)
						threads_vector[i].join();

					auto end = std::chrono::steady_clock::now();
					time = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
				}
				else throw std::exception("Biblioteka C nie dziala poprawnie");
			}
		}
		else {
			handlerLib = LoadLibrary(L"DLL_ASM.dll");
			if (handlerLib) {
				functionASM = (akcentASM)GetProcAddress(handlerLib, "MyProc1");
				if (functionASM)
				{
					auto start = std::chrono::steady_clock::now();
					for (int i = 0; i < params.threads; i++) {
						if (i == params.threads - 1) {
							linesToProcess += leftover;
						}
						rows = linesToProcess;
						threads_vector.push_back(std::thread(functionASM, bitmap.bmp, offset * i, rows, params.r, params.g, params.b, params.range, stride, lineWidth));
					}

					for (int i = 0; i < params.threads; i++)
						threads_vector[i].join();

					auto end = std::chrono::steady_clock::now();
					time = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
				}
				else throw std::exception("Biblioteka ASM nie dziala poprawnie");
			}
		}
		writeBMP(bitmap, params.destinationPath);
		FreeLibrary(handlerLib);
	}
	catch (std::exception e) {
		std::cout << e.what() << std::endl;
	}
	
	delete[] bitmap.bmp;
	delete bitmap.bfh;
	delete bitmap.bih;
	return time;
}

int main()
{
	std::regex bmp_reg("[[:print:]]*.bmp");
	std::string sourcePath = "",
		destinationPath = "";

	int range = 0;
	int r = 0;
	int g = 0;
	int b = 0;

	const unsigned int processor_count = std::thread::hardware_concurrency();
	
	int threads = 1; 

	bool ASM = 1;
	bool exit = false; 
	int menuKey;

	Program_params params(ASM, threads, range, r, g, b, sourcePath, destinationPath);
	while (!exit)
	{
		std::cout << "\t\tAkcent Kolorystyczny\t\t" << std::endl << std::endl;
		std::cout << " 0 - wybierz biblioteke " << std::endl
			<< " 1 - podaj liczbe watkow na ilu ma sie wykonac procedura " << std::endl
			<< " 2 - podaj sciezke do pliku " << std::endl
			<< " 3 - podaj sciezke do pliku wynikowego " << std::endl
			<< " 4 - podaj kolor ktory chcesz akcentowac " << std::endl
			<< " 5 - podaj zakres tolerancji " << std::endl
			<< " 6 - wykonaj procedure " << std::endl
			<< " 9 - wyjscie " << std::endl;
		std::cout << std::endl <<"Aktualne parametry : " << std::endl
			<< "Sciezka do pliku : " << sourcePath << std::endl
			<< "Sciezka do pliku wynikowego : " << destinationPath << std::endl
			<< "Ilosc watkow do wykonania procedury : " << threads << std::endl
			<< "Akcentowany kolor : (" << r << ", " << g << ", " << b << "), zakres : " << range << std::endl;
		std::cin >> menuKey;
		if (std::cin.fail()) {
			std::cin.clear();
			std::cin.ignore();
		}
		else {
			switch (menuKey) {
			case 0: {
				std::cout << "Z jakiej biblioteki chcesz skorzystac?" << std::endl
					<< " 0 - C " << std::endl
					<< " 1 - ASM " << std::endl;
				std::cin >> ASM;
				while (std::cin.fail()) {
					std::cin.clear();
					std::cin.ignore();
					std::cin >> ASM;
				}
			}
				  break;
			case 1: {
				std::cout << "Na Twoim komputerze program powinno wykonywac sie na : " << processor_count << " watkach." << std::endl;
				std::cout << "Ile watkow chcesz wyorzystac?  ( 1 - 64 )" << std::endl;
				std::cin >> threads;
				while (!validateThreadsCount(threads) || std::cin.fail()) {
					std::cin.clear();
					std::cin.ignore();
					std::cin >> threads;
				}
			}
				  break;
			case 2: {
				std::cout << "Wprowadz sciezke do pliku, ktory ma byc przetworzony. " << std::endl;
				std::cin >> sourcePath;
				while (std::cin.fail() || !std::regex_match(sourcePath, bmp_reg)) {
					std::cin.clear();
					std::cin.ignore();
					sourcePath = "";
					std::cout << "Podano bledna sciezke do pliku, sprobuj jeszcze raz." << std::endl;
					std::cin >> sourcePath;
				}
			}
				  break;
			case 3: {
				std::cout << "Wprowadz sciezke dla pliku wynikowego. " << std::endl;
				std::cin >> destinationPath;
				while (std::cin.fail() || !std::regex_match(destinationPath, bmp_reg)) {
					std::cin.clear();
					std::cin.ignore();
					destinationPath = "";
					std::cout << "Podano bledna sciezke do pliku wynikowego, sprobuj jeszcze raz." << std::endl;
					std::cin >> destinationPath;
				}}
				  break;
			case 4: {
				std::cout << "Podaj wartosci r g b wybranego przez Ciebie koloru oraz zakres akcentowania sumy wartosci. " << std::endl
					<< "Zakres dla kazdej ze skladowych to 0 - 255" << std::endl;
				std::cout << "Podaj wartosc skladowej czerwieni : " << std::endl;
				std::cin >> r;
				while (!validateRange(r) || std::cin.fail()) {
					std::cin.clear();
					std::cin.ignore();
					std::cin >> r;
				}
				std::cout << "Podaj wartosc skladowej zieleni : " << std::endl;
				std::cin >> g;
				while (!validateRange(g) || std::cin.fail()) {
					std::cin.clear();
					std::cin.ignore();
					std::cin >> g;
				}
				std::cout << "Podaj wartosc skladowej niebieskiego : " << std::endl;
				std::cin >> b;
				while (!validateRange(b) || std::cin.fail()) {
					std::cin.clear();
					std::cin.ignore();
					std::cin >> b;
				}
			}
				  break;
			case 5: {
				std::cout << "Podaj zakres bezwzglednych roznic miedzy wybrana barwa a odcieniami obrazu." << std::endl
					<< "Akceptowane wartości z przedziału: 0 - 255" << std::endl;
				std::cin >> range;
				while (!validateRange(range) || std::cin.fail()) {
					std::cin.clear();
					std::cin.ignore();
					std::cin >> range;
				}	
			}
				  break;
			case 6: {
				params.ASM = ASM;
				params.threads = threads;
				params.range = range;
				params.r = r;
				params.g = g;
				params.b = b;
				params.sourcePath = sourcePath;
				params.destinationPath = destinationPath;
				std::cout << "Wykonano w " << program(params) << " ms." << std::endl;
				if (ASM) std::cout << " Korzystano z biblioteki ASM, plik zapisany w : " << destinationPath << std::endl;
				else std::cout << " Korzystano z biblioteki C, plik zapisany w : " << destinationPath << std::endl;
				std::cout << "Korzystano z nastepujacej liczby watkow : " << threads << ". Akcentowany kolor : ("<<r<<", "<<g<<", "<<b<<"), zakres : "<<range;
				Sleep(1000);
			}
				  break;
			case 9: {
				exit = true;
				std::cout << "\x1B[2J\x1B[H" << "\t\tDo widzenia!\t\t" << std::endl;
				Sleep(1000);
			}
				  break;
			}
		}
		std::cout << "\x1B[2J\x1B[H";
	}
}