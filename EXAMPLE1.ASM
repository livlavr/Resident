CODE	SEGMENT				; Начало сегмента кода
	ORG	100H			; Смещение 100H для программы типа COM
	ASSUME	CS:CODE,DS:CODE		; Назначение сегментов
BEGIN:	JMP	START			; Переход на выполнение вспомогательной части
	OLD_VEC	LABEL	DWORD
	IP_OLD	DW	?		; Определение FAR метки
	CS_OLD	DW	?
PRO:					; НАЧАЛО РЕЗИДЕНТНОЙ ЧАСТИ
	PUSHF				; Имитация прерывания
	CALL	CS:OLD_VEC		; Вызов системной обработки
	PUSH	AX			; Сохранение в стеке регистров AX и ES
	PUSH	ES
	MOV	AX,0			; Чтение флагов состояния
	MOV	ES,AX			; клавиатуры в регистр AL и
	MOV	AL,ES:[041 7H]		; определение нажаты ли клавиши
	AND	AL,00001100B		; Ctrl-Alt, если нет, то
	CMP	AL,00001100B		; возврат управления
	JNZ	A1
	PUSH	CX			; Сохранение в стеке регистров
	PUSH	BX			; CX, BX и SI
	PUSH	SI
	MOV	AX,0B800H			; Адрес видеопамяти в ES
	MOV	ES,AX
	MOV	SI,1			; Подготовка к инверсии яркости
	MOV	CX,2000
CYC:	MOV	AL,ES:[SI]		; Чтение байта видеопамяти
	XOR	AL,00001000B		; Инверсия яркости (3-й бит)
	MOV	ES:[SI],AL		; Запись байта на место
	INC	SI			; Увеличение смещения на 2
	INC	SI
	LOOP	CYC			; Если не конец экрана, то продолжить инверсию
	POP	SI			; Восстановление регистров,
	POP	BX			; испорченных во время
	POP	CX			; работы резидентной части
A1:	POP	ES
	POP	AX
	IRET				; Возврат управления
START:					; НАЧАЛО ВСПОМОГАТЕЛЬНОЙ ЧАСТИ
	MOV	AX,3509H			; Чтение вектора 09H
	INT	21H
	MOV	IP_OLD,BX			; Запись вектора 09H в метку
	MOV	CS_OLD,ES
	MOV	AX,2509H			; Установка вектора 09H на адрес
	LEA	DX,PRO			; резидентной процедуры PRO
	INT	21H
	LEA	DX,START			; Адрес конца резидентной части
	INT	27H			; KEEP
CODE	ENDS				; Конец сегмента кода
	END	BEGIN			; Конец программы

Hosted by uCoz
