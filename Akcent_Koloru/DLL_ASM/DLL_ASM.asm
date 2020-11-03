;* Akcent Kolorystyczny
;* Algorytm pozostawiaj¹cy na przetworzonym obrazie wybran¹ przez u¿ytkownika barwê oraz odcienie mieszcz¹ce siê w podanym przez
;* u¿ytkownika zakresie. To, czy dany kolor mieœci siê w zakresie liczone jest na bazie sumy wartoœci 
;* bezwzglêdnych róznic miêdzy sk³adowymi r, g, b barwy podanej oraz aktualnie sprawdzanego piksela w obrazie. 
;* Odcienie niemieszcz¹ce siê w zakresie zostaj¹ przekszta³cone w odcienie szaroœci. 
;* Data wykonania: 31.10.2020
;* Rok akademicki 2020/2021
;* Autor: Pawe³ Ryka³a
;* AEiI Informatyka semestr 5, grupa 6

.data
 amask BYTE 0,3,6,9,12,15,2,2,2,2,2,2,2,2,2,2
 bmask BYTE 2,5,8,11,14,0,0,0,0,0,0,0,0,0,0,0
 cmask BYTE 1,4,7,10,13,2,2,2,2,2,2,2,2,2,2,2 

 recoveryAmask BYTE 10,0,0,11,0,0,12,0,0,13,0,0,14,0,0,15
 recoveryBmask BYTE 0,11,0,0,12,0,0,13,0,0,14,0,0,15,0,0
 recoveryCmask BYTE 0,0,11,0,0,12,0,0,13,0,0,14,0,0,15,0

 multiplyMoveMask BYTE 0,15,0,15,0,15,0,15,0,15,0,15,0,15,0,15

 condMask1 BYTE 0,2,4,6,8,10,12,14,15,15,15,15,15,15,15,15 
 condMask2 BYTE 15,15,15,15,15,15,15,15,0,2,4,6,8,10,12,14

.code
MyProc1 proc 
        ;Odk³adanie rejstrów nieulotnych na stos 
        push RBX
        push RBP
        push RDI
        push RSI
        push RSP
        mov RSI, 0
        mov r13, r8          ; Tworzê licznik pêtli w r13d - zmienna Rows 
        mov r14, rdx         ; Wstawiam do r14 adres pierwszego elementu bitmapy
        mov r10d, [rsp + 104]; Wprowadzenie do r10d zmiennej stride
        mov RAX, r14         ; Przeniesienei do rejestru rax pierwszego elementu bitmapy
        mul r10              ; Wymna¿am adres pierwszego elementu bitmapy przez stride - adres pierwszego przetwarzanego elementu jest teraz w rax
        add rcx, RAX         ; Od teraz w rcx adres pierwszego przetwarzanego elementu 
        mov r12d, [rsp + 112]; Od teraz szerokoœæ linii w r12d 

