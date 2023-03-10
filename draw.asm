;---------------------------Any Macros should be stored here------------------------------------------
PUSH_ALL MACRO 
            PUSH AX
            PUSH BX
            PUSH CX
            PUSH DX
            PUSH SI
            PUSH DI
ENDM PUSH_ALL

POP_ALL MACRO 
            POP DI
            POP SI
            POP DX
            POP CX
            POP BX
            POP AX
ENDM POP_ALL
;----------------------------------------------------------------------------------------------------

extrn update_Last_move_time:far

extrn bKing:byte
extrn wKing:byte
extrn bQueen:byte
extrn wQueen:byte
extrn bRook:byte
extrn wRook:byte
extrn bBishop:byte
extrn wBishop:byte
extrn valid1:byte
extrn valid2:byte
extrn bKnight:byte
extrn wKnight:byte
extrn bPawn:byte
extrn wPawn:byte
extrn bSquare:byte
extrn wSquare:byte
extrn selector1:byte
extrn selector2:byte
extrn locker:byte
extrn unlocker_black:byte
extrn unlocker_white:byte
extrn boardMap:byte
extrn valid_row:byte
extrn valid_col:byte
extrn piece_type:byte
extrn Star:byte
extrn EndGame:byte


extrn s1_col:word
extrn s1_row:word
extrn s2_col:word
extrn s2_row:word
extrn from_row:word
extrn from_col:word
extrn to_col:word
extrn to_row:word
extrn from_row_:word
extrn from_col_:word
extrn to_col_:word
extrn to_row_:word

extrn wFound:word
extrn bFound:word
extrn wPiece:word
extrn bPiece:word
extrn player_mode:byte

public draw_cell, get_cell_start,draw_valid_cell,draw_white_valid,draw_black_valid ,draw_selector1, draw_selector2, init_draw,move_piece,draw_W_from_cell
public draw_B_from_cell,draw_W_to_cell,draw_B_to_cell,Timer,PrintWinner,reset_timer,PrintBlackKilled,KilledBlack,KilledWhite,PrintWhiteKilled
public row, col, cell_start, shape_to_draw,check_W_piece,check_B_piece,move_piece_,draw_W_from_cell_,draw_B_from_cell_,draw_W_to_cell_,draw_B_to_cell_

.model small
.stack 64
.data
col dw 0
row dw 0
cell_start dw 0
shape_to_draw dw 0
KilledWhite db 0
KilledBlack db 0
;---------------Timer Data------------------
seconds1 db -1
seconds2 db 0
min1 db 0
min2 db 0
Last db 0
;----------Status Bar Data-----------------------
     White_win db "White Wins(F4)$"
     Black_win db "Black Wins(F4)$"
     BPwenDie db "B-Pawn Died$"
     WPwenDie db "W-Pawn Died$"
     BKnightDie db "B-Knight Died$"
     WKnightDie db "W-Knight Died$"
     BRooKDie db "B-Rook Died$"
     WRookDie db "W-Rook Died$"
     BQueenDie db "B-Queen Died$"
     WQueenDie db "W-Queen Died$"
     BBishopDie db "B-Bishop Died$"
     WBishopDie db "W-Bishop Died$"
     delete__ db "               $"

.code


;-------------------------------------------------------PrintBlackKilled-------------------------------------------------------------------
PrintBlackKilled proc far
PUSH_ALL
push bx
     ; mov cursor
     mov ah,2
     mov dx,1719h
     int 10h 
     
     ;delete
     lea bx,delete__
     mov ah, 9
     mov dx,bx
     int 21h
pop bx
     ; mov cursor
     mov ah,2
     mov dx,1719h
     int 10h 
     ;-------
     mov al,KilledBlack
     lea bx,BRooKDie
     cmp al,11h
     je found_B 
     cmp al,01h
     je found_B 
     lea bx,BKnightDie
     cmp al,02h
     je found_B 
     cmp al,12h
     je found_B 
     lea bx,BBishopDie
     cmp al,13h
     je found_B 
     cmp al,03h
     je found_B
     lea bx,BPwenDie
     cmp al,40h
     je found_B 
     cmp al,41h
     je found_B 
     cmp al,42h
     je found_B 
     cmp al,43h
     je found_B 
     cmp al,44h
     je found_B 
     cmp al,45h
     je found_B 
     cmp al,46h
     je found_B 
     cmp al,47h
     je found_B 
     lea bx,BQueenDie
     cmp al,0Bh
     je found_B
     jmp end_B

     found_B:
     mov ah, 9
     mov dx,bx
     int 21h
     end_B:
     ;-------
     POP_ALL
     ret 
