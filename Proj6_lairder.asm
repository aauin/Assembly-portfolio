TITLE String Primitives and Macros     (Proj6_lairder.asm)

; Author: Erwin Laird
; Last Modified: Mar 19, 2023
; OSU email address: lairder@oregonstate.edu
; Course number/section:   CS271 Section 402
; Project Number: 6                Due Date: Mar 19, 2023
; Description: This program reinforces concepts in string primitive instructions
;              and macros. It implements two macros that gets string inputs from
;              the user and displays them while checking that the values after 
;              being converted into int are within range. It collects 10 signed
;              decimals, calculates their sum and truncated average, and displays
;              all of that to console.

INCLUDE Irvine32.inc


; ---------------------- M A C R O S -------------------------


; ------------------------------------------------------------
; Name: mGetString
;
; Displays a prompt then get the user's keyboard input as string.
;
; Preconditions: Should not use EDX, ECX, EAX for byteCount.
;
; Receives: prompt = BYTE array address
;			buffer = BYTE array address
;			byteCount = SDWORD value
;			(uses BUFFER_SIZE = constant value)
;
; Returns: buffer = contains address of str user input
;		   byteCount = length of string in buffer
; ------------------------------------------------------------
mGetString MACRO prompt:REQ, buffer:REQ, byteCount:REQ
  PUSH	EDX
  PUSH	ECX
  PUSH	EAX

  MOV	EDX,  prompt
  CALL	WriteString
  MOV	EDX,  buffer		; address to put str input
  MOV	ECX,  BUFFER_SIZE
  CALL	ReadString
  MOV	byteCount,  EAX

  POP	EAX
  POP	ECX
  POP	EDX
ENDM


; ------------------------------------------------------------
; Name: mDisplayString
;
; Prints the string passed by reference.
;
; Preconditions: None
;
; Receives: strVal = BYTE array address
;
; Returns: Prints string to console.
mDisplayString MACRO strVal:REQ
  PUSH	EDX
  PUSH	EAX

  MOV	EDX,  strVal
  CALL	WriteString

  POP	EAX
  POP	EDX
ENDM



; -------------------- C O N S T A N T S ---------------------

BUFFER_SIZE		=	200
LO				=	-2147483648
HI				=	2147483647



; ------------------- V A R I A B L E S ----------------------

.data
  intro			BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 13, 10,
						"Written by: Erwin Laird", 13, 10, 13, 10, 0
  instruction	BYTE	"Please provide 10 signed decimal integers.", 13, 10,
						"Each nnumber needs to be small enough to fit inside a 32-bit register.", 13, 10,
						"After you have finished inputting the raw numbers, I'll display a list of", 13, 10,
						"the integers, their sum, and their average value.", 13, 10, 13, 10, 0
  enterNum		BYTE	"Please enter a signed number: ", 0
  reenterNum	BYTE	"ERROR: You did not enter a signed number or your number was too big.", 13, 10,
						"Please try again: ", 0
  arrLabel		BYTE	13, 10, "You entered the following numbers:", 13, 10, 0
  sumLabel		BYTE	13, 10, "The sum of these numbers is: ", 0
  comma			BYTE	", ", 0
  avgLabel		BYTE	13, 10, "The trucated average is: ", 0
  outro			BYTE	13, 10, 13, 10, "Thanks for playing and have a good life!", 13, 10, 0
  strInput		BYTE	200 DUP(?)
  clrArr		BYTE	200 DUP(?)
  intInput		SDWORD	0
  arrSum		SDWORD	0
  arrAvg		SDWORD	?
  inputSize		DWORD	?
  inputSign		DWORD	0			; 0 means positive, 1 means negative
  zeroFound		DWORD	0			; 0 means zero not found, 1 means found
  nonZeroFound	DWORD	0			; 0 means non-zero number not found, 1 means found
  numArr		SDWORD	10 DUP(?)
  strBuffer		BYTE	12 DUP(?)	; Array buffer for int to string conversion
  reversedStr	BYTE	12 DUP(?)	; Array for reversed string in strBuffer




  ; -------------- M A I N   P R O C E D U R E -----------------

