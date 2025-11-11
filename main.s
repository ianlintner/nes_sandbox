; ======================================
; NES Cat Mecha Shmup - Main Code
; A side-scrolling shooter featuring a giant cat mecha
; ======================================

.segment "HEADER"
    ; iNES header (16 bytes)
    .byte "NES", $1A        ; Magic string
    .byte $02               ; 2x 16KB PRG ROM
    .byte $01               ; 1x 8KB CHR ROM
    .byte $01               ; Mapper 0, vertical mirroring
    .byte $00               ; Mapper 0
    .byte $00, $00, $00, $00, $00, $00, $00, $00

.segment "ZEROPAGE"
    ; Player variables
    player_x:       .res 1      ; Player X position
    player_y:       .res 1      ; Player Y position
    player_hp:      .res 1      ; Player health
    player_shield:  .res 1      ; Shield active flag
    
    ; Weapon variables
    weapon_type:    .res 1      ; 0=single, 1=triple, 2=spread, 3=homing
    weapon_level:   .res 1      ; Weapon level
    rapid_fire:     .res 1      ; Rapid fire cooldown
    melee_active:   .res 1      ; Melee weapon active
    
    ; Bullet variables (8 bullets)
    bullet_active:  .res 8      ; Bullet active flags
    bullet_x:       .res 8      ; Bullet X positions
    bullet_y:       .res 8      ; Bullet Y positions
    bullet_type:    .res 8      ; Bullet type
    
    ; Enemy variables (8 enemies)
    enemy_active:   .res 8      ; Enemy active flags
    enemy_x:        .res 8      ; Enemy X positions
    enemy_y:        .res 8      ; Enemy Y positions
    enemy_hp:       .res 8      ; Enemy health
    enemy_type:     .res 8      ; Enemy type
    
    ; Boss variables
    boss_active:    .res 1      ; Boss active flag
    boss_x:         .res 1      ; Boss X position
    boss_y:         .res 1      ; Boss Y position
    boss_hp:        .res 1      ; Boss health
    boss_phase:     .res 1      ; Boss attack phase
    
    ; Game state
    game_state:     .res 1      ; 0=intro, 1=playing, 2=boss, 3=gameover
    scroll_x:       .res 1      ; Background scroll
    frame_count:    .res 1      ; Frame counter
    spawn_timer:    .res 1      ; Enemy spawn timer
    score_lo:       .res 1      ; Score low byte
    score_hi:       .res 1      ; Score high byte
    
    ; Temporary variables
    temp:           .res 1
    temp2:          .res 1
    temp3:          .res 1
    
    ; Controller input
    buttons:        .res 1      ; Current buttons
    buttons_prev:   .res 1      ; Previous buttons

; Constants
PLAYER_START_X  = 32
PLAYER_START_Y  = 120
PLAYER_HP_MAX   = 5
BOSS_HP_MAX     = 50
RAPID_FIRE_MAX  = 3

; PPU registers
PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
OAMDATA   = $2004
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007

; APU and I/O registers
OAMDMA    = $4014
JOYPAD1   = $4016
JOYPAD2   = $4017

; Button constants
BUTTON_A      = $01
BUTTON_B      = $02
BUTTON_SELECT = $04
BUTTON_START  = $08
BUTTON_UP     = $10
BUTTON_DOWN   = $20
BUTTON_LEFT   = $40
BUTTON_RIGHT  = $80

.segment "BSS"
    oam_buffer: .res 256    ; OAM sprite buffer

.segment "CODE"

; ======================================
; Reset Handler
; ======================================
reset:
    sei                     ; Disable interrupts
    cld                     ; Disable decimal mode
    ldx #$40
    stx JOYPAD2             ; Disable APU frame IRQ
    ldx #$FF
    txs                     ; Set up stack
    inx                     ; X = 0
    stx PPUCTRL             ; Disable NMI
    stx PPUMASK             ; Disable rendering
    stx $4010               ; Disable DMC IRQs
    
    ; Wait for PPU to be ready (2 vblanks)
    bit PPUSTATUS
:   bit PPUSTATUS
    bpl :-
:   bit PPUSTATUS
    bpl :-
    
    ; Clear RAM
    lda #$00
    ldx #$00
