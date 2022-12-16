include macros.inc


public inline_x,inline_y,inline_chat,show_player_name

extrn player_name:byte

.MODEL small
.stack 64
.DATA 
inline_x db 25
inline_y db 0

.code
inline_move_cursor proc
    push_all
    mov ah,02h
    mov bh,0
    mov dl,inline_x
    mov dh,inline_y
    int 10h
    pop_all
    ret
inline_move_cursor endp

show_player_name proc far
    push_all
    mov bx,2
    mov ah,2
    mov inline_x,25

    printing_name:
    call inline_move_cursor
    mov dl,player_name[bx]
    cmp dl,13                   ;half enter
    je printed_name
    int 21h
    inc inline_x
    inc bx
    jmp printing_name

    printed_name:
    mov dl,':'
    int 21h
    inc inline_x
    pop_all
    ret
show_player_name endp

inline_chat proc far
    cmp ah,1ch
    je enter_inline_endl

    ;moving the cursor to inline_x,inline_y then printing the character
    call inline_move_cursor

    mov dl,al
    mov ah,2
    int 21h

    inc inline_x
    cmp inline_x,40 ;if we have reached the end of the line we move to the next one
    je inline_endl
    ret

    ;we do the same as normal inline_endl and then print the player name
    enter_inline_endl:
    mov inline_x,25
    inc inline_y
    cmp inline_y,25
    je full_chat
    call show_player_name
    ret

    ;user have reached the end of the line or pressed enter
    inline_endl:
    mov inline_x,25
    inc inline_y
    cmp inline_y,25
    je full_chat
    ret

    full_chat:
    call inline_clear
    mov inline_y,0
    call show_player_name
    ret
inline_chat endp

inline_clear proc
    mov ax,0600h
    mov bh,0
    mov cl,25
    mov ch,0
    mov dl,39
    mov dh,24
    int 10h
    ret
inline_clear endp
end