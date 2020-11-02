#include "DLL_C.h"
#include "framework.h"
#include "pch.h"
/*
* Akcent Kolorystyczny
* Algorytm pozostawiaj¹cy na przetworzonym obrazie wybran¹ przez u¿ytkownika barwê oraz odcienie mieszcz¹ce siê w podanym przez
* u¿ytkownika zakresie. To, czy dany kolor mieœci siê w zakresie liczone jest na bazie sumy wartoœci 
* bezwzglêdnych róznic miêdzy sk³adowymi r, g, b barwy podanej oraz aktualnie sprawdzanego piksela w obrazie. 
* Odcienie niemieszcz¹ce siê w zakresie zostaj¹ przekszta³cone w odcienie szaroœci. 
* Data wykonania: 31.10.2020
* Rok akademicki 2020/2021
* Autor: Pawe³ Ryka³a
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