:   sta $0000, x
    sta $0100, x
    sta $0200, x
    sta $0300, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    inx
    bne :-
    
    ; Initialize game variables
    jsr init_game
    
    ; Load palette
    jsr load_palette
    
    ; Enable rendering
    lda #%10000000          ; Enable NMI
    sta PPUCTRL
    lda #%00011110          ; Enable sprites and background
    sta PPUMASK
    
    ; Main game loop
main_loop:
    ; Wait for NMI flag
:   lda nmi_flag
    beq :-
    lda #$00
    sta nmi_flag
    
    ; Update game state
    jsr read_controller
    jsr update_game
    jsr update_sprites
    
    jmp main_loop

; ======================================
; Initialize Game
; ======================================
init_game:
    ; Set up player
    lda #PLAYER_START_X
    sta player_x
    lda #PLAYER_START_Y
    sta player_y
    lda #PLAYER_HP_MAX
    sta player_hp
    
    ; Clear all bullets
    ldx #7
:   lda #0
    sta bullet_active, x
    dex
    bpl :-
    
    ; Clear all enemies
    ldx #7
:   lda #0
    sta enemy_active, x
    dex
    bpl :-
    
    ; Initialize weapon
    lda #0
    sta weapon_type
    sta weapon_level
    sta melee_active
    sta rapid_fire
    
    ; Initialize game state
    lda #1                  ; Start in playing state
    sta game_state
    lda #0
    sta scroll_x
    sta frame_count
    sta spawn_timer
    sta boss_active
    sta player_shield
    sta score_lo
    sta score_hi
    
    rts

; ======================================
; Load Palette
; ======================================
load_palette:
    ; Set PPU address to palette
    bit PPUSTATUS
    lda #$3F
    sta PPUADDR
    lda #$00
    sta PPUADDR
    
    ; Load background palette
    ldx #0
:   lda palette, x
    sta PPUDATA
    inx
    cpx #32
    bne :-
    
    ; Reset scroll
    bit PPUSTATUS
    lda #0
    sta PPUSCROLL
    sta PPUSCROLL
    
    rts

; ======================================
; Read Controller
; ======================================
read_controller:
    ; Save previous button state
    lda buttons
    sta buttons_prev
    
    ; Strobe controller
    lda #$01
    sta JOYPAD1
    lda #$00
    sta JOYPAD1
    
    ; Read 8 buttons
    ldx #8
:   lda JOYPAD1
    lsr a
    rol buttons
    dex
    bne :-
    
    rts

; ======================================
; Update Game
; ======================================
update_game:
    ; Increment frame counter
    inc frame_count
    
    ; Check game state
    lda game_state
    cmp #1
    beq @playing
    cmp #2
    beq @boss_fight
    rts
    
@playing:
    jsr update_player
    jsr update_bullets
    jsr update_enemies
    jsr spawn_enemies
    jsr check_collisions
    jsr update_scroll
    
    ; Check if boss should spawn
    lda score_hi
    cmp #2              ; Spawn boss after score reaches 512
    bcc @done
    lda #2
    sta game_state
    jsr spawn_boss
    
@done:
    rts
    
@boss_fight:
    jsr update_player
    jsr update_bullets
    jsr update_boss
    jsr check_collisions
    rts

; ======================================
; Update Player
; ======================================
update_player:
    ; Check for death
    lda player_hp
    bne @alive
    lda #3
    sta game_state      ; Game over
    rts
    
@alive:
    ; Handle movement
    lda buttons
    and #BUTTON_UP
    beq @check_down
    lda player_y
    cmp #16
    bcc @check_down
    dec player_y
    dec player_y
    
@check_down:
    lda buttons
    and #BUTTON_DOWN
    beq @check_left
    lda player_y
    cmp #208
    bcs @check_left
    inc player_y
    inc player_y
    
@check_left:
    lda buttons
    and #BUTTON_LEFT
    beq @check_right
    lda player_x
    cmp #8
    bcc @check_right
    dec player_x
    
@check_right:
    lda buttons
    and #BUTTON_RIGHT
    beq @check_fire
    lda player_x
    cmp #240
    bcs @check_fire
    inc player_x
    
@check_fire:
    ; Handle rapid fire cooldown
    lda rapid_fire
    beq @check_a_button
    dec rapid_fire
    
@check_a_button:
    ; A button for shooting
    lda buttons
    and #BUTTON_A
    beq @check_b_button
    
    ; Check if can fire
    lda rapid_fire
    bne @check_b_button
    
    ; Fire weapon
    jsr fire_weapon
    lda #RAPID_FIRE_MAX
    sta rapid_fire
    