PrintBlackKilled endp
;-------------------------------------------------------PrintWhiteKilled-------------------------------------------------------------------
PrintWhiteKilled proc far
PUSH_ALL
push bx
     ; mov cursor
     mov ah,2
     mov dx,1719h
     int 10h 
     
     ;delete
     lea bx,delete__
     mov ah, 9
     mov dx,bx
     int 21h
pop bx
     ; mov cursor
     mov ah,2
     mov dx,1719h
     int 10h 
     ;-------
     mov al,KilledWhite
     lea bx,WRooKDie
     cmp al,21h
     je found_W 
     cmp al,31h
     je found_W 
     lea bx,WKnightDie
     cmp al,22h
     je found_W 
     cmp al,32h
     je found_W 
     lea bx,WBishopDie
     cmp al,23h
     je found_W 
     cmp al,33h
     je found_W
     lea bx,WPwenDie
     cmp al,50h
     je found_W 
     cmp al,51h
     je found_W 
     cmp al,52h
     je found_W 
     cmp al,53h
     je found_W 
     cmp al,55h
     je found_W 
     cmp al,55h
     je found_W 
     cmp al,56h
     je found_W 
     cmp al,57h
     je found_W 
     lea bx,WQueenDie
     cmp al,1Bh
     je found_W
     jmp end_W

     found_W:
     mov ah, 9
     mov dx,bx
     int 21h
     end_W:
     ;-------
     POP_ALL
     ret 
PrintWhiteKilled endp
;-------------------------------------------------------PrintWinner-------------------------------------------------------------------
reset_timer proc far
     mov seconds1, -1
     mov seconds2, 0
     mov min1, 0
     mov min2, 0 
     mov Last, 0
     ret
reset_timer endp


PrintWinner proc far
PUSH_ALL
     ; mov cursor
     mov ah,2
     mov dx,1819h
     int 10h 
     ;------
     cmp EndGame,0Ah
     jne BWin
     lea bx,White_win
     jmp GoPrint
     BWin:
     lea bx,Black_win
     GoPrint:
mov ah, 9
mov dx,bx
int 21h
     POP_ALL
     ret 
PrintWinner endp
;-------------------------------------------------------Timer-------------------------------------------------------------------
Timer proc far
PUSH_ALL
;get time.
  mov  ah, 2ch
  int  21h 
;check if one second has passed.
  cmp  dh, Last
  je   no_change
 
  mov Last,dh
  add  seconds1,1    
  
    call update_Last_move_time


  ; mov cursor
  mov ah,2
  mov dx,001eh
  int 10h 
  
  
  
;display text every second.
     mov ah,2
     mov dl,min2
     add dl,'0'
     int 21h
     ;------
     mov ah,2
     mov dl,min1
     add dl,'0'
     int 21h
     ;------
     mov ah,2
     mov dl,':'
     int 21h 
     ;-----
     mov ah,2
     mov dl,seconds2
     add dl,'0'
     int 21h
     ;------
     mov ah,2
     mov dl,seconds1
     add dl,'0'
     int 21h


    cmp seconds1,9
    jne no_change
    mov seconds1,-1
    add seconds2,1
    
    cmp seconds2,6
    jne no_change
    mov seconds2,0
    add min1,1 
    
    cmp min1,9
    jne no_change
    mov min1,0
    add min2,1
    ;finish.
no_change:  
POP_ALL
     ret 
Timer endp

;----------------------------------------------------Helping Function for draw_cell----------------------------------------------------
drawLine proc
     
     ;don't push SI!!!
     push ax
     push bx    
     push cx
     push dx
     push di
     
     mov cx,25
     draw_pixel:
          mov al,ds:[si]
          cmp al,02h
          je skip_pixel
          mov es:[di],al
          skip_pixel:
          inc si
          inc di
     loop draw_pixel
          
     pop di
     pop dx
     pop cx
     pop bx
     pop ax
     ret 
drawLine endp

;--------------------------------------------------------Useful-everywhere-------------------------------------------------------------

get_cell_start proc far
     ;gets cell cell_start from row and col values and stores it in the variable "cell_start"
     push_all
     mov ax,25
     mul col
     mov bx,ax

     ;the sole reason why col and row is a word instead of a byte
     mov ax,8000
     mul row
     add ax,bx

     mov cell_start,ax
     pop_all
     ret
get_cell_start endp

draw_cell proc far
     ;draws a cell with the shape_to_draw at the selected row and col    
     push_all
     mov cx,25
     call get_cell_start
     mov di,cell_start
     mov si, shape_to_draw
     draw_cell_loop:
          call drawLine
          add di,320
     loop draw_cell_loop
     pop_all
     ret
draw_cell endp


