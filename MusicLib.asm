  .include "NoteTable.asm"

Voice1 = %00000000
Voice2 = %01000000
Voice3 = %00100000

MuteAll:
  lda #$9F
  jsr SendSoundByte
  lda #$BF
  jsr SendSoundByte
  lda #$DF
  jsr SendSoundByte
  lda #$FF
  jsr SendSoundByte

SendNote:
    tax 
    lda NoteHi,x
    jsr SendSoundByte
    lda NoteLo,x
    jsr SendSoundBuye
    rts

SendSoundByte:


