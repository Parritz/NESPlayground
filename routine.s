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
  LDA #$3F                    ; High byte of $3F00 (palette address) me when copilot writes the comment for me
  STA $2006
  LDA #$00                    ; Low byte of $3F00 SKIBIDI I BEAT COPILOT FUCK YOU
  STA $2006

  ; Write color to the palette
  LDA #$01                    ; load color from palette
  STA $2007                   ; write color to palette

  PLA             ; Pull A back from the stack
  RTI             ; Return from interrupt



VBlank2:
  ; Your VBlank handling code here
  ; Example: updating the screen, handling sprite logic, etc.

    ; check if vblank2 is ready
    ; BIT $2002
    ; BPL VBlank2

    ; LDA #$20                    ; point to nametable 0 in VRAM
    ; STA $2006
    ; LDA #$00
    ; STA $2006

    ; LDA #$20                    ; point to first nametable in VRAM
    ; STA $2006
    ; LDA #$00
    ; STA $2006

    ; LDY #$00
    ; LDX #$04

    LDA #$3F ; load color from palette nom nom (blackie)
    STA $2006  ; load the high byte of the address (thanks copilot for fucking stealing this comment from me)
    LDA #$16 ; load lower byte I BEAT COPILOT IM SIGMA
    STA $2006 ; load it into thingy
    STA $2007 ; load it into other ppu thingy

  RTI             ; Return from subroutine