@check_b_button:
    ; B button for melee
    lda buttons
    and #BUTTON_B
    beq @check_select
    
    ; Check if just pressed (not held)
    lda buttons_prev
    and #BUTTON_B
    bne @check_select
    
    ; Activate melee
    lda #15
    sta melee_active
    
@check_select:
    ; SELECT to cycle weapons (cheat for demo)
    lda buttons
    and #BUTTON_SELECT
    beq @done
    lda buttons_prev
    and #BUTTON_SELECT
    bne @done
    
    ; Cycle weapon
    inc weapon_type
    lda weapon_type
    cmp #4
    bcc @done
    lda #0
    sta weapon_type
    
@done:
    ; Update melee timer
    lda melee_active
    beq @melee_done
    dec melee_active
@melee_done:
    
    ; Update shield timer
    lda player_shield
    beq @shield_done
    dec player_shield
@shield_done:
    rts

; ======================================
; Fire Weapon
; ======================================
fire_weapon:
    ; Find free bullet slot
    ldx #0
@find_slot:
    lda bullet_active, x
    beq @found_slot
    inx
    cpx #8
    bne @find_slot
    rts                 ; No free slots
    
@found_slot:
    ; Activate bullet
    lda #1
    sta bullet_active, x
    
    ; Set bullet position
    lda player_x
    clc
    adc #16
    sta bullet_x, x
    
    lda player_y
    clc
    adc #4
    sta bullet_y, x
    
    ; Set bullet type based on weapon
    lda weapon_type
    sta bullet_type, x
    
    ; For triple and spread, fire additional bullets
    lda weapon_type
    cmp #1              ; Triple shot
    beq @triple
    cmp #2              ; Spread shot
    beq @spread
    rts
    
@triple:
    ; Fire additional bullets above and below
    inx
    cpx #8
    beq @done
    lda #1
    sta bullet_active, x
    lda player_x
    clc
    adc #16
    sta bullet_x, x
    lda player_y
    sec
    sbc #8
    sta bullet_y, x
    lda #1
    sta bullet_type, x
    
    inx
    cpx #8
    beq @done
    lda #1
    sta bullet_active, x
    lda player_x
    clc
    adc #16
    sta bullet_x, x
    lda player_y
    clc
    adc #8
    sta bullet_y, x
    lda #1
    sta bullet_type, x
    rts
    
@spread:
    ; Fire 5 bullets in spread pattern
    ; (Simplified - just 3 additional for now)
    inx
    cpx #8
    beq @done
    lda #1
    sta bullet_active, x
    lda player_x
    clc
    adc #16
    sta bullet_x, x
    lda player_y
    sec
    sbc #12
    sta bullet_y, x
    lda #2
    sta bullet_type, x
    
    inx
    cpx #8
    beq @done
    lda #1
    sta bullet_active, x
    lda player_x
    clc
    adc #16
    sta bullet_x, x
    lda player_y
    clc
    adc #12
    sta bullet_y, x
    lda #2
    sta bullet_type, x
    
@done:
    rts

; ======================================
; Update Bullets
; ======================================
update_bullets:
    ldx #0
@loop:
    lda bullet_active, x
    beq @next
    
    ; Move bullet right
    lda bullet_x, x
    clc
    adc #4
    sta bullet_x, x
    
    ; Check if off screen
    cmp #255
    bcc @next
    
    ; Deactivate bullet
    lda #0
    sta bullet_active, x
    
@next:
    inx
    cpx #8
    bne @loop
    rts

; ======================================
; Update Enemies
; ======================================
update_enemies:
    ldx #0
@loop:
    lda enemy_active, x
    beq @next
    
    ; Move enemy left
    lda enemy_x, x
    sec
    sbc #1
    sta enemy_x, x
    
    ; Check if off screen
    cmp #8
    bcs @move_y
    
    ; Deactivate enemy
    lda #0
    sta enemy_active, x
    jmp @next
    
@move_y:
    ; Simple sine wave movement
    lda enemy_type, x
    and #$01
    beq @move_down
    
@move_up:
    lda frame_count
    and #$03
    bne @next
    lda enemy_y, x
    cmp #16
    bcc @next
    lda enemy_y, x
    sec
    sbc #1
    sta enemy_y, x
    jmp @next
    
