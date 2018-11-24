;
; CP/M Z80 HBIOS CIO PIO BIT MODE TEST PROGRAM
;
; Version 20-Nov-2018 
; Phil Summers
; difficultylevelhigh@gmail.com
;
; Default test pattern for each port is:
; 
; 1 Toggle all bits on and off. 
; 2 Toggle each bit on and off.
; 3 Toggle alternate bits on and off. 
;
;
UNIT	.EQU	$07
BDOS	.EQU	0005H
BDOUT	.EQU	09H	
CR	.EQU	0DH
LF	.EQU	0AH

	.ORG	100H
;
	LD	DE,MSGBEG	; HELLO
	CALL	PSTRIN

	LD	B,$04		; INIT 
	LD	C,UNIT
	LD	DE,$FFFF

	CALL	PAUSE
	CALL	PAUSE
	CALL	PAUSE
	CALL	PAUSE
;
; DISPLAY TEST PATTERN
;
	LD	HL,TSTBEG
	LD	B,TSTPAT-TSTBEG
LP2:	LD	A,(HL)
	CALL	OUTB
	CALL	OUTSPC
;
	LD	A,(HL)
	LD	E,A
;
	PUSH	BC
;	LD	E,$00
	LD	B,$01
	LD	C,UNIT
	RST	08
	POP	BC
	CALL	PAUSE
	CALL	PAUSE
;
	INC	HL
	DJNZ	LP2
;
BYE:	LD	DE,MSGEND	; GOODBYE
	CALL	PSTRIN	
	RET
;
; PAUSE
;
PAUSE:	PUSH	DE
	PUSH	BC	
   	LD      D,0FFH
LP3:    LD      B,0FFH
LP4:	DJNZ    LP4
        DEC     D
        JR      NZ,LP3
        POP	BC
        POP	DE
	RET
;
; OUTPUT SPACE
;
OUTSPC:	LD	E,20H
	CALL	PCHAR
	RET
;
; OUTPUT CR+LF
;
CRLF:	LD	E,CR
	CALL	PCHAR
	LD	E,LF
	CALL	PCHAR
	RET
;
; OUTPUT BYTE A
;	
OUTB:	PUSH	AF
	RRCA
	RRCA
	RRCA
	RRCA
	AND	0FH
	CALL	HBTHE
	POP	AF
	AND	0FH
	CALL	HBTHE
	CALL	OUTSPC
	RET
;
;Output HALF-BYTE
;****************
;
;PARAMETER: Entry Half-BYTE IN A (BIT 0 - 3)
;*********
;
HBTHE:	CP 	0AH
	JR	C,HBTHE1
	ADD	A,7
HBTHE1:	ADD	A,30H
	LD	E,A
	CALL	PCHAR
	RET
;
; PRINT A CHARACTER 
;
PCHAR:	PUSH	BC
	LD	C,02H
	JR	BDO
PSTRIN:	PUSH	BC
	LD	C,09H
	JR	BDO
;
; CP/M BDOS CALL
;
BDO:	PUSH	HL
	PUSH	DE
	PUSH	IX
	PUSH	IY
	CALL	BDOS
	POP	IY
	POP	IX
	POP	DE
	POP	HL
	POP	BC
	RET

MSGBEG:	.DB	"CP/M Z80 HBIOS PIO BIT MODE TEST.",CR,LF,"$"
MSGEND:	.DB	CR,LF,"TEST COMPLETE.",CR,LF,"$"
PIONUM:	.DB	"PIO $"
PORTNUM:.DB	"PORT $"

TSTBEG	.EQU	$
	.DB	0FFH
        .DB      55H
        .DB      0AAH
        .DB      55H
        .DB      0AAH
	.DB	55H
	.DB	0AAH
	.DB	55H
	.DB	0AAH
	.DB	00H
	.DB	01H
	.DB	02H
	.DB	04H
	.DB	08H
	.DB	10H
	.DB	20H
	.DB	40H
	.DB	80H
	.DB	00H
	.DB	0FFH
	.DB	00H
	.DB	0FFH
	.DB	00H
	.DB	0FFH
	.DB	00H
TSTPAT:	.DB	0FFH	

        .END
