CODE	SEGMENT
	ORG		100H
	ASSUME		CS:CODE,DS:CODE
BEGIN:	JMP		START
	OLD_VIDEO	LABEL	DWORD
	IP_OLD		DW	?
	CS_OLD		DW	?
PRO:					; НАЧАЛО РЕЗИДЕНТНОЙ ЧАСТИ
	CMP		AH,09H		; Проверка, 9-я ли это функция:
	JZ		A1		; если да, то пользовательская обработка
	CMP		AH,0AH		; Проверка, 10-я ли это функция:
	JZ		A1		; если да, то пользовательская обработка;
	JMP		CS:OLD_VIDEO	; если нет, то системная обработка
A1:
	CMP		AL,32		; Сравнить выводимый символ с пробелом
	JZ		A2
	MOV		BL,0FH		; если пробел, то красный фон;
	JMP		A3
A2:	MOV		BL,4FH		; если не пробел, то черный фон
A3:	MOV		AH,09H		; Функция 09H
	JMP		CS:OLD_VIDEO	; Системная обработка

START:					; НАЧАЛО ВСПОМОГАТЕЛЬНОЙ ЧАСТИ
	MOV		AX,3510H		; Чтение вектора 10H
	INT		21H
	MOV		IP_OLD,BX		; Запись вектора 10H в метку
	MOV		CS_OLD,ES
	MOV		AX,2510H		; Установка вектора 10H на адрес
	LEA		DX,PRO		; резидентной процедуры PRO
	INT		21H
	LEA		DX,START		; Адрес конца резидентной части
	INT		27H		; KEEP
CODE	ENDS				; Конец сегмента кода
	END		BEGIN		; Конец программы

Hosted by uCoz