.code
main PROC

  ; Displays intro and instruction
  mDisplayString OFFSET intro
  mDisplayString OFFSET instruction

  ; ------------------------------------------------------------
  ; The following loop asks the user to enter a signed number
  ; ten times and stores them in an array. It uses the procedure
  ; ReadVal to read the string input from the user, validates it,
  ; and converts it into a signed int before populating the array.
  ; ------------------------------------------------------------

  MOV	ECX,  10
  MOV	EDI,  OFFSET numArr

_fillArrLoop:
  PUSH	OFFSET clrArr
  PUSH	zeroFound
  PUSH	nonZeroFound
  PUSH	OFFSET enterNum
  PUSH	OFFSET reenterNum
  PUSH	OFFSET strInput
  PUSH	intInput
  PUSH	inputSize
  PUSH	inputSign
  CALL	ReadVal			; Receives int value in ESI

  MOV	[EDI],  ESI
  ADD	EDI,  4
  MOV	inputSign,  0
  MOV	inputSize,  0

  ; Clears strInput array
  PUSHAD
  MOV	ESI,  OFFSET clrArr
  MOV	EDI,  OFFSET strInput
  MOV	ECX,  LENGTHOF strInput
  REP	MOVSB
  POPAD

  LOOP	_fillArrLoop


  ; ------------------------------------------------------------
  ; The following loop prints the 10 signed numbers collected
  ; from the user in the loop above. It uses the procedure WriteVal
  ; to convert the int back into a string (array of bytes).
  ; ------------------------------------------------------------

  ; Prints arrLabel
  mDisplayString OFFSET arrLabel

  MOV	ECX,  10
  MOV	EDI,  OFFSET numArr

_printArrLoop:
  ; Checks if int is negative
  MOV	EAX,  [EDI]
  CMP	EAX,  0
  JGE	_continue

  ; Int is negative, so reverse Two's Complement
  NEG	EAX
  MOV	[EDI],  EAX
  MOV	inputSign, 1
  NEG	EAX

_continue:
  PUSH	OFFSET reversedStr
  PUSH	inputSign
  PUSH	OFFSET strBuffer
  PUSH	[EDI]
  CALL	WriteVal		; Prints value to console
  MOV	[EDI],  EAX		; Restores original signed value

  ; Adds comma except after the last value
  CMP	ECX,  1
  JE	_skipComma
  mDisplayString OFFSET comma

_skipComma:
  ADD	EDI,  4
  MOV	inputSign,  0

  ; Clears reversedStr array
  PUSHAD
  MOV	ESI,  OFFSET clrArr
  MOV	EDI,  OFFSET reversedStr
  MOV	ECX,  LENGTHOF reversedStr
  REP	MOVSB

  ; Clears strBuffer array
  MOV	ESI,  OFFSET clrArr
  MOV	EDI,  OFFSET strBuffer
  MOV	ECX,  LENGTHOF strBuffer
  REP	MOVSB
  POPAD

  LOOP	_printArrLoop


  ; ------------------------------------------------------------
  ; The following calculates the sum and uses the procedure 
  ; WriteVal to display the result to console.
  ; ------------------------------------------------------------

  CLD
  MOV	ECX,  10
  MOV	ESI,  OFFSET numArr

_sumLoop:
  LODSD
  ADD	arrSum,  EAX
  LOOP	_sumLoop
  MOV	EAX,  arrSum	; Places sum into EAX

  ; Prints sumLabel
  mDisplayString OFFSET sumLabel
  
  ; Checks if sign is negative
  CMP	arrSum,  0
  JGE	_skip2Complement
  MOV	EAX,  arrSum
  NEG	EAX
  MOV	arrSum, EAX
  MOV	inputSign,  1

