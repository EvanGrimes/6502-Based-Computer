

PORTB = $6000

PORTA = $6001

DDRB = $6002

DDRA = $6003
PCR = $600c
IFR = $600d
IER = $600e

E  = %01000000
RW = %00100000
RS = %00010000

HunThousands = $00
TenThousands = $01
Thousands = $02
Hundreds = $03
Tens = $04
Ones = $05

  .org $8000

reset:
  ;Init Stack
  ldx #$ff
  txs
  ;Init Interupts and Assoc. Regs
  lda #$01
  sta PCR
  lda #$82
  sta IER
  cli

  ;Set up Ports
  lda #%11111111 ; Set all pins on port B to output
  sta DDRB
  lda #%00000000 ; Set all pins on port A to input
  sta DDRA
  ;Clear all vars and Ports
  sta PORTB
  sta PORTB
  sta Ones
  sta Tens
  sta Hundreds
  sta Thousands
  sta TenThousands
  sta HunThousands
  
  ;Init LCD
  jsr lcd_init
  lda #%00101000 ; Set 4-bit mode; 2-line display;         5x8 font
  jsr lcd_instruction
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor;     don't shift display
  jsr lcd_instruction
  lda #%00000001 ; Clear display
  jsr lcd_instruction


Loop:
    lda #%00000010    ; Return to start of Line One
    jsr lcd_instruction
    

PHunThous:
    clc             
    lda HunThousands     ; Load Hundred Thousands Place
    BEQ PTenThous        ; Skip printing hundred thousands if zero
    adc #$30          ; Make it ascii
    cmp #$3A          ; Check if >9
    BEQ ZeroHunThousands ; Increment Hundred Thousands place if so
    jsr PrintLCDChar     ; Print digit

PTenThous:
    clc
    BNE PrintTenThous       ;If hundred thousands is zero, cif not, print Ten Thousands
          
    lda TenThousands     ; Load Thousands Place
    BEQ PThous           ; If Ten Thousands is zero, jump to thousands 
PrintTenThous:
    lda TenThousands
    adc #$30          ; Make it ascii
    cmp #$3A          ; Check if >9
    BEQ IncHunThousands ; Increment Hundred Thousands place if so
    jsr PrintLCDChar

PThous:
    clc         
    BNQ PrintThous   ; If Ten Thousands is not zero, print Thousands no matter what

    lda Thousands     ; Load Thousands Place
    BEQ PHun          ; If Thousands is zero, skip printing
PrintThous:
    lda Thousands
    adc #$30          ; Make it ascii
    cmp #$3A          ; Check if >9
    BEQ IncTenThousands ; Increment Ten Thousands if so
    jsr PrintLCDChar

PHun:
    clc
    BNE PrintHun    ; If Thousands is not zero, print Hundreds no matter what

    lda Hundreds
    BEQ PTen       ; If Hundreds is zero, skip printing
PrintHun:
    lda Hundreds
    adc #$30     ; Make into ASCII char
    cmp #$3A     ; Check if >9
    BEQ IncThousands   ; Increment Thousands place if so
    jsr PrintLCDChar ; Print Char

PTen:
    clc
    BNE PrintTen  ; If Hundreds is above zero, print tens unconditionaly

    lda Tens 
    BEQ POne      ; If tens is zero, skip printing
PrintTen:
    lda Tens
    adc #$30     ; Make into ASCII char
    cmp #$3A
    BEQ IncHundred   ; Increment Hundreds place if so
    jsr PrintLCDChar ; Print Char
POne:
    clc
    lda Ones
   
    adc #$30     ; Make into ASCII char
    cmp #$3A     ; Check if >9
    BEQ IncTen   ; Increment tens place if so
    jsr PrintLCDChar ; Print Char

    inc Ones     ; Increment ones

    jmp Loop


ZeroHunThousands:
    lda #$00
    sta Tens
    sta Ones
    sta Hundreds
    sta Thousands
    sta TenThousands
    sta HunThousands
    jmp Loop

IncHunThousands:
    inc HunThousands
    lda #$00
    sta Tens
    sta Ones
    sta Hundreds
    sta Thousands
    sta TenThousands
    jmp Loop

IncTenThousands:
    inc TenThousands
    lda #$00
    sta Tens
    sta Ones
    sta Hundreds
    sta Thousands
    jmp Loop

IncThousands:
    inc Thousands
    lda #$00
    sta Tens
    sta Ones
    sta Hundreds
    jmp Loop
    
IncHundred:
    inc Hundreds
    lda #$00
    sta Tens
    sta Ones
    jmp Loop

IncTen:
    inc Tens
    lda #$00
    sta Ones
    jmp Loop

    .include "LCDLib.asm"  ; All LCD Functions

irq:    
   pha
   lda IFR
   ;Do something to poll the interrupts
   lda PORTA
   lda PORTB  ; Clear all possible User Controlled Interrupts
   pla
   rti


nmi:
  rti

; Reset/IRQ vectors
  .org $fffa
  .word nmi
  .word reset
  .word irq