Main:
        ;Wczytanie 16 pikseli
        movdqu xmm0, xmmword ptr[RCX + RSI]     ; Wczytanie 16 bajtów od pierwszego przetwarzanego elementu
        movdqu xmm1, xmmword ptr[RCX + RSI + 16]; Wczytanie kolejnych 16 bajtów do przetworzenia
        movdqu xmm2, xmmword ptr[RCX + RSI + 32]; Wczytanie kolejnych 16 bajtów do przetworzenia 

        movdqu xmm3, xmm0
        pshufb xmm3, xmmword ptr[amask]
        pslldq xmm3, 10
        psrldq xmm3, 10

        movdqu xmm4, xmm1
        pshufb xmm4, xmmword ptr[bmask]
        pslldq xmm4, 11
        psrldq xmm4, 5
        paddq xmm3, xmm4

        movdqu xmm4, xmm2
        pshufb xmm4, xmmword ptr[cmask]
        pslldq xmm4, 11
        paddq xmm3, xmm4; Tablica b w xmm3 

        movdqu xmm4, xmm0
        pshufb xmm4, xmmword ptr[cmask]
        pslldq xmm4, 11
        psrldq xmm4, 11

        movdqu xmm5, xmm1
        pshufb xmm5, xmmword ptr[amask]
        pslldq xmm5, 10
        psrldq xmm5, 5
        paddq xmm4, xmm5

        movdqu xmm5, xmm2
        pshufb xmm5, xmmword ptr[bmask]
        pslldq xmm5, 11
        paddq xmm4, xmm5; Tablica g w xmm4

        movdqu xmm5, xmm0
        pshufb xmm5, xmmword ptr[bmask]
        pslldq xmm5, 11
        psrldq xmm5, 11

        movdqu xmm6, xmm1
        pshufb xmm6, xmmword ptr[cmask]
        pslldq xmm6, 11
        psrldq xmm6, 6
        paddq xmm5, xmm6

        movdqu xmm6, xmm2
        pshufb xmm6, xmmword ptr[amask]
        pslldq xmm6, 10
        paddq xmm5, xmm6; Tablica r w xmm5 

        movdqu xmm0, xmm3; W xmm3 i xmm0 wartosci b
        movdqu xmm1, xmm4; W xmm4 i xmm1 wartosci g
        movdqu xmm2, xmm5; W xmm5 i xmm2 wartosci r

        ;Rozszerzenie b na 16 bitów        
        movdqu xmm4, xmm0 
        pmovzxbw xmm3, xmm4; b7 - b0 - XMM 3
        psrldq xmm4, 8
        pmovzxbw xmm4, xmm4; b15 - b8 - XMM 4

        ;Rozszerzenie g na 16 bitów
        movdqu xmm6, xmm1
        pmovzxbw xmm5, xmm6; g7 - g0 - XMM 5
        psrldq xmm6, 8
        pmovzxbw xmm6, xmm6; g15 - g8 - XMM 6

        ;Rozszerzenie r na 16 bitów
        movdqu xmm8, xmm2 
        pmovzxbw xmm7, xmm8; r7 - r0 - XMM 7
        psrldq xmm8, 8
        pmovzxbw xmm8, xmm8; r15 - r8 - XMM 8
        
        ;Wczytywanie barwy podanej przez u¿ytkownika 
        mov EAX,  r9d 
        movd xmm11, eax
        pshufb xmm11, xmmword ptr[multiplyMoveMask]; R - czerwony na 16 bitach - XMM 11
      
        mov EAX,  [rsp+80]
        movd xmm12, eax
        pshufb xmm12, xmmword ptr[multiplyMoveMask]; G - zielony na 16 bitach - XMM 12
       
        mov EAX,  [rsp+88]
        movd xmm14, eax
        pshufb xmm14, xmmword ptr[multiplyMoveMask]; B - niebieski na 16 bitach - XMM 14
        
        movdqu xmm10,xmm11 ; R 
        psubw xmm10, xmm7  ; R-r[7-0]
        pabsw xmm10, xmm10 ; ABS (R-r[7-0]) - XMM 10
        
        psubw xmm11, xmm8  ; R-r[15-8]
        pabsw xmm11, xmm11 ; ABS (R-r[15-8]) - XMM 11

        movdqu xmm13, xmm12; G
        psubw xmm13, xmm5  ; G-g[7-0]
        pabsw xmm13, xmm13 ; ABS (G-g[7-0]) - XMM 13
        
        psubw xmm12, xmm6
        pabsw xmm12, xmm12 ; ABS(G-g[15-8]) - XMM 12

        movdqu xmm15, xmm14; B
        psubw xmm14, xmm3  ; B-b[7-0]
        pabsw xmm14, xmm14 ; ABS (B-b[7-0]) - XMM 14
        
        psubw xmm15, xmm4
        pabsw xmm15, xmm15 ; ABS(B-b[15-8]) - XMM 15

        paddw xmm10, xmm13 
        paddw xmm10, xmm14 ; Suma wartoœci bezwzglêdnych [7-0] - XMM 10
       
        paddw xmm11, xmm12 
        paddw xmm11, xmm15 ; Suma wartoœci bezwzglêdnych [15-8] - XMM 11
        
        ;Wczytywanie zakresu
        mov EAX, [rsp+96] 
        movd xmm9, eax
        pshufb xmm9, xmmword ptr[multiplyMoveMask]; Zakres na 16 bitach
        
        movdqu xmm12, xmm9 
        pcmpgtw xmm12, xmm10; Zakres > Sumy wartoœci bezwzglêdnych [7-0] - XMM 12
        pcmpgtw xmm9, xmm11 ; Zakres > Sumy wartoœci bezwzglêdnych [15-8] - XMM 9 
        psllq xmm12,8
        psrlq xmm12,8
        pshufb xmm12, xmmword ptr[condMask1]
        psllq xmm9,8
        psrlq xmm9,8
        pshufb xmm9, xmmword ptr[condMask2]
        paddb xmm9, xmm12 ; Czy Zakres > Sumy wartoœci bezwzglêdnych - XMM 9 
     
        mov EAX, 86       ; 256/3 + 1 = 86 
        movd xmm10, EAX
        pshufb xmm10, xmmword ptr[multiplyMoveMask]; 86 - na 16 bitach

        pmullw xmm3, xmm10; b[7-0] * 86 - xmm3 
        psrlw xmm3, 8     ; 3/256 
        pshufb xmm3, xmmword ptr[condMask1]; xmm 3 = b[7-0] / 3 
     
        pmullw xmm4, xmm10; b[15-8] * 86 - xmm4
        psrlw xmm4, 8     ; 3/256 
        pshufb xmm4, xmmword ptr[condMask2]; xmm 4 = b[15-8] / 3 
        
        paddb xmm3, xmm4; xmm 3 = b[15-0] /3 
        
        pmullw xmm5, xmm10; g[7-0] * 86 - xmm5
        psrlw xmm5, 8     ; 3/256 
        pshufb xmm5, xmmword ptr[condMask1]; - xmm 5 = g[7-0] / 3 
     
        pmullw xmm6, xmm10; g[15-8] * 86 - xmm4
        psrlw xmm6, 8     ; 3/256 
        pshufb xmm6, xmmword ptr[condMask2]; xmm 6 = g[15-8] / 3 
        
        paddb xmm5,xmm6   ; xmm 5 = g[15 - 0] / 3 

        pmullw xmm7, xmm10; r[7-0] * 86 - xmm7 
        psrlw xmm7, 8     ; 3/256 
        pshufb xmm7, xmmword ptr[condMask1]; xmm 7 = r[7-0] / 3 
     
        pmullw xmm8, xmm10; b[15-8] * 86 <- xmm8
        psrlw xmm8, 8     ; 3/256 
        pshufb xmm8, xmmword ptr[condMask2]; xmm 8 = r[15-8] / 3 

        paddb xmm7,xmm8   ; xmm 7 = r[15 - 0] / 3 
       
        paddb xmm3, xmm5
        paddb xmm3, xmm7  ; rgb[15-0] / 3  - XMM 3 

        ;Warunkowe uk³adanie sk³adowych (pierwotna barwa lub œrednia) 
        movdqu xmm4, xmm9 ; Kopiujê warunek 
        pand xmm0, xmm9   ; Te z b które s¹ zgodne z Zakres > Sumy wartoœci bezwzglêdnych 
        pandn xmm4, xmm3  ; Œrednia dla niezgodnych 
        paddb xmm0, xmm4  ; Wynik w xmm 0 

        movdqu xmm4, xmm9 ; Kopiujê warunek
        pand xmm1, xmm9   ; Te z g które s¹ zgodne z Zakres > Sumy wartoœci bezwzglêdnych 
        pandn xmm4, xmm3  ; Œrednia dla niezgodnych
        paddb xmm1, xmm4  ; Wynik w xmm1  

        pand xmm2, xmm9   ; Te z r które s¹ zgodne z Zakres > Sumy wartoœci bezwzglêdnych 
        pandn xmm9, xmm3  ; Dla niezgodnych œrednia
        paddb xmm2, xmm9  ; Wynik w xmm2

        ;Przywracanie nale¿ytej kolejnoœci sk³adowych 
        ;Wartoœci B - sk³adowej niebieskiego
        movdqu xmm6, xmm0 ; Kopiuje sobie xmm3 do xmm6 w celu obróbki
        pslldq xmm6, 10   ; zostawiam tylko 6 bajtów tego rejestru - 6 najni¿szych indeksowo wartoœci
        psrldq xmm0, 6    ; Bo w³aœnie je zabra³em
        pshufb xmm6, xmmword ptr[recoveryAmask] ; wracam do pierwotnego u³o¿enia tych sk³adowych w rejestrze;

        movdqu xmm7, xmm1 ; Kopiuje sobie xmm4 do xmm7 w celu obróbki
        pslldq xmm7, 11   ; zostawiam tylko 5 bajtów tego rejestru - 5 najni¿szych indeksowo wartoœci
        psrldq xmm1, 5    ; Bo w³aœnie je zabra³em
        pshufb xmm7, xmmword ptr[recoveryBmask] ; wracam do pierwotnego u³o¿enia tych sk³adowych w rejestrze 
        paddq xmm6, xmm7  ; wracam powoli do pierwotnego u³o¿enia rejestru xmm6 (ma mieæ uk³ad jak na pocz¹tku xmm0) 

        movdqu xmm7, xmm2 ; Kopiuje sobie xmm5 do xmm7 w celu obróbki
        pslldq xmm7, 11   ; zostawiam tylko 5 bajtów tego rejestru - 5 najni¿szych indeksowo wartoœci
        psrldq xmm2, 5    ; Bo w³aœnie je zabra³em
        pshufb xmm7, xmmword ptr[recoveryCmask] 
        paddq xmm6, xmm7  ; W xmm6 pierwotne u³o¿enie wartoœci jak by³o w xmm0 tylko ju¿ s¹ po obróbce
        
        ;Wartoœci R - sk³adowej czerwieni
        movdqu xmm7, xmm0 ; Kopiuje sobie xmm3 do xmm6 w celu obróbki
        pslldq xmm7, 11   ; zostawiam tylko 5 bajtów tego rejestru - 5 najni¿szych indeksowo wartoœci
        psrldq xmm0, 5    ; Bo w³aœnie je zabra³em
        pshufb xmm7, xmmword ptr[recoveryCmask] ; wracam do pierwotnego u³o¿enia tych sk³adowych w rejestrze;

        movdqu xmm8, xmm1 ; Kopiuje sobie xmm4 do xmm7 w celu obróbki
        pslldq xmm8, 10   ; zostawiam tylko 6 bajtów tego rejestru - 6 najni¿szych indeksowo wartoœci
        psrldq xmm1, 6    ; Bo w³aœnie je zabra³em
        pshufb xmm8, xmmword ptr[recoveryAmask] ; wracam do pierwotnego u³o¿enia tych sk³adowych w rejestrze 
        paddq xmm7, xmm8  ; wracam powoli do pierwotnego u³o¿enia rejestru xmm6 (ma mieæ uk³ad jak na pocz¹tku xmm0) 

        movdqu xmm8, xmm2 ; Kopiuje sobie xmm5 do xmm7 w celu obróbki
        pslldq xmm8, 11   ; zostawiam tylko 5 bajtów tego rejestru - 5 najni¿szych indeksowo wartoœci
        psrldq xmm2, 5    ; w³aœnie zosta³y zabrane
        pshufb xmm8, xmmword ptr[recoveryBmask] 
        paddq xmm7, xmm8  ; W xmm7 pierwotne u³o¿enie wartoœci jak by³o w xmm1 tylko ju¿ s¹ po obróbce
        
        ;Wartoœci G - sk³adowej zieleni
        movdqu xmm8, xmm0 ; Kopiuje sobie xmm3 do xmm6 w celu obróbki
        pslldq xmm8, 11   ; zostawiam tylko 5 bajtów tego rejestru - 5 najni¿szych indeksowo wartoœci
        psrldq xmm0, 5    ; Bo w³aœnie je zabra³em
        pshufb xmm8, xmmword ptr[recoveryBmask] ; wracam do pierwotnego u³o¿enia tych sk³adowych w rejestrze;

        movdqu xmm9, xmm1 ; Kopiuje sobie xmm4 do xmm7 w celu obróbki
        pslldq xmm9, 11   ; zostawiam tylko 5 bajtów tego rejestru - 5 najni¿szych indeksowo wartoœci
        psrldq xmm1, 5    ; Bo w³aœnie je zabra³em
        pshufb xmm9, xmmword ptr[recoveryCmask] ; wracam do pierwotnego u³o¿enia tych sk³adowych w rejestrze 
        paddq xmm8, xmm9  ; wracam powoli do pierwotnego u³o¿enia rejestru xmm6 (ma mieæ uk³ad jak na pocz¹tku xmm0) 

        movdqu xmm9, xmm2 ; Kopiuje sobie xmm5 do xmm7 w celu obróbki
        pslldq xmm9, 10   ;zostawiam tylko 6 bajtów tego rejestru - 5 najni¿szych indeksowo wartoœci
        psrldq xmm2, 6    ;w³aœnie zosta³y zabrane
        pshufb xmm9, xmmword ptr[recoveryAmask] 
        paddq xmm8, xmm9  ;W xmm8 pierwotne u³o¿enie wartoœci jak by³o w xmm1 tylko ju¿ s¹ po obróbce
        
        ;Zapis przetworzonych danych
        movdqu xmmword ptr[RCX + RSI],  xmm6
        movdqu xmmword ptr[RCX + RSI + 16],  xmm7
        movdqu xmmword ptr[RCX + RSI + 32],  xmm8

        add ESI, 48
        sub r12d, 48
        jb Nierowno
        jg Main
        mov r12d, [rsp+112]
        sub r13,1 
        jz EndProc
        add RCX, R10
        mov ESI, 0
        jg Main

EndProc:
        ;Pobranie rejestrów nieulotnych ze stosu
        pop RSP
        pop RSI
        pop RDI
        pop RBP
        pop RBX
        ret 
Nierowno: 
        ;Wyrównywanie bajtów do przetworzenia do 48
        xor r12d, eax
        sub r12d, eax
        sub ESI, r12d
        sub ESI, 48
        mov r12d, 48
        jmp Main
       
MyProc1 endp
end