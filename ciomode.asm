;
; CP/M Z80 HBIOS CIO PIO MODE TEST PROGRAM
;
; Version 2-Dec-2018 
; Phil Summers
; difficultylevelhigh@gmail.com
; Some code portions by Wayne Warthen. Thank you.
; Assemble with TASM
;
; USAGE: CIOMODE n
;
; Where n is the unit.
;
RESTART	.EQU	$0000
BDOS	.EQU	0005H
BDOUT	.EQU	09H	
CR	.EQU	0DH
LF	.EQU	0AH
stksiz	.equ	$40		; Working stack size
;
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

GETDEV:	LD	DE,UNITNUM	
	CALL	PSTRIN
	CALL	getnum		; GET UNIT TO VIEW IN A & C
	LD	(UNIT),A	; AND DISPLAY IT.
	CALL	OUTB

	LD	DE,DEVATT
	CALL	PSTRIN
	LD	A,(UNIT)
	LD	C,A
	LD	B,6		; RETURN VALUES IN C, D, E
	RST	08
	OR	A
	JR	NZ,FAIL
	PUSH	DE
	LD	A,C
	CALL	OUTB		; DISPLAY DEVICE ATTRIBUTE

	LD	DE,DEVTYP
	CALL	PSTRIN	
	POP	DE
	PUSH	DE
	LD	A,D
	CALL	OUTB		; DISPLAY DEVICE TYPE
	POP	DE

	PUSH	DE
	LD	DE,DEVNUM
	CALL	PSTRIN
	POP	DE
	LD	A,E
	CALL	OUTB		; DISPLAY DEVICE NUMBER

	LD	DE,DEVCHR
	CALL	PSTRIN
	LD	A,(UNIT)
	LD	C,A
	LD	B,5		; GET DEVICE CHARACTERISTICS
	RST	08		; AND DISPLAY
	OR	A
	JR	NZ,FAIL
	PUSH	DE
	LD	A,D
	CALL	OUTB
	POP	DE
	LD	A,E
	CALL	OUTB

BYE:	LD	DE,MSGEND	; GOODBYE
BYE1:	CALL	PSTRIN	

	ld	sp,(stksav)	; restore stack
	JP	RESTART		; return to CP/M via restart

FAIL:	LD	DE,ERRMSG
	JR	BYE1

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
;	CALL	OUTSPC
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

MSGBEG:	.DB	"CP/M Z80 HBIOS DISPLAY CIO UNIT MODE.",CR,LF,"$"
MSGEND:	.DB	CR,LF,"DONE.",CR,LF,"$"
UNITNUM:.DB	"UNIT $"
DEVATT:	.DB	" ATTRIBUTES $"
DEVTYP:	.DB	" TYPE $"
DEVNUM:	.DB	" NUMBER $"
DEVCHR:	.DB	" CHARACTERISTICS $"
ERRMSG:	.DB	" FAILED. $"

stksav	.dw	0		; stack pointer saved at start
	.fill	stksiz,0	; stack
stack	.equ	$

        .END