@move_down:
    lda frame_count
    and #$03
    bne @next
    lda enemy_y, x
    cmp #208
    bcs @next
    lda enemy_y, x
    clc
    adc #1
    sta enemy_y, x
    
@next:
    inx
    cpx #8
    bne @loop
    rts

; ======================================
; Spawn Enemies
; ======================================
spawn_enemies:
    ; Increment spawn timer
    inc spawn_timer
    lda spawn_timer
    cmp #60             ; Spawn every 60 frames
    bcc @done
    
    ; Reset timer
    lda #0
    sta spawn_timer
    
    ; Find free enemy slot
    ldx #0
@find_slot:
    lda enemy_active, x
    beq @found_slot
    inx
    cpx #8
    bne @find_slot
    rts                 ; No free slots
    
@found_slot:
    ; Activate enemy
    lda #1
    sta enemy_active, x
    
    ; Set enemy position
    lda #248
    sta enemy_x, x
    
    ; Random Y position based on frame count
    lda frame_count
    and #$7F
    clc
    adc #32
    sta enemy_y, x
    
    ; Set enemy type
    lda frame_count
    and #$03
    sta enemy_type, x
    
    ; Set enemy HP
    lda #3
    sta enemy_hp, x
    
@done:
    rts

; ======================================
; Spawn Boss
; ======================================
spawn_boss:
    lda #1
    sta boss_active
    lda #200
    sta boss_x
    lda #100
    sta boss_y
    lda #BOSS_HP_MAX
    sta boss_hp
    lda #0
    sta boss_phase
    rts

; ======================================
; Update Boss
; ======================================
update_boss:
    lda boss_active
    beq @done
    
    ; Simple boss movement pattern
    lda frame_count
    and #$7F
    cmp #$40
    bcc @move_down
    
@move_up:
    lda boss_y
    cmp #32
    bcc @done
    dec boss_y
    jmp @done
    
@move_down:
    lda boss_y
    cmp #180
    bcs @done
    inc boss_y
    
@done:
    rts

; ======================================
; Check Collisions
; ======================================
check_collisions:
    ; Check bullet-enemy collisions
    ldx #0
@bullet_loop:
    lda bullet_active, x
    beq @next_bullet
    
    ; Check against all enemies
    ldy #0
@enemy_loop:
    lda enemy_active, y
    beq @next_enemy
    
    ; Simple AABB collision
    ; Check X overlap
    lda bullet_x, x
    sec
    sbc enemy_x, y
    clc
    adc #8
    cmp #24
    bcs @next_enemy
    
    ; Check Y overlap
    lda bullet_y, x
    sec
    sbc enemy_y, y
    clc
    adc #8
    cmp #24
    bcs @next_enemy
    
    ; Collision detected!
    lda #0
    sta bullet_active, x
    
    ; Damage enemy
    lda enemy_hp, y
    sec
    sbc #1
    sta enemy_hp, y
    bne @next_enemy
    
    ; Enemy destroyed
    lda #0
    sta enemy_active, y
    
    ; Increment score
    inc score_lo
    bne @next_enemy
    inc score_hi
    
@next_enemy:
    iny
    cpy #8
    bne @enemy_loop
    
@next_bullet:
    inx
    cpx #8
    bne @bullet_loop
    
    ; Check bullet-boss collision
    lda boss_active
    beq @check_player_enemy
    
    ldx #0
@bullet_boss_loop:
    lda bullet_active, x
    beq @next_bullet_boss
    
    ; Check collision with boss
    lda bullet_x, x
    sec
    sbc boss_x
    clc
    adc #8
    cmp #40
    bcs @next_bullet_boss
    
    lda bullet_y, x
    sec
    sbc boss_y
    clc
    adc #8
    cmp #40
    bcs @next_bullet_boss
    
    ; Hit boss
    lda #0
    sta bullet_active, x
    
    dec boss_hp
    lda boss_hp
    bne @next_bullet_boss
    
    ; Boss defeated!
    lda #0
    sta boss_active
    lda #1
    sta game_state      ; Back to normal play
    
@next_bullet_boss:
    inx
    cpx #8
    bne @bullet_boss_loop
    
@check_player_enemy:
    ; Check player-enemy collisions
    lda player_shield
    bne @check_melee    ; Shield protects
    
    ldx #0
