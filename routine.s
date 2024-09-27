.segment "HEADER"
  .byte "NES"
  .byte $1A
  .byte $02 ; 2 16kb PRG ROM chips
  .byte $01 ; 1 8kb CHR ROM chip
  .byte %00000000 ; mapper and mirroring
  .byte $00
  .byte $00
  .byte $00
  .byte $00
  .byte $00, $00, $00, $00, $00 ; filler bytes

.segment "RODATA"
  coolPalette:
    .byte $12, $05, $17, $1A
    .byte $12, $35, $28, $31
    .byte $12, $47, $23, $34
    .byte $12, $39, $67, $1A
    .byte $12, $05, $17, $1A
    .byte $12, $35, $28, $31
    .byte $12, $47, $23, $34
    .byte $12, $39, $67, $1A

  mario:
    .byte $00, $36, $00, $00
    .byte $00, $37, $00, $08
    .byte $08, $38, $00, $00
    .byte $08, $39, $00, $08

.segment "DATA"
  gravity = 1
  maxYV = 10

.segment "ZEROPAGE"
  marioX: .res 1
  marioY: .res 1
  marioXV: .res 1
  marioYV: .res 1

.segment "STARTUP"
  .include "resetroutine.s"

.segment "CODE"

  lda #$3F
  sta $2006
  lda #$00
  sta $2006

  ; Write colors to the palette
  loadPalettes:
    LDA coolPalette, X
    STA $2007
    INX
    CPX #32
    BNE loadPalettes
  
  ldx #0
  loadSprite:
    LDA mario, X
    STA $0200, X
    INX
    CPX #16
    BNE loadSprite

Forever:
  JMP Forever     ; Infinite loop

NMI:
  PHA             ; Push A to the stack
  LDA $2002       ; Read PPU status to clear the VBlank flag

  ldx #0
  setMarioPos:
    lda mario+3, x
    adc marioX
    sta $0203, x
    lda mario, x
    adc marioY
    sta $0200, x
    inx
    inx
    inx
    inx
    cpx #16
    bne setMarioPos


  lda marioYV
  sec
  cmp #maxYV
  bcc addGrav
  jmp addYV

  addGrav:
    clc
    adc #gravity
    sta marioYV

  
  addYV:
    lda marioY
    sec
    cmp #208
    bcs @done
    clc
    adc marioYV
    sta marioY
    
@done:
  lda #$00
  sta $2003
  lda #$02
  sta $4014

  PLA             ; Pull A back from the stack
  RTI             ; Return from interrupt

.segment "VECTORS"
  .word NMI        ; NMI vector
  .word Reset      ; Reset vector
  .word 0          ; IRQ/BRK vector (not used)

.segment "CHARS"
  .incbin "mario.chr"