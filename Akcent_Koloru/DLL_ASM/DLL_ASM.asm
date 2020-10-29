.data
 amask BYTE 0,3,6,9,12,15,2,2,2,2,2,2,2,2,2,2
 bmask BYTE 2,5,8,11,14,0,0,0,0,0,0,0,0,0,0,0
 cmask BYTE 1,4,7,10,13,2,2,2,2,2,2,2,2,2,2,2 

 recoveryAmask BYTE 10,0,0,11,0,0,12,0,0,13,0,0,14,0,0,15
 recoveryBmask BYTE 0,11,0,0,12,0,0,13,0,0,14,0,0,15,0,0
 recoveryCmask BYTE 0,0,11,0,0,12,0,0,13,0,0,14,0,0,15,0

 multiplyMoveMask2 BYTE 0,15,0,15,0,15,0,15,0,15,0,15,0,15,0,15

 condMask1 BYTE 0,2,4,6,8,10,12,14,15,15,15,15,15,15,15,15 
 condMask2 BYTE 15,15,15,15,15,15,15,15,0,2,4,6,8,10,12,14

.code
MyProc1 proc 
        push RBX ; rcx - adres bitmapy
        push RBP ; rdx - offset
        push RDI ; r8 - rows
        push RSI ; r9 - red     rsp+80 - green      rsp+88 - blue    rsp+96 - range     rsp+104 - stride    rsp+112 - lineWidth
        push RSP
        mov RSI, 0
        ADD RSI, rdx
        mov r13, r8 ; Licznik w r13
        mov r10d, [rsp + 104]
        mov r12d, [rsp + 112]
        mov r11, 0
