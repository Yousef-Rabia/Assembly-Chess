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


;---------------------------------------------------------
extrn player_name:byte
extrn other_player_name:byte
extrn player_mode:byte

public chat_mode

;------------------------------------------------------

.MODEL small
.data
    chat_message_offset Dw ?
    X_now              DB 0
    Y_now              DB 0
    X_ME           DB 3
    Y_ME           DB 0
    X_YOU          DB 4
    Y_YOU          DB 13
    LINE           DB "------------------------------------------------------------------------------------$"
    mrk            db ":$"
    _ah            db ? 
.code
ME_clear proc 
    ;clears the chat and return the cursor to the start of it
    mov X_ME,1
    mov Y_ME,1

    mov ax,0600h
    mov bh,7
    mov cl,0
    mov ch,1
    mov dl,79
    mov dh,11
    int 10h
    ret
ME_clear endp

YOU_clear proc 
    ;clears the chat and return the cursor to the start of it
    mov X_YOU,1
    mov Y_YOU,14

    mov ax,0600h
    mov bh,7
    mov cl,0
    mov ch,14
    mov dl,79
    mov dh,24
    int 10h
    ret
YOU_clear endp

Show_Message_chat PROC
                 PUSH_ALL
                 mov      ah,9h
                 mov      dx,chat_message_offset
                 int      21h
                 POP_ALL
                 RET
Show_Message_chat ENDP


CURSOR_GOTO PROC
                 PUSH_ALL
                 mov      ah,02h
                 mov      bh,0
                 mov      dl,X_now
                 mov      dh,Y_now
                 int      10h
                 POP_ALL
                 RET
CURSOR_GOTO ENDP

CURSOR_ME PROC
                 PUSH_ALL
                 MOV      BL,X_ME
                 MOV      X_now,BL
                 MOV      BL,Y_ME
                 MOV      Y_now,BL
                 POP_ALL
                 RET
CURSOR_ME ENDP

CURSOR_YOU PROC
                 PUSH_ALL
                 MOV      BL,X_YOU
                 MOV      X_now,BL
                 MOV      BL,Y_YOU
                 MOV      Y_now,BL
                 POP_ALL
                 RET
CURSOR_YOU ENDP

; --------------------------------------------------------------------------
chat_mode proc FAR
    ;CHAT SCREEN
                 MOV      AH,0
                 MOV      AL,3
                 INT      10H

                 MOV      X_now,0

                 MOV      Y_now,12
                 CALL     CURSOR_GOTO
                 MOV      chat_message_offset,OFFSET LINE
                 CALL     Show_Message_chat

                 MOV      Y_now,0
                 MOV      X_now,0 
                 CALL     CURSOR_GOTO

                 MOV      chat_message_offset,OFFSET player_name[2]
                 CALL     Show_Message_chat

                ; MOV      chat_message_offset,OFFSET mrk
                ; CALL     Show_Message_chat



                 MOV      Y_now,13
                 CALL     CURSOR_GOTO
                
                 MOV      chat_message_offset,OFFSET other_player_name
                 CALL     Show_Message_chat
                ; MOV      chat_message_offset,OFFSET mrk
                ; CALL     Show_Message_chat

                 MOV      X_ME,1
                 MOV     Y_ME,1
                 MOV      X_YOU,1
                 MOV     Y_YOU,14

    CHAT:        
    ;Check that Transmitter Holding Register is Empty
                 mov      dx , 3FDH                     ; Line Status Register
    
                 In       al , dx                       ;Read Line Status
                 AND      al , 00100000b
                 JZ      DONE1

    ;If empty put the VALUE in Transmit data register
    SEND_CHECK:  
                 MOV      AH,1
                 INT      16H
                 JZ       DONE1

    ;K EY PRESSED, GET IT
                MOV      AH,0
                 INT      16H
                 mov      _ah,ah
                 CMP      AH,1CH
                 JNE      NOT_ENTER
                 INC      Y_ME
                 cmp Y_ME,12
                 je full_chat_me

                 MOV      X_ME,0
                 JMP      DONE_ENTER
    NOT_ENTER:   
                    ;move cursor
                 CALL     CURSOR_ME
                 CALL     CURSOR_GOTO
                 INC      X_ME
                  cmp x_ME,80
                  jne NOT_END_OF_LINE
                    mov X_ME,0
                    inc Y_ME
                    cmp Y_ME,12
                 je full_chat_me
                  NOT_END_OF_LINE:
                ;  cmp x_ME,80
                ;  jne  goo
                ;     cmp Y_ME,11
                ;     jne gooo
                ;     mov     ah, 06h ; scroll up function id.
                ;     mov     al, 2   ; lines to scroll.
                ;     mov     bh, 07  ; attribute for new lines.
                ;     mov     cl, 0   ; upper col.
                ;     mov     ch, 0   ; upper row.
                ;     mov     dl, 80  ; lower col.
                ;     mov     dh, 0   ; lower row.
                ;     int     10h
                ;     mov X_ME,0
                ;     mov Y_ME,9
                ;     CALL     CURSOR_ME
                ;  CALL     CURSOR_GOTO
                ; goo:
                ; gooo:
                 MOV      AH,2
                 MOV      DL,AL
                 INT      21H

    DONE_ENTER: 

                cmp _ah,3dh  
                je go_to_menu 
                 mov      dx , 3F8H                     ; Transmit data register
                 out      dx , al
        jmp DONE1

        full_chat_me:
             call ME_clear   

    DONE1:       
    
    ;RECIEVE
    ;Check that Data Ready
                 mov      dx , 3FDH                     ; Line Status Register
                 in       al , dx
                 AND      al , 1
                 JZ       DONT_PRINT

    ;If Ready read the VALUE in Receive data register
                 mov      dx , 03F8H
                 in       al , dx
                 mov      DL , al

                 cmp al,7 
                 je go_to_menu2


                 CMP      aL,13
                 JNE      NOT_ENTER2
                 INC      Y_YOU
                 cmp Y_YOU,25
                 je full_chat_you

                 MOV      X_YOU,0
                 JMP      DONT_PRINT
    NOT_ENTER2:  

                 CALL     CURSOR_YOU
                 CALL     CURSOR_GOTO
                 INC      X_YOU
                    cmp X_YOU,80
                    jne NOT_END_OF_LINE_YOU
                    mov X_YOU,0
                    inc Y_YOU
                    cmp Y_YOU,25
                    je full_chat_you

                    NOT_END_OF_LINE_YOU:
                 mov      ah, 2
                 MOV      DL,AL
                 int      21h
    DONT_PRINT:
                full_chat_you:
                call YOU_clear

                JMP      CHAT
    go_to_menu:
                mov dx,3f8h
                mov al,7
                out dx,al
 
   go_to_menu2:             
ret
chat_mode endp
end

