;
; CP/M Z80 HBIOS CIO PIO BIT MODE TEST PROGRAM
;
; Version 27-Nov-2018 
; Phil Summers
; difficultylevelhigh@gmail.com
; Some code portions by Wayne Warthen. Thank you.
;
; USAGE: PIOCIOTST n
;
;
; Default test pattern for each port is:
; 
; 1 Toggle all bits on and off. 
; 2 Toggle each bit on and off.
; 3 Toggle alternate bits on and off. 
;
;
RESTART	.EQU	$0000
BDOS	.EQU	0005H
BDOUT	.EQU	09H	
CR	.EQU	0DH
LF	.EQU	0AH
stksiz	.equ	$40		; Working stack size

	.ORG	100H
;
	ld	(stksav),sp	; save stack
	ld	sp,stack	; set new stack

RUN:	LD	DE,MSGBEG	; HELLO
	CALL	PSTRIN

	ld	ix,$81		; point to start of parm area (past len byte)
SKIP:	ld	a,(ix)		; load next character
	or	a		; string ends with a null
	jr	z,GETDEV	; if null, return pointing to null
	cp	' '		; check for blank
	JR	nz,GETDEV	; return if not blank
	inc	ix		; if blank, increment character pointer
	jr	SKIP		; and loop

GETDEV:	CALL	getnum		; DEVICE TO TEST IS IN A & C
	LD	(UNIT),A
	LD	B,$04		; INIT 
	LD	DE,$FFFF
	RST	08

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
	LD	B,$01
	LD	A,(UNIT)
	LD	C,A
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

	ld	sp,(stksav)	; restore stack
	JP	RESTART		; return to CP/M via restart
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

;
; Get numeric chars and convert to number returned in A
; Carry flag set on overflow
;
getnum:
	ld	c,0		; C is working register
getnum1:
	ld	a,(ix)		; get the active char
	cp	'0'		; compare to ascii '0'
	jr	c,getnum2	; abort if below
	cp	'9' + 1		; compare to ascii '9'
	jr	nc,getnum2	; abort if above
;
	; valid digit, add new digit to C
	ld	a,c		; get working value to A
	rlca			; multiply by 10
	ret	c		; overflow, return with carry set
	rlca			; ...
	ret	c		; overflow, return with carry set
	add	a,c		; ...
	ret	c		; overflow, return with carry set
	rlca			; ...
	ret	c		; overflow, return with carry set
	ld	c,a		; back to C
	ld	a,(ix)		; get new digit
	sub	'0'		; make binary
	add	a,c		; add in working value
	ret	c		; overflow, return with carry set
	ld	c,a		; back to C
;
	inc	ix		; bump to next char
	jr	getnum1		; loop
;
getnum2:	; return result
	ld	a,c		; return result in A
	or	a		; with flags set, CF is cleared
	ret

UNIT:	.DB	0

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

stksav	.dw	0		; stack pointer saved at start
	.fill	stksiz,0	; stack
stack	.equ	$

        .END
