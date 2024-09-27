.segment "HEADER"
  ; .byte "NES", $1A      ; iNES header identifier
  .byte $4E, $45, $53, $1A
  .byte 2               ; 2x 16KB PRG code
  .byte 1               ; 1x  8KB CHR data
  .byte $01, $00        ; mapper 0, vertical mirroring

.segment "VECTORS"
  .word NMI        ; NMI vector
  .word RESET      ; Reset vector
  .word 0          ; IRQ/BRK vector (not used)


.segment "CODE"
RESET:
  SEI             ; Disable interrupts
  CLD             ; Clear decimal mode
  LDX #$FF        ; Stack goes down rather than up, so we gotta get it ready
  TXS             ; Set up stack
  INX             ; X = 0
  STX $2000       ; Disable NMI
  STX $2001       ; Disable rendering
  STX $4010       ; Disable DMC IRQs

  LDA #%00010000   ; Enable sprites
  STA $2001

  ; Initialize PPU
  LDA #$00
  STA $2000
  STA $2001
  STA $2002

  ; Set up NMI
  LDA #%10000000  ; Enable NMI
  STA $2000

  CLI             ; Enable interrupts

Forever:
  JMP Forever     ; Infinite loop

NMI:
  PHA             ; Push A to the stack
  LDA $2002       ; Read PPU status to clear the VBlank flag

  ; Set up the palette address
  LDA #$3F
  STA $2006       ; High byte of palette address
  LDA #$00
  STA $2006       ; Low byte of palette address

  ; Write colors to the palette
  LDA #$01       ; Background color (index 0)
  STA $2007      ; Write background color
  LDA #$10       ; Red color (index 1)
  STA $2007      ; Write red color
  LDA #$00       ; Black (index 2)
  STA $2007
  LDA #$00       ; Black (index 3)
  STA $2007

  ; OAM Write
  LDA #$80        ; set y pos (128 FUCK YOU COPILOT)
  STA $0200       ; store y pos
  LDA #$00        ; set tile index thingy
  STA $0201       ; store tile index
  LDA #$01        ; Attributes uh red
  STA $0202       ; store attributes
  LDA #$80        ; set x pos (128)
  STA $0203       ; storeX position

  PLA             ; Pull A back from the stack
  RTI             ; Return from interrupt


.segment "CHARS"
  .byte %11111111
  .byte %11111111
  .byte %11111111
  .byte %11111111
  .byte %11111111
  .byte %11111111
  .byte %11111111
  .byte %11111111

  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000