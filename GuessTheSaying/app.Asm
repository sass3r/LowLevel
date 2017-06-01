format PE GUI 4.0
entry MyEntry

include 'Win32a.inc'

ventana_1       equ     1
play            equ     1001
probar_char     equ     1003
adivinar        equ     1006

section '.data' data readable writeable
respuesta       dd      0
cadena          rb      30
refran          db      'al que madruga dios le ayuda',0
entrada         rb      10
Ist             dd      0
pWnd            dd      0

section '.code' code readable executable

MyEntry:
	invoke GetModuleHandle,HWND_DESKTOP
	mov [Ist],eax
	invoke DialogBoxParam,eax,ventana_1,0,DlgProc,0 
ExitApp:
	invoke ExitProcess,0

proc DlgProc,hWnd,uMsg,wParam,lParam
	push edi esi ebx
	
	mov eax,[uMsg]
	cmp	eax,WM_COMMAND
	je	jCOMMAND
	cmp	eax,WM_INITDIALOG
	je	jINITDIALOG
	cmp	eax,WM_CLOSE
	je	jCLOSE
	xor eax,eax
	jmp finish

jINITDIALOG:
	mov eax,[hWnd]
	mov [pWnd],eax
	mov eax,1
	jmp finish
	
jCOMMAND:
	mov eax,[wParam]
	cmp	eax,1000
	je	a1000
	cmp eax,play
	je  init_game
	cmp eax,probar_char
	je  action_char
	cmp eax,adivinar
	je  action_adivinar    
	xor eax,eax
	jmp finish
	
a1000:
	invoke SendMessage,[hWnd],WM_CLOSE,0,0
	mov eax,1
	jmp finish

init_game:
	stdcall iniciar_juego
	mov eax,1
	jmp finish
	
action_char:
	stdcall comparaChar
	mov eax,1
	jmp finish

action_adivinar:
	stdcall adivinar_refran
	mov eax,1
	jmp finish
		
jCLOSE:	
	invoke EndDialog,[hWnd],0
	mov eax,1
	
finish:
	pop ebx esi edi
	ret
endp

proc iniciar_juego
	mov esi,cadena
	invoke lstrlen,refran
	mov ecx,eax
	mov al,'-'
ciclo:
	mov [esi],al
	inc esi
	loop ciclo
	inc esi
	mov al,0
	mov [esi],al
	invoke SetDlgItemText,[pWnd],1002,cadena
	ret
endp

proc comparaChar
	invoke GetDlgItemText,[pWnd],1004,entrada,10
	mov ebx,entrada
	mov esi,refran
	mov edi,cadena
	invoke lstrlen,refran
	mov ecx,eax
bucle:
		mov ah,[esi]
		mov al,[ebx]
		cmp ah,al
		jne continuar
		mov [edi],ah
	continuar:
		inc esi
		inc edi
		loop bucle
		
	invoke SetDlgItemText,[pWnd],1002,cadena
	ret
endp

proc adivinar_refran
	invoke GetDlgItemText,[pWnd],1005,respuesta,255
	mov esi,respuesta
	mov edi,refran
	invoke lstrlen,refran
	mov ecx,eax
comparar:
	mov al,[esi]
	mov bl,[edi]
	mov ah,0
	cmp al,bl
	jne _continuar
	mov ah,1
	inc esi
	inc edi
	loop comparar
_continuar:
	and ah, 1
	cmp ah,0
	je _finish
	invoke SetDlgItemText,[pWnd],1002,refran
_finish:
	ret
endp


section '.idata' import data readable writeable
  ;importamos solo los procedimientos basicos para abrir una ventana
  library kernel, 'KERNEL32.DLL',\
	  user,   'USER32.DLL',

  import  kernel,\
	  GetModuleHandle,'GetModuleHandleA',\
	  ExitProcess,	  'ExitProcess',\
	  lstrlen,        'lstrlenA'

  import  user,\
	  DialogBoxParam, 'DialogBoxParamA',\
	  EndDialog,	  'EndDialog',\
	  SendMessage,	  'SendMessageA',\
	  SetDlgItemText, 'SetDlgItemTextA',\
	  GetDlgItemText, 'GetDlgItemTextA'
	  
  ;otra forma para importar los procedimientos importando archivos INC
  ;library kernel32,'KERNEL32.DLL',user32,'USER32.DLL',gdi32,'GDI32.DLL'
  ;include 'api\kernel32.inc'
  ;include 'api\user32.inc'
  ;include 'api\gdi32.inc'

section '.rsrc' resource from 'app.res' data readable
