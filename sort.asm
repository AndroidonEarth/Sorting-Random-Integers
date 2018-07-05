TITLE Sorting Random Integers     (sort.asm)

; Author: Andrew Swaim
; Date: 3/4/2018
; Description: A program to generate random numbers in the range [100 .. 999]. The program then
;	displays the original list, sorts the list, and calculates the median value. Finally, it
;	displays the new sorted list in decending order. The program is constructed using procedures
;	and parameters are passed by value or by reference on the system stack.

INCLUDE Irvine32.inc

;Global Constants.
MIN = 10
MAX	= 200
LO  = 100
HI  = 999

.data
;Global strings.
program			BYTE	"Sorting Random Integers      Programmed by Andrew Swaim",0
rules1			BYTE	"This program generates random numbers in the range [100 .. 999],",0
rules2			BYTE	"Displays the original list, sorts the list, and calculates the",0
rules3			BYTE	"median value.  Finally, it displays the list sorted in descending order.",0
prompt			BYTE	"How many numbers should be generated? [10 .. 200]: ",0
error			BYTE	"Invalid input",0
medResult1		BYTE	"The median is ",0
medResult2		BYTE	".",0
space			BYTE	"   ",0

;Strings to be passed by reference.
unsortTitle		BYTE	"The unsorted random numbers:",0
sortTitle		BYTE	"The sorted list:",0

;Program variables.
request			DWORD	?
array			DWORD	MAX DUP(?)

.code
main PROC

	;Setup random seed and print program introduction.
	call	Randomize
	call	introduction

	;call getData {parameters: request (value)}
	push	OFFSET request
	call	getData

	;call fillArray {parameters: array (reference), request (value)}
	push	OFFSET array
	push	request
	call	fillArray

	;call displayList {parameters: array (reference), request (value), title (reference)}
	push	OFFSET array
	push	request
	push	OFFSET unsortTitle
	call	displayList

	;call sortList {parameters: array (reference), request (value)}
	push	OFFSET array
	push	request
	call	sortList

	;call displayMedian {parameters: array (reference), request (value)}
	push	OFFSET array
	push	request
	call	displayMedian
	
	;call displayList {parameters: array (reference), request (value), title (reference)}
	push	OFFSET array
	push	request
	push	OFFSET sortTitle
	call	displayList

	exit	; exit to operating system
main ENDP

;------------------------------------------------------------------------------
introduction PROC
; Displays an the introduction to the program.
; Receives: none
; Returns: none
; Preconditions: none
; Postconditions: Prints program name and author name, indication of extra credit,
;	and user instructions to the console.
; Registers changed: edx
;------------------------------------------------------------------------------

	;Display program and author name.
		mov		edx,OFFSET program
		call	WriteString
		call	Crlf

	;User instructions.
		mov		edx,OFFSET rules1
		call	WriteString
		call	Crlf
		mov		edx,OFFSET rules2
		call	WriteString
		call	Crlf
		mov		edx,OFFSET rules3
		call	WriteString
		call	Crlf
		call	Crlf
		ret

introduction ENDP


;------------------------------------------------------------------------------
getData PROC
; Prompts the user to enter a number between [10 .. 200], and then validates the
;	user input. If validation fails, continues to prompt the user again until
;	a valid input is entered.
; Receives: request (reference)
; Returns: none
; Preconditions: none
; Postconditions: prints prompt to console, gets and validates user input.
; Registers changed: edx, eax, ebx
;------------------------------------------------------------------------------

	;Setup stack frame.
		push	ebp
		mov		ebp,esp
		mov		ebx,[ebp+8]		;address of request
	;Prompt for, get, and validate request.
	getInput:
		mov		edx,OFFSET prompt
		call	WriteString
		call	ReadInt
	;Validate number is >= 10 (MIN).
		cmp		eax,MIN
		jl		errorMessage
	;Validate number is <= 200 (MAX).
		cmp		eax,MAX
		jg		errorMessage
	;If validation passed, store number in request variable.
		mov		[ebx],eax
		pop		ebp
		ret		4

	errorMessage:
	;Display error message and prompt again.
		mov		edx,OFFSET error
		call	WriteString
		call	Crlf
		jmp		getInput

getData ENDP


;------------------------------------------------------------------------------
fillArray PROC
; Uses RandomRange to step through the array and fill it with random integers
;	in the range [100 .. 999].
; Receives: array (reference), request (value)
; Returns: none
; Preconditions: none
; Postconditions: array is filled with random values.
; Registers changed: edi, eax, ecx
;------------------------------------------------------------------------------

	;Setup stack frame.
		push	ebp
		mov		ebp,esp
		mov		ecx,[ebp+8]		;request
		mov		edi,[ebp+12]	;address of array

	;Fill the array with random numbers.
	getRandomInt:
		mov		eax,HI
		sub		eax,LO
		inc		eax
		call	RandomRange
		add		eax,LO
		mov		[edi],eax
		add		edi,4
		loop	getRandomInt

		pop		ebp
		ret		8

fillArray ENDP


;------------------------------------------------------------------------------
sortList PROC
	LOCAL i:DWORD, k:DWORD, j:DWORD
; Utilizes the selection sort algorithm from the assignment description to sort
;	the array in descending order. Calls the exchange procedure to swap two 
;	values in the array when sorting.
; Receives: array (reference), request (value)
; Returns: none
; Preconditions: none
; Postconditions: values are sorted in array in descending order.
; Registers changed: eax, ebx, ecx, esi
;------------------------------------------------------------------------------

	;**Stack frame already set up by LOCAL directive.

	;Outerloop conditions (k = 0; k < request - 1).
		mov		k,0				;k = 0
	outerLoop1:
		mov		eax,k
		mov		i,eax			;i = k
;------------------------------------------------------------------------------
	;Innerloop conditions (j = k + 1; j < request).
		mov		eax,k
		mov		j,eax
		inc		j				;j = k + 1
	innerLoop:
	;Get array[j] into edi.
		mov		esi,[ebp+12]	;address of array
		mov		eax,j
		mov		ebx,4
		mul		ebx
		add		esi,eax			;esi+index*4 = array[index]
		mov		edi,[esi]		;dereference and store in edi
	;Compare to array[i].
		mov		esi,[ebp+12]	
		mov		eax,i
		mov		ebx,4
		mul		ebx
		add		esi,eax
		cmp		edi,[esi]		;dereference and compare to edi
		jbe		notGreater
	;If array[j] > array[i], store the greater index for swapping.
		mov		eax,j
		mov		i,eax			;i = j
	notGreater:
	;Continue inner loop.
		inc		j				;j++
		mov		ecx,[ebp+8]		;while j < request
		cmp		ecx,j
		ja		innerLoop
;------------------------------------------------------------------------------
	outerloop2:
	;Push the address of array[k]
		mov		esi,[ebp+12]
		mov		eax,k
		mov		ebx,4
		mul		ebx
		add		esi,eax
		push	esi
	;Push the address of array[i]
		mov		esi,[ebp+12]
		mov		eax,i
		mov		ebx,4
		mul		ebx
		add		esi,eax
		push	esi
	;Swap the values at array[k] and array[i]
		call	exchange
		inc		k				;k++
		mov		ecx,[ebp+8]
		dec		ecx				;while k < request - 1
		cmp		ecx,k
		ja		outerLoop1
;------------------------------------------------------------------------------
	;Return.
		ret		8

sortList ENDP


;------------------------------------------------------------------------------
exchange PROC
; Swaps two values in an array using their respective memory locations.
; Receives: array[k] (reference), array[i] (reference)
; Returns: none
; Preconditions: none
; Postconditions: the values in the address of array[k] and array[i] are swapped.
; Registers changed: eax, esi, edi
;------------------------------------------------------------------------------

	;Setup stack frame.
		push	ebp
		mov		ebp,esp
	;Get addresses of array[k] and array[i]
		mov		esi,[ebp+8]
		mov		edi,[ebp+12]
	;Get first integer.
		mov		eax,[esi]
	;Exchange with second.
		xchg	eax,[edi]
	;Replace with first
		mov		[esi],eax
	;Return.
		pop		ebp
		ret		8

exchange ENDP


;------------------------------------------------------------------------------
displayMedian PROC
; Calculates and displays the median of the array. If the array has an odd number
;	of integers, gets the value at the middle index and displays it. If the array
;	has an even number of integers, gets the values of the two middle indexes and
;	adds them together, divides by 2, and then checks the remainder and rounds up
;	if neccessary.
; Receives: array (reference), request (value)
; Returns: none
; Preconditions: none
; Postconditions: median value is printed to the console.
; Registers changed: eax, ebx, edx, esi
;------------------------------------------------------------------------------

	;Setup stack frame.
		push	ebp
		mov		ebp,esp
		mov		esi,[ebp+12]	;address of array

	;Print title.
		mov		edx,OFFSET medResult1
		call	WriteString

	;Calculate median
		mov		eax,[ebp+8]		;value of request
		mov		ebx,2
		mov		edx,0
		cdq
		div		ebx
	;Check if even number integers.
		cmp		edx,0
		je		evenNum

	;Odd number of integers.
		mov		ebx,4
		mul		ebx
		add		esi,eax
		mov		eax,[esi]
		jmp		printMed

	;Even number of integers.
	evenNum:
	;Get upper-middle number
		mov		ebx,4
		mul		ebx
		add		esi,eax
		mov		ebx,[esi]
	;Get lower-middle number
		mov		eax,4
		sub		esi,eax
		mov		eax,[esi]
	;Add together and divide by 2.
		add		eax,ebx
		mov		ebx,2
		mov		edx,0
		cdq
		div		ebx
	;Determine if rounding is needed.
		cmp		edx,0
		je		printMed
		inc		eax

	printMed:
		call	WriteDec
		mov		edx,OFFSET medResult2
		call	WriteString
		call	Crlf

		pop		ebp
		ret		8


displayMedian ENDP


;------------------------------------------------------------------------------
displayList PROC
; Prints the title passed to the procedure, then steps through the array and
;	prints each value separated by three spaces, and after ten values are
;	printed detects this and prints a new line instead.
; Receives: array (reference), request (value), title (reference)
; Returns: none
; Preconditions: none
; Postconditions: array is printed to the console, ten values per line each
;	separated by three spaces.
; Registers changed: eax, ebx, ecx, edx, esi
;------------------------------------------------------------------------------

	;Setup stack frame.
		push	ebp
		mov		ebp,esp
	
	;Print title.
		call	Crlf
		mov		edx,[ebp+8]		;Address of title.
		call	WriteString
		call	Crlf
		mov		edx,OFFSET space
	
	;Setup array and new line accumulator.
		mov		ecx,[ebp+12]	;request
		mov		esi,[ebp+16]	;address of array
		mov		ebx,0			;New line accumulator.

	printArray:
	;Write the first/next element of the array.
		mov		eax,[esi]
		call	WriteDec
		inc		ebx
	;Check if new line needs to be printed.
		cmp		ebx,10
		je		newline
	;Otherwise print three spaces.
		call	WriteString

	continue:
		add		esi,4
		loop	printArray

	;Return.
		call	Crlf
		pop		ebp
		ret		12

	newline:
	;Print a new line and reset accumulator.
		call	Crlf
		mov		ebx,0
		jmp		continue

displayList ENDP

END main
