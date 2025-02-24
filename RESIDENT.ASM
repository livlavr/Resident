.model tiny
.186
locals
.code
org 100h
;--------------------------------------------------------------------------|
main:
	
	mov al, 0b6h
	out 43h, al
	mov al, 0d0h
	out 42h, al
	mov al, 11h
	out 42h, al

	in al, 61h
	or al, 03h
	out 61h, al

	mov cx, 00007h
	mov dx, 0a120h	
	mov ah, 86h
	int 15h
	
	in al, 61h
	and al, 0fch
	out 61h, al
	
	ret
	
end	main