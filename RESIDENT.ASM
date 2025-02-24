.model tiny
.186
.code
org 100h
locals
;####################################################################|
;--------------------------------------------------------------------|
VIDEOSEG	equ 0b800h
SCREENL		equ 050h
SCREENW		equ 019h
;--------------------------------------------------------------------|
; F9 - commands - memory info - perexvaty -> release = klava rabotaet
; system queue after interruption list?
; zapisyvautsya scan codes nazhatiy poka naprimer volkov otrisovyvaet sebya
; max 15 scan codes
; 16H 00H - analog getchar()
; appartny kolzevoy buffer v klave
; preobrazovanie scan code to ascii code

Start:
	xor ax, ax
	mov es, ax
	mov bx, 09h * 4 ; interruption number (09H) * 4
			; cause every address takes 2 byte (segment + shift)

	; nuzhen teper stary obrabotchik
	mov ax, es:[bx]
	mov Old09Ofs, ax ; ax?
	mov ax, es:[bx + 2]
	mov Old09Seg, ax ; ax?

	; IMPORTANT LINE ;
	cli
	; IMPORTANT LINE ;

	mov es:[bx], offset New09 ; my interrupt function

	push cs
	pop ax

	mov es:[bx+2], ax ; put segment address

	; IMPORTANT LINE ;
	sti
	; IMPORTANT LINE ;

	int 09h ; CHECKER

	mov ax, 3100h
	mov dx, offset EOP
	shr dx, 4
	inc dx		 ; last paragraph
	int 21h

;-----------------------------------------------------------------|

New09	proc

	push ax bx cx dx es ds		; save AX, ES, DI

	mov ax, VIDEOSEG
	mov es, ax
	mov ah, 4ch
	mov di, 5*80*2

	cld

	;call PrintRegisters

	in al, 60H
	stosw

	jmp ChainOldISR 	; jump to old ISR

	; nuzhno chtoby kontroller vozobnovil obrabotky preryvani
	; signal chto preryvanie obrabotano
	; podacaha signala EOI (end of interrupt)

	; teper mozhno vozvrachatsya
	; forma vozvrata iret - interrupt return - vozvrachaetsya na adress
	; i vosstanavliavet flagi
	; else disbalance stacka

	iret

include printreg.asm

ChainOldISR:	; Chain to old interrupt service routine
		pop ds es dx cx bx ax

		db 0eah
Old09Ofs	dw 0
Old09Seg	dw 0

	endp

EOP:

end 	Start
;####################################################################|