draw_selector1 proc far
     push ax
     cmp player_mode,2
     je no_selector_1

     mov shape_to_draw,offset selector1
     mov ax,s1_col
     mov col,ax
     mov ax,s1_row
     mov row,ax
     call draw_cell
     
     no_selector_1:
     pop ax
     ret
draw_selector1 endp

draw_selector2 proc far
    Push ax
    cmp player_mode,1
    je no_selector_2

    mov shape_to_draw,offset selector2
    mov ax,s2_col
    mov col,ax
    mov ax,s2_row
    mov row,ax
    call draw_cell
    
    no_selector_2:
    Pop ax
    ret
draw_selector2 endp

draw_valid_cell proc  ; draw the highlight for valid cells
    push ax
    mov al,valid_col
    mov ah,00
    mov col,ax
    mov al,valid_row
    mov row,ax
    call draw_cell
    pop ax
    ret
draw_valid_cell endp
;--------------------------------
draw_black_valid proc far ;draw highlight for white 
push_all
    mov shape_to_draw,offset valid2
     call draw_valid_cell
     pop_all
     ret
draw_black_valid endp
;--------------------------------
draw_white_valid proc far ;draw highlight for white 
push_all
    mov shape_to_draw,offset valid1
          call draw_valid_cell
          pop_all
     ret
draw_white_valid endp
;---------------------------------------------------------- move piece ----------------------------------------------------------

move_piece proc far
     push ax
     mov ax,to_col
     mov col,ax
     mov ax,to_row
     mov row,ax
     call draw_cell
     pop ax
     ret
move_piece endp

draw_W_from_cell proc far
    Push ax
    mov shape_to_draw,offset wSquare
    mov ax,from_col
    mov col,ax
    mov ax,from_row
    mov row,ax
    call draw_cell
    Pop ax
    ret
draw_W_from_cell endp

draw_B_from_cell proc far
    Push ax
    mov shape_to_draw,offset bSquare
    mov ax,from_col
    mov col,ax
    mov ax,from_row
    mov row,ax
    call draw_cell
    Pop ax
    ret
draw_B_from_cell endp

draw_W_to_cell proc far
    Push ax
    mov shape_to_draw,offset wSquare
    mov ax,to_col
    mov col,ax
    mov ax,to_row
    mov row,ax
    call draw_cell
    Pop ax
    ret
draw_W_to_cell endp

draw_B_to_cell proc far
    Push ax
    mov shape_to_draw,offset bSquare
    mov ax,to_col
    mov col,ax
    mov ax,to_row
    mov row,ax
    call draw_cell
    Pop ax
    ret
draw_B_to_cell endp



check_W_piece proc far
     PUSH_ALL
     lea bx,boardMap
     mov ax,from_row
     mov cl,8
     mul cl
     add ax,from_col
     add bx,ax
     mov al,[bx]
          mov wPiece,offset wRook
     cmp al,31h
     je found 
     cmp al,21h
     je found 
          mov wPiece,offset wKnight
     cmp al,22h
     je found
     cmp al,32h
     je found
     mov wPiece,offset wBishop
     cmp al,23h
     je found 
     cmp al,33h
     je found
          mov wPiece,offset wPawn
     cmp al,50h
     je found 
     cmp al,51h
     je found 
     cmp al,52h
     je found 
     cmp al,53h
     je found 
     cmp al,54h
     je found 
     cmp al,55h
     je found 
     cmp al,56h
     je found 
     cmp al,57h
     je found 
     mov wPiece,offset wKing
     cmp al,1Ah
     je found 
     mov wPiece,offset wQueen
     cmp al,1Bh
     je found
     jmp not_found

     not_found:
          mov wFound,00h
          jmp ee
     found:
          mov wFound,01h
          mov piece_type,al
     ee:
     POP_ALL
     ret
check_W_piece endp
;---------------------------------------------------------- move Black piece ----------------------------------------------------------

move_piece_ proc far
     push ax
     mov ax,to_col_
     mov col,ax
     mov ax,to_row_
     mov row,ax
     call draw_cell
     pop ax
     ret
move_piece_ endp

draw_W_from_cell_ proc far
    Push ax
    mov shape_to_draw,offset wSquare
    mov ax,from_col_
    mov col,ax
    mov ax,from_row_
    mov row,ax
    call draw_cell
    Pop ax
    ret
draw_W_from_cell_ endp

draw_B_from_cell_ proc far
    Push ax
    mov shape_to_draw,offset bSquare
    mov ax,from_col_
    mov col,ax
    mov ax,from_row_
    mov row,ax
    call draw_cell
    Pop ax
    ret
draw_B_from_cell_ endp

draw_W_to_cell_ proc far
    Push ax
    mov shape_to_draw,offset wSquare
    mov ax,to_col_
    mov col,ax
    mov ax,to_row_
    mov row,ax
    call draw_cell
    Pop ax
    ret
