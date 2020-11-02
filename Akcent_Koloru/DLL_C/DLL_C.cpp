#include "DLL_C.h"
#include "framework.h"
#include "pch.h"
/*
* Akcent Kolorystyczny
* Algorytm pozostawiaj�cy na przetworzonym obrazie wybran� przez u�ytkownika barw� oraz odcienie mieszcz�ce si� w podanym przez
* u�ytkownika zakresie. To, czy dany kolor mie�ci si� w zakresie liczone jest na bazie sumy warto�ci 
* bezwzgl�dnych r�znic mi�dzy sk�adowymi r, g, b barwy podanej oraz aktualnie sprawdzanego piksela w obrazie. 
* Odcienie niemieszcz�ce si� w zakresie zostaj� przekszta�cone w odcienie szaro�ci. 
* Data wykonania: 31.10.2020
* Rok akademicki 2020/2021
* Autor: Pawe� Ryka�a
* AEiI Informatyka semestr 5, grupa 6
*/
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
