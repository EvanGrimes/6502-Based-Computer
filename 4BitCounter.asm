

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
  ldx #$ff
  txs

  lda #$01
  sta PCR
  lda #$82
  sta IER
  cli
  lda #%11111111 ; Set all pins on port B to output
  sta DDRB
  lda #%00000000 ; Set all pins on port A to input
  sta DDRA
  sta PORTB
  sta Ones
  sta Tens
  sta Hundreds
  sta Thousands
  sta TenThousands
  sta HunThousands
  

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
    BEQ PTenThous
    adc #$30             ; Make it ascii
    cmp #$3A             ; Check if >9
    BEQ ZeroHunThousands ; Bring var back to Zero
    jsr PrintLCDChar
PTenThous:
    clc
    BEQ GoTenThous
    jmp PrintTenThous
GoTenThous:           
    lda TenThousands     ; Load Ten Thousands Place
    BEQ PThous
PrintTenThous
    lda TenThousands
    adc #$30          ; Make it ascii
    cmp #$3A          ; Check if >9
    BEQ IncHunThousands ; Bring back Zero
    jsr PrintLCDChar
PThous:
    clc         
    BEQ GoThous 
    jmp PrintThous
GoThous:
    lda Thousands     ; Load Thousands Place
    BEQ PHun
PrintThous:
    lda Thousands
    adc #$30          ; Make it ascii
    cmp #$3A          ; Check if >9
    BEQ IncTenThousands ; Bring back Zero
    jsr PrintLCDChar
PHun:
    clc
    BEQ GoHun
    jmp PrintHun
GoHun:
    lda Hundreds
    BEQ PTen
PrintHun:
    lda Hundreds
    adc #$30
    cmp #$3A
    BEQ IncThousands
    jsr PrintLCDChar
PTen:
    clc
    BEQ GoTe
    jmp PrintTen
GoTe:
    lda Tens
    BEQ POne
PrintTen:
    lda Tens
    adc #$30
    cmp #$3A
    BEQ IncHundred
    jsr PrintLCDChar
POne:
    lda Ones
    clc
    adc #$30
    cmp #$3A
    BEQ IncTen
    jsr PrintLCDChar

    inc Ones  

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
    
    
lcd_wait:
  pha
  lda #%11110000  ; LCD data is input
  sta DDRB
lcdbusy:
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB       ; Read high nibble
  pha             ; and put on stack since it has the busy flag
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB       ; Read low nibble
  pla             ; Get high nibble off stack
  and #%00001000
  bne lcdbusy 

  lda #RW
  sta PORTB
  lda #%11111111  ; LCD data is output
  sta DDRB
  pla
  rts

lcd_init:
  lda #%00000010 ; Set 4-bit mode
  sta PORTB
  ora #E
  sta PORTB
  and #%00001111
  sta PORTB
  rts

lcd_instruction:
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr            ; Send high 4 bits
  sta PORTB
  ora #E         ; Set E bit to send instruction
  sta PORTB
  eor #E         ; Clear E bit
  sta PORTB
  pla
  and #%00001111 ; Send low 4 bits
  sta PORTB
  ora #E         ; Set E bit to send instruction
  sta PORTB
  eor #E         ; Clear E bit
  sta PORTB
  rts

PrintLCDChar:
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr             ; Send high 4 bits
  ora #RS         ; Set RS
  sta PORTB
  ora #E          ; Set E bit to send instruction
  sta PORTB
  eor #E          ; Clear E bit
  sta PORTB
  pla
  and #%00001111  ; Send low 4 bits
  ora #RS         ; Set RS
  sta PORTB
  ora #E          ; Set E bit to send instruction
  sta PORTB
  eor #E          ; Clear E bit
  sta PORTB
  rts
  
  
irq:
   rti


nmi:
  rti

; Reset/IRQ vectors
  .org $fffa
  .word nmi
  .word reset
  .word irq