@player_enemy_loop:
    lda enemy_active, x
    beq @next_player_enemy
    
    ; Check collision
    lda player_x
    sec
    sbc enemy_x, x
    clc
    adc #8
    cmp #24
    bcs @next_player_enemy
    
    lda player_y
    sec
    sbc enemy_y, x
    clc
    adc #8
    cmp #24
    bcs @next_player_enemy
    
    ; Hit player
    lda #0
    sta enemy_active, x
    dec player_hp
    
    ; Give brief invincibility
    lda #30
    sta player_shield
    
@next_player_enemy:
    inx
    cpx #8
    bne @player_enemy_loop
    
@check_melee:
    ; Check melee attack
    lda melee_active
    beq @done
    
    ldx #0
@melee_loop:
    lda enemy_active, x
    beq @next_melee
    
    ; Check if enemy is in melee range
    lda enemy_x, x
    sec
    sbc player_x
    clc
    adc #8
    cmp #32
    bcs @next_melee
    
    lda enemy_y, x
    sec
    sbc player_y
    clc
    adc #8
    cmp #32
    bcs @next_melee
    
    ; Hit with melee
    lda enemy_hp, x
    sec
    sbc #2              ; Melee does double damage
    sta enemy_hp, x
    bpl @next_melee
    
    ; Enemy destroyed
    lda #0
    sta enemy_active, x
    inc score_lo
    bne @next_melee
    inc score_hi
    
@next_melee:
    inx
    cpx #8
    bne @melee_loop
    
@done:
    rts

; ======================================
; Update Scroll
; ======================================
update_scroll:
    ; Simple auto-scroll
    lda frame_count
    and #$01
    beq @done
    
    inc scroll_x
    
@done:
    rts

; ======================================
; Update Sprites
; ======================================
update_sprites:
    ; Clear OAM buffer
    ldx #0
    lda #$FF
@clear_loop:
    sta oam_buffer, x
    inx
    inx
    inx
    inx
    bne @clear_loop
    
    ; Draw player (4 sprites for 16x16)
    ldx #0
    
    ; Top-left
    lda player_y
    sta oam_buffer, x
    inx
    lda #$00                ; Tile index
    sta oam_buffer, x
    inx
    lda #$00                ; Attributes
    sta oam_buffer, x
    inx
    lda player_x
    sta oam_buffer, x
    inx
    
    ; Top-right
    lda player_y
    sta oam_buffer, x
    inx
    lda #$01
    sta oam_buffer, x
    inx
    lda #$00
    sta oam_buffer, x
    inx
    lda player_x
    clc
    adc #8
    sta oam_buffer, x
    inx
    
    ; Bottom-left
    lda player_y
    clc
    adc #8
    sta oam_buffer, x
    inx
    lda #$10
    sta oam_buffer, x
    inx
    lda #$00
    sta oam_buffer, x
    inx
    lda player_x
    sta oam_buffer, x
    inx
    
    ; Bottom-right
    lda player_y
    clc
    adc #8
    sta oam_buffer, x
    inx
    lda #$11
    sta oam_buffer, x
    inx
    lda #$00
    sta oam_buffer, x
    inx
    lda player_x
    clc
    adc #8
    sta oam_buffer, x
    inx
    
    ; Draw bullets
    stx temp
    ldx #0
@bullet_loop:
    lda bullet_active, x
    beq @next_bullet
    
    ldy temp
    
    lda bullet_y, x
    sta oam_buffer, y
    iny
    lda #$02            ; Bullet tile
    sta oam_buffer, y
    iny
    lda #$01            ; Attributes
    sta oam_buffer, y
    iny
    lda bullet_x, x
    sta oam_buffer, y
    iny
    
    sty temp
    
@next_bullet:
    inx
    cpx #8
    bne @bullet_loop
    
    ; Draw enemies
    ldx #0
@enemy_loop:
    lda enemy_active, x
    beq @next_enemy
    
    ldy temp
    
    lda enemy_y, x
    sta oam_buffer, y
    iny
    lda #$03            ; Enemy tile
    sta oam_buffer, y
    iny
    lda #$02            ; Attributes
    sta oam_buffer, y
    iny
    lda enemy_x, x
    sta oam_buffer, y
    iny
    
    sty temp
    
