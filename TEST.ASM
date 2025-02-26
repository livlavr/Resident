.model tiny
.186
.code
org 100h
locals
;-------------------------------------------------------------------|
MyTest:
	mov ax, 1111h
	mov bx, 2222h
	mov cx, 3333h
	mov dx, 4444h
	in al, 60h
	cmp al, 1h
	jne MyTest

	ret
;-------------------------------------------------------------------|
end	MyTest