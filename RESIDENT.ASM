.model tiny
.code
.186
locals @@
org 100h
;--------------------------------------------------------------------|
; TSR - Terminate and Stay Resident
; This tool shows the status of all registers in real time
;--------------------------------------------------------------------|
FLAG_KEY	equ 12h				; F1
;--------------------------------------------------------------------|
Start: jmp LoadingTSR
;--------------------------------------------------------------------|
DrawFrame09		proc

	push ax bx cx dx si di ds es
	cld

	xor ax, ax
	in al, 60h
	cmp al, FLAG_KEY

	jne ChainOld09ISR

	xor cs:ShowFrame, 01h

	jmp ChainOld09ISR

ChainOld09ISR:                            ; address of the old int09h
	pop es ds di si dx cx bx ax

		db 0eah                 ;   jmp in bytes
Old09Ofs	dw 0                    ;   offset - changes in line 17
Old09Seg	dw 0                    ;   segment - changes in line 19

	iret

DrawFrame09		endp
;--------------------------------------------------------------------|
UpdateFrame08	proc
	push ax bx cx dx si di ds es	; save registers not to fuck them up
	push dx cx bx ax

	cld                              ; df = 0 (++)

	pop ax
	mov bx, offset cs:AXREG
	mov si, bx
	call HexToAscii

	pop ax
	mov bx, offset cs:BXREG
	mov si, bx
	call HexToAscii

	pop ax
	mov bx, offset cs:CXREG
	mov si, bx
	call HexToAscii

	pop ax
	mov bx, offset cs:DXREG
	mov si, bx
	call HexToAscii

	cmp cs:ShowFrame, 01h

	jne ChainOld08ISR
	call PrintRegisters

	jmp ChainOld08ISR

ChainOld08ISR:                            ; address of the old int08h

	pop es ds di si dx cx bx ax
		db 0eah                 ;   jmp in bytes
Old08Ofs	dw 0                    ;   offset - changes in line 17
Old08Seg	dw 0                    ;   segment - changes in line 19

		iret

UpdateFrame08	endp
;--------------------------------------------------------------------|
include printreg.asm
;--------------------------------------------------------------------|
.data
;--------------------------------------------------------------------|
ShowFrame	db 0
;--------------------------------------------------------------------|
EOF:
;--------------------------------------------------------------------|
LoadingTSR:

	xor ax, ax		                ; ax = 0
	mov es, ax		                ; es = 0

	mov bx, 08h * 4			        ; bx = 08h interrupt address
		        			; 4 bytes for address
	mov ax, es:[bx]				; save old int08h address
	mov Old08Ofs, ax               		; save offset
	mov ax, es:[bx + 2]             	;
	mov Old08Seg, ax                	; save segment (offset + 2)

	mov si, 09h * 4				; same thing, but with 09h interrupt

	mov ax, es:[si]
	mov Old09Ofs, ax
	mov ax, es:[si + 2]
	mov Old09Seg, ax

	cli									; IF = 0 -> interrupts are forbidden

	mov es:[bx], offset cs:UpdateFrame08	; set offset (for UpdateFrame08) ; remember about little endian ; because of it in memory: offset:segment
	push cs				        ; ax = cs
	pop ax
	mov es:[bx + 2], ax		        ; set segment address (for UpdateFrame08) - cs segment

	mov es:[si], offset cs:DrawFrame09	; set offset (for CheckShortcut09)
	mov es:[si + 2], ax		        ; set segment address - cs

	sti			                    ; IF = 1 -> interrupts are allowed

	mov cs:ShowFrame, 0h

	mov ah, 31h		                ; exit with reserving memory for resident
	mov dx, offset EOF
	shr dx, 4		                ; 31h counts in paragraphs
	inc dx                          ; to make sure everything in memory
	int 21h                         ; exit(with resident state)

end		Start
;--------------------------------------------------------------------|