@next_enemy:
    inx
    cpx #8
    bne @enemy_loop
    
    ; Draw boss if active
    lda boss_active
    beq @done
    
    ldy temp
    
    ; Boss (4 sprites for 16x16)
    lda boss_y
    sta oam_buffer, y
    iny
    lda #$04
    sta oam_buffer, y
    iny
    lda #$03
    sta oam_buffer, y
    iny
    lda boss_x
    sta oam_buffer, y
    iny
    
    lda boss_y
    sta oam_buffer, y
    iny
    lda #$05
    sta oam_buffer, y
    iny
    lda #$03
    sta oam_buffer, y
    iny
    lda boss_x
    clc
    adc #8
    sta oam_buffer, y
    iny
    
    lda boss_y
    clc
    adc #8
    sta oam_buffer, y
    iny
    lda #$14
    sta oam_buffer, y
    iny
    lda #$03
    sta oam_buffer, y
    iny
    lda boss_x
    sta oam_buffer, y
    iny
    
    lda boss_y
    clc
    adc #8
    sta oam_buffer, y
    iny
    lda #$15
    sta oam_buffer, y
    iny
    lda #$03
    sta oam_buffer, y
    iny
    lda boss_x
    clc
    adc #8
    sta oam_buffer, y
    
@done:
    rts

; ======================================
; NMI Handler (VBlank)
; ======================================
nmi:
    ; Save registers
    pha
    txa
    pha
    tya
    pha
    
    ; Set NMI flag
    inc nmi_flag
    
    ; Update OAM via DMA
    lda #$00
    sta OAMADDR
    lda #>oam_buffer
    sta OAMDMA
    
    ; Update scroll
    bit PPUSTATUS
    lda scroll_x
    sta PPUSCROLL
    lda #0
    sta PPUSCROLL
    
    ; Restore registers
    pla
    tay
    pla
    tax
    pla
    
    rti

; ======================================
; IRQ Handler (not used)
; ======================================
irq:
    rti

; ======================================
; Data Section
; ======================================

; Palette data (32 bytes)
palette:
    ; Background palettes
    .byte $0F, $00, $10, $30  ; Palette 0: Dark space
    .byte $0F, $02, $12, $22  ; Palette 1: Blue
    .byte $0F, $06, $16, $26  ; Palette 2: Red
    .byte $0F, $0A, $1A, $2A  ; Palette 3: Green
    
    ; Sprite palettes
    .byte $0F, $07, $17, $27  ; Palette 0: Cat mecha (orange/brown)
    .byte $0F, $11, $21, $31  ; Palette 1: Bullets (blue)
    .byte $0F, $15, $25, $35  ; Palette 2: Enemies (pink)
    .byte $0F, $19, $29, $39  ; Palette 3: Boss (yellow)

; NMI flag
nmi_flag: .byte 0

; ======================================
; Interrupt Vectors
; ======================================
.segment "VECTORS"
    .word nmi           ; NMI vector
    .word reset         ; Reset vector
    .word irq           ; IRQ vector

; ======================================
; CHR ROM Data (Graphics)
; ======================================
.segment "CHR"
    ; Tile $00: Cat mecha top-left
    .byte %11111111
    .byte %11000011
    .byte %10111101
    .byte %10111101
    .byte %10111101
    .byte %10111101
    .byte %10000001
    .byte %11111111
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    
    ; Tile $01: Cat mecha top-right
    .byte %11111111
    .byte %11000011
    .byte %10111101
    .byte %10111101
    .byte %10111101
    .byte %10111101
    .byte %10000001
    .byte %11111111
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    
    ; Tile $02: Bullet
    .byte %00000000
    .byte %00000000
    .byte %00011000
    .byte %00111100
    .byte %00111100
    .byte %00011000
    .byte %00000000
    .byte %00000000
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    
    ; Tile $03: Enemy
    .byte %00111100
    .byte %01111110
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %01111110
    .byte %00111100
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    
    ; Tile $04: Boss top-left
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    
    ; Tile $05: Boss top-right
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    
    ; Tile $10: Cat mecha bottom-left
    .byte %11111111
    .byte %10000001
    .byte %10111101
    .byte %10111101
    .byte %10111101
    .byte %10111101
    .byte %11000011
    .byte %11111111
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    
    ; Tile $11: Cat mecha bottom-right
    .byte %11111111
    .byte %10000001
    .byte %10111101
    .byte %10111101
    .byte %10111101
    .byte %10111101
    .byte %11000011
    .byte %11111111
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    
    ; Tile $14: Boss bottom-left
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    
    ; Tile $15: Boss bottom-right
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    
    ; Fill rest of CHR with zeros
    .res 8192 - 160