_skip2Complement:
  PUSH	OFFSET reversedStr
  PUSH	inputSign
  PUSH	OFFSET strBuffer
  PUSH	EAX
  CALL	WriteVal		; Prints value to console


  ; Clears reversedStr array
  PUSHAD
  MOV	ESI,  OFFSET clrArr
  MOV	EDI,  OFFSET reversedStr
  MOV	ECX,  LENGTHOF reversedStr
  REP	MOVSB

  ; Clears strBuffer array
  MOV	ESI,  OFFSET clrArr
  MOV	EDI,  OFFSET strBuffer
  MOV	ECX,  LENGTHOF strBuffer
  REP	MOVSB
  POPAD


  ; ------------------------------------------------------------
  ; The following calculates the average of all the numbers in
  ; the array and uses the procedure WriteVal to print the
  ; result to console.
  ; ------------------------------------------------------------

  ; Prints avgLabel
  mDisplayString OFFSET avgLabel

  MOV	EAX,  arrSum
  MOV	EBX,  10
  MOV	EDX,  0
  IDIV	EBX
  MOV	arrAvg,  EAX

  ; Check if sign is negative
  CMP	arrAvg,  0
  JGE	_skipNegation
  MOV	EAX,  arrSum
  NEG	EAX
  MOV	arrSum, EAX
  MOV	inputSign,  1

_skipNegation:
  PUSH	OFFSET reversedStr
  PUSH	inputSign
  PUSH	OFFSET strBuffer
  PUSH	arrAvg
  CALL	WriteVal		; Prints value to console


  ; Prints the outro of the program
  mDisplayString OFFSET outro

  Invoke ExitProcess, 0	; exit to operating system
main ENDP



; ------------ O T H E R   P R O C E D U R E S ---------------


; ------------------------------------------------------------
; Name: ReadVal
;
; Invokes the mGetString macro to get a signed number in string
; form then converts it into int while validating. This procedure
; will keep asking the user until they enter a valid data, then
; pass this valid data. (It only gets a valid data once.)
;
; Preconditions: clrArr and strInput should be empty arrays.
;				 zeroFound, nonZeroFound, intInput, and
;                inputSign should all be clear.
;
; Postconditions: None
;
; Receives: [EBP+40] = clrArr reference
;			[EBP+36] = zeroFound value (0)
;			[EBP+32] = nonZeroFound value (0)
;			[EBP+28] = prompt reference
;			[EBP+24] = reenter prompt reference
;			[EBP+20] = strInput reference
;			[EBP+16] = intInput value (0)
;			[EBP+12] = inputSize value
;			 [EBP+8] = inputSign value (0)
;
; Returns: Returns converted int value in ESI
; ------------------------------------------------------------
ReadVal PROC
  PUSH	EBP
  MOV	EBP,  ESP

  ; Saves registers
  PUSH	ECX
  PUSH	EDI

  MOV	EDX,  [EBP+28]		; prompt
  MOV	EAX,  [EBP+20]		; strInput
  MOV	EDI,  [EBP+16]		; intInput
  MOV	EBX,  [EBP+12]		; inputSize 

_getString:
  mGetString  EDX, EAX, EBX	; EAX = input,  EBX = input size

  CLD
  MOV	[EBP+12],  EBX
  MOV	ECX,  EBX
  MOV	ESI,  [EBP+20]

_convertLoop:
  MOV	EAX,  0
  LODSB
  CMP	AL,  43				; (+)
  JE	_validateSign
  CMP	AL,  45				; (-)
  JE	_validateSign
  CMP	AL,  48				; not a number
  JB	_errorReenter
  CMP	AL,  57				; not a number
  JA	_errorReenter

  ; Checks for leading zeros
  CMP	AL,  48				; 0
  JNE	_updateIntInput
  MOV	EBX,  1		
  MOV	[EBP+34], EBX       ; zeroFound
  MOV	EBX,  [EBP+32]		; nonZeroFound
  CMP	EBX,  0
  JE	_continueLoop
  JMP	_updateIntInput

_validateSign:
  CMP	[EBP+12],  ECX
  JNE	_errorReenter
  CMP	AL,  43
  JE	_continueLoop

_setNegative:
  MOV	EBX,  1
  MOV	[EBP+8],  EBX
  JMP	_continueLoop

_errorReenter:
  MOV	EDX,  [EBP+24]
  MOV	EBX,  0
  MOV	[EBP+8],  EBX		; reset inputSign to 0 (positive)
  MOV	[EBP+32], EBX		; reset nonZeroFound to 0 (not found)
  MOV	EDI,  0

  ; Clears strInput array
  PUSHAD
  MOV	ESI,  [EBP+40]
  MOV	EDI,  [EBP+20]
  MOV	ECX,  200
  REP	MOVSB
  POPAD

  MOV	EAX,  [EBP+20]
  JMP _getString