draw_W_to_cell_ endp

draw_B_to_cell_ proc far
    Push ax
    mov shape_to_draw,offset bSquare
    mov ax,to_col_
    mov col,ax
    mov ax,to_row_
    mov row,ax
    call draw_cell
    Pop ax
    ret
draw_B_to_cell_ endp

check_B_piece proc far
     PUSH_ALL
     lea bx,boardMap
     mov ax,from_row_
     mov cl,8
     mul cl
     add ax,from_col_
     add bx,ax
     mov al,[bx]
     mov bPiece,offset bRook
     cmp al,11h
     je found_ 
     cmp al,01h
     je found_ 
     mov bPiece,offset bKnight
     cmp al,02h
     je found_ 
     cmp al,12h
     je found_ 
     mov bPiece,offset bBishop
     cmp al,13h
     je found_ 
     cmp al,03h
     je found_
     mov bPiece,offset bPawn
     cmp al,40h
     je found_ 
     cmp al,41h
     je found_ 
     cmp al,42h
     je found_ 
     cmp al,43h
     je found_ 
     cmp al,44h
     je found_ 
     cmp al,45h
     je found_ 
     cmp al,46h
     je found_ 
     cmp al,47h
     je found_ 
     mov bPiece,offset bKing
     cmp al,0Ah
     je found_ 
     mov bPiece,offset bQueen
     cmp al,0Bh
     je found_
     jmp not_found_

     not_found_:
          mov bFound,00h
          jmp ee_
     found_:
          mov piece_type,al
          mov bFound,01h
     ee_:
     POP_ALL
     ret
check_B_piece endp
;-------------------------------------------------------Exclusive For Initial Drawing---------------------------------------------------------------------

get_init_piece proc
     ;gets the offset of the initial piece based on row and col and stores it in "shape_to_draw"
     cmp row,1
     je bpa
     cmp row,6
     je wpa

     cmp row,0
     je black
     cmp row,7
     je white

     bpa:
     mov shape_to_draw,offset bPawn
     ret
     wpa:
     mov shape_to_draw,offset wPawn
     ret

     white:
     cmp col,0 
     je wro
     cmp col,1
     je wkn
     cmp col,2 
     je wbi
     cmp col,3
     je wqe
     cmp col,4 
     je wki
     cmp col,5
     je wbi
     cmp col,6 
     je wkn
     cmp col,7
     je wro

     wkn:
     mov shape_to_draw,offset wKnight
     ret
     wbi:
     mov shape_to_draw,offset wBishop
     ret
     wro:
     mov shape_to_draw,offset wRook
     ret
     wki:
     mov shape_to_draw,offset wKing
     ret
     wqe:
     mov shape_to_draw,offset wQueen
     ret

     black:
     cmp col,0 
     je bro
     cmp col,1
     je bkn
     cmp col,2 
     je bbi
     cmp col,3
     je bqe
     cmp col,4 
     je bki
     cmp col,5
     je bbi
     cmp col,6 
     je bkn
     cmp col,7
     je bro

     bkn:
     mov shape_to_draw,offset bKnight
     ret
     bbi:
     mov shape_to_draw,offset bBishop
     ret
     bro:
     mov shape_to_draw,offset bRook
     ret
     bqe:
     mov shape_to_draw,offset bQueen
     ret
     bki:
     mov shape_to_draw,offset bKing
     ret 
get_init_piece endp

draw_board_pieces proc
     mov row,0
     draw_board:
     mov col,0

     draw_row:
   
     call get_init_piece
     call draw_cell

     inc col
     cmp col,7
     jle draw_row

     cmp row,1
     jne normal_inc
     add row,4
     normal_inc:
     inc row
     cmp row,7
     jle draw_board

     ret
draw_board_pieces endp

draw_empty_board proc
     ;draws empty white and black board
     mov shape_to_draw,offset wSquare
     mov bl,0ffh
     mov row,0
     draw_board2:
     mov col,0

     draw_row2:
     call draw_cell

     ;switching between black and white squares
     not bl
     cmp col,7
     je white_square ;not really white square, but to skip switching colors after the end of a row

     cmp bl,0
     je black_square
     mov shape_to_draw,offset wSquare
     jmp white_square
     black_square:
     mov shape_to_draw,offset bSquare
     white_square:

     inc col
     cmp col,7
     jle draw_row2

     not bl
     inc row
     cmp row,7
     jle draw_board2
     
     ret
draw_empty_board endp

init_draw proc far
     push_all
     mov ah,0
     mov al,13h
     int 10h

     mov ax,0A000H
     mov es,ax

     call draw_empty_board
     call draw_board_pieces
     call draw_selector1
     call draw_selector2
     pop_all
     ret
init_draw endp
end