Main:
        ;Wczytanie 16 pikseli
        movdqu xmm0, xmmword ptr[RCX + RSI]
        movdqu xmm1, xmmword ptr[RCX + RSI + 16]
         movdqu xmm2, xmmword ptr[RCX + RSI + 32] 

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
        paddq xmm3, xmm4; Tablica b w xmm3 <----

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
        paddq xmm4, xmm5; Tablica g w xmm4 <----

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
        paddq xmm5, xmm6; Tablica r w xmm5 <----

        movdqu xmm0, xmm3; W xmm3 i xmm0 wartosci b
        movdqu xmm1, xmm4; W xmm4 i xmm1 wartosci g
        movdqu xmm2, xmm5; W xmm5 i xmm2 wartosci r

        ;Rozszerzenie b na 16 bitów        
        movdqu xmm4, xmm0 
        pmovzxbw xmm3, xmm4; b7 - b0 - XMM 3
        psrldq xmm4, 8
        pmovzxbw xmm4, xmm4 ; b15 - b8 - XMM 4

        ;Rozszerzenie g na 16 bitów
        movdqu xmm6, xmm1
        pmovzxbw xmm5, xmm6; g7 - g0 - XMM 5
        psrldq xmm6, 8
        pmovzxbw xmm6, xmm6 ; g15 - g8 - XMM 6

        ; Rozszerzenie r na 16 bitów
        movdqu xmm8, xmm2 
        pmovzxbw xmm7, xmm8; r7 - r0 - XMM 7
        psrldq xmm8, 8
        pmovzxbw xmm8, xmm8 ; r15 - r8 - XMM 8
        
        ;Wczytywanie barwy podanej przez u¿ytkownika 
        mov EAX,  r9d 
        movd xmm11, eax;
        pshufb xmm11, xmmword ptr[multiplyMoveMask2]; Red na 16 bitach - XMM 11
      
        mov EAX,  [rsp+80]
        movd xmm12, eax;
        pshufb xmm12, xmmword ptr[multiplyMoveMask2]; Green na 16 bitach - XMM 12
       
        mov EAX,  [rsp+88]
        movd xmm14, eax;
        pshufb xmm14, xmmword ptr[multiplyMoveMask2]; Blue na 16 bitach - XMM 14
        
        movdqu xmm10,xmm11; R 
        psubw xmm10, xmm7;  R-r[7-0]
        pabsw xmm10, xmm10; ABS (R-r[7-0]) - XMM 10
        
        psubw xmm11, xmm8;  R-r[15-8]
        pabsw xmm11, xmm11; ABS (R-r[15-8]) - XMM 11

        movdqu xmm13, xmm12
        psubw xmm13, xmm5;  G-g[7-0]
        pabsw xmm13, xmm13; ABS (G-g[7-0]) - XMM 13
        
        psubw xmm12, xmm6
        pabsw xmm12, xmm12 ; ABS(G-g[15-8]) - XMM 12

        movdqu xmm15, xmm14
        psubw xmm14, xmm3;  B-b[7-0]
        pabsw xmm14, xmm14; ABS (B-b[7-0]) - XMM 14
        
        psubw xmm15, xmm4
        pabsw xmm15, xmm15 ; ABS(B-b[15-8]) - XMM 15

        paddw xmm10, xmm13 
        paddw xmm10, xmm14; DISTANCE [7-0] - XMM 10
       
        paddw xmm11, xmm12 
        paddw xmm11, xmm15; DISTANCE [15-8] - XMM 11
        
        ;Wczytywanie zakresu
        mov EAX, [rsp+96] 
        movd xmm9, eax;
        pshufb xmm9, xmmword ptr[multiplyMoveMask2]; Range na 16 bitach
        
        movdqu xmm12, xmm9 
        pcmpgtw xmm12, xmm10; Range > Distance [7-0] - XMM 12
        pcmpgtw xmm9, xmm11; Range > Distance [15-8] - XMM 9 
        psllq xmm12,8
        psrlq xmm12,8
        pshufb xmm12, xmmword ptr[condMask1]
        psllq xmm9,8
        psrlq xmm9,8
        pshufb xmm9, xmmword ptr[condMask2]
        paddb xmm9, xmm12; <---- Czy range > distance  - XMM 9 
     
        mov EAX, 86;  256/3 + 1 = 86 
        movd xmm10, EAX
        pshufb xmm10, xmmword ptr[multiplyMoveMask2]; 86 <- na 16 bitach

        pmullw xmm3, xmm10; b[7-0] * 86 <- xmm3 
        psrlw xmm3, 8; 3/256 
        pshufb xmm3, xmmword ptr[condMask1]; <- xmm 3 = b[7-0] / 3 
     
        pmullw xmm4, xmm10; b[15-8] * 86 <- xmm4
        psrlw xmm4, 8; 3/256 
        pshufb xmm4, xmmword ptr[condMask2]; <- xmm 4 = b[15-8] / 3 
        
        paddb xmm3, xmm4; <------------------- XMM 3 = b[15-0] /3 

        pmullw xmm5, xmm10; g[7-0] * 86 <- xmm5
        psrlw xmm5, 8; 3/256 
        pshufb xmm5, xmmword ptr[condMask1]; <- xmm 5 = g[7-0] / 3 
     
        pmullw xmm6, xmm10; g[15-8] * 86 <- xmm4
        psrlw xmm6, 8; 3/256 
        pshufb xmm6, xmmword ptr[condMask2]; <- xmm 6 = g[15-8] / 3 
        
        paddb xmm5,xmm6 ;  <-------------------- XMM 5 = g[15 - 0] / 3 

        pmullw xmm7, xmm10; r[7-0] * 86 <- xmm7 
        psrlw xmm7, 8; 3/256 
        pshufb xmm7, xmmword ptr[condMask1]; <- xmm 7 = r[7-0] / 3 
     
        pmullw xmm8, xmm10; b[15-8] * 86 <- xmm8
        psrlw xmm8, 8; 3/256 
        pshufb xmm8, xmmword ptr[condMask2]; <- xmm 8 = r[15-8] / 3 

        paddb xmm7,xmm8 ;  <-------------------- XMM 7 = r[15 - 0] / 3 
       
        paddb xmm3, xmm5
        paddb xmm3, xmm7; rgb[15-0] / 3  - XMM 3 

        ;Warunkowe uk³adanie sk³adowych (pierwotna barwa lub œrednia) 
        movdqu xmm4, xmm9; Kopiujê warunek 
        pand xmm0, xmm9; Te z b które s¹ zgodne z RANGE > DISTANCE 
        pandn xmm4, xmm3; Œrednia dla niezgodnych 
        paddb xmm0, xmm4; Wynik w XMM 0 

        movdqu xmm4, xmm9; Kopiujê warunek
        pand xmm1, xmm9; Te które s¹ zgodne z RANGE > DISTANCE 
        pandn xmm4, xmm3; Œrednia dla niezgodnych
        paddb xmm1, xmm4; Wynik w xmm1  

        pand xmm2, xmm9; Te które s¹ zgodne z RANGE > DISTANCE 
        pandn xmm9, xmm3; Dla niezgodnych œrednia
        paddb xmm2, xmm9; Wynik w xmm2

       ; movdqu xmm0, xmm3; 
       ; movdqu xmm1, xmm3; 
        ;movdqu xmm2, xmm3; 

        ; Przywracanie nale¿ytej kolejnoœci sk³adowych 
        ; Wartoœci Blue
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
        ; Wartoœci Red
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
        ; Wartoœci Green
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
        pslldq xmm9, 10   ; zostawiam tylko 6 bajtów tego rejestru - 5 najni¿szych indeksowo wartoœci
        psrldq xmm2, 6    ; w³aœnie zosta³y zabrane
        pshufb xmm9, xmmword ptr[recoveryAmask] 
        paddq xmm8, xmm9  ; W xmm8 pierwotne u³o¿enie wartoœci jak by³o w xmm1 tylko ju¿ s¹ po obróbce
        
        movdqu xmmword ptr[RCX + RSI],  xmm6 
        movdqu xmmword ptr[RCX + RSI + 16],  xmm7
        movdqu xmmword ptr[RCX + RSI + 32],  xmm8 

        add ESI, 48
        sub r12d, 48
       ; jb Nierowno
        jg Main
        mov r12d, [rsp+112]
        sub r13,1 
        jz EndProc
        add RCX, R10
        mov ESI, 0
        jg Main

EndProc:
        pop RSP
        pop RSI
        pop RDI
        pop RBP
        pop RBX
        ret 
Nierowno: 
        neg r12d
        inc r12d ; Do zapisu u2
        sub ESI, r12d
        sub ESI, 48
        jmp Main

MyProc1 endp
end