_updateIntInput:
  ; Sets nonZeroFound
  MOV	EBX,  1
  MOV	[EBP+32],  EBX

  ; If ECX > 11 at any point, input too big
  CMP	ECX,  11
  JA	_errorReenter

  SUB	AL,  48

  PUSH	EAX
  MOV	EAX,  10
  MUL	EDI
  MOV	EDI,  EAX
  POP	EAX

  ADD	EDI,  EAX			; AL is already in EAX

_continueLoop:
  DEC	ECX
  JNZ _convertLoop

  ; Checks if non-zero num is found
  MOV	EBX,  [EBP+32]
  CMP	EBX,  1
  JE	_checkSign

  ; Non-zero not found, checks if zero is found
  MOV	EBX,  [EBP+34]
  CMP	EBX,  0
  JE	_errorReenter

  ; Non-zero not found but zero is found, sets intInput to 0
  MOV	EDI,  0



_checkSign:
  ; Checks the signed num is within range
  MOV	EAX,  [EBP+8]
  CMP	EAX,  0
  JE	_isPositive
  NEG	EDI

_isPositive:
  CMP	EDI,  HI
  JG	_errorReenter
  CMP	EDI,  LO
  JL	_errorReenter

  MOV ESI,  EDI

  ; Restores registers
  POP	EDI
  POP	ECX

  POP	EBP
  RET	36
ReadVal ENDP



; ------------------------------------------------------------
; Name: WriteVal
;
; Converts one numeric SDWORD int to a string of ASCII digits,
; then invokes the mDisplayString macro to print to console.
;
; Preconditions: All arrays must be clear, and inputSign and
;				 the int value should be pushed in the stack.
;				 If the int value is negative, its Two's
;                Complement should be undone.
;
; Postconditions: Changes the arrays.
;
; Receives: [EBP+20] = reversedStr array reference
;			[EBP+16] = inputSign value
;			[EBP+12] = buffer array reference
;			 [EBP+8] = the int value to be converted to string
;
; Returns: Displays the passed int value to console.
; ------------------------------------------------------------
WriteVal PROC
  PUSH	EBP
  MOV	EBP,  ESP

  ; Saves registers
  PUSH	EDI
  PUSH	ECX
  PUSH	EAX

  MOV	EDI,  [EBP+12]		; BYTE buffer address
  MOV	EAX,  [EBP+8]		; SDWORD value into EAX

  ; If int is 0, skips divide loop
  CMP	EAX,  0
  JE	_onlyOneZero

  ; int is not zero
  MOV	ECX,  0				; will be the length of string in buffer array
_divideLoop:
  CMP	EAX,  0
  JE	_checkSign
  MOV	EDX,  0
  MOV	EBX,  10
  DIV	EBX
  ADD	EDX,  48
  MOV	[EDI],  EDX
  ADD	EDI,  1
  INC	ECX
  JMP	_divideLoop

_onlyOneZero:
  MOV	ESI,  [EBP+20]
  MOV	BYTE PTR [ESI],  48
  JMP   _invokeMacro

_checkSign:
  MOV	EAX,  [EBP+16]		; inputSign
  CMP	EAX,  0
  JE	_reverseString

  ; Sign is negative, adds - and increments ECX
  MOV	EDX,  45
  MOV	[EDI],  EDX
  INC	ECX

_reverseString:
  ; Sets up loop counter and indices
  MOV	ESI,  [EBP+12]
  ADD	ESI,  ECX
  DEC	ESI
  MOV	EDI,  [EBP+20]

  ; Reverses string
_revLoop:
  STD
  LODSB
  CLD
  STOSB
  LOOP	_revLoop

  ; Invokes macro to print string to console
_invokeMacro:
  MOV	EDI,  [EBP+20]
  mDisplayString EDI

  ; Restores registers
  POP	EAX
  POP	ECX
  POP	EDI

  POP	EBP
  RET	16
WriteVal ENDP


END main
