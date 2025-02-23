CODE	SEGMENT
	ORG		100H
	ASSUME		CS:CODE,DS:CODE
BEGIN:	JMP		START
	INT_TIM		LABEL	DWORD
	IP_TIM		DW	?
	CS_TIM		DW	?
	TIK		DB	?
	NCH		DB	0
PROCESS:					; НАЧАЛО РЕЗИДЕНТНОЙ ЧАСТИ
	CLI				; Запрещение прерываний
	INC		TIK		; Увеличение счетчика тиков
	CMP		TIK,10		; Сравнение его с 10:
	JL		A1		; если меньше, то конец прерывания
	PUSH		ES		; Сохранение регистров в стеке
	PUSH		AX
	MOV		AX,0B800H		; Вывод символа по номеру NCH
	MOV		ES,AX		; прямой записью в видеопамять
	XOR		AL,AL
	MOV		TIK,AL
	INC		NCH
	MOV		AL,NCH
	MOV		ES:[0],AL
	MOV		AL.1EH
	MOV		ES:[1],AL
	POP		AX		; Восстановление регистров
	POP		ES
A1:	STI				; Разрешение прерываний
	PUSH		AX
	MOV		AX,20H		; Сигнал о конце прерывания
	OUT		AX,20H
	POP		AX
	IRET				; Возврат управления

START:					; НАЧАЛО ВСПОМОГАТЕЛЬНОЙ ЧАСТИ
	MOV		AX,351CH		; Сохранение вектора 1CH
	INT		21H
	MOV		IP_TIM,BX
	MOV		CS_TIM,ES
	MOV		AX,251CH		; Установка вектора 1CH
	LEA		DX,PROCESS	; по адресу метки PROCESS
	INT		21H
	MOV		AL,0		; Установка начального
	MOV		TIK,AL		; значения переменной TIK
	LEA		DX,START		; Установка адреса конца
	INT		27H		; резидентной части и KEEP
CODE	ENDS
	END		BEGIN
