# Development Guide - Extending the Cat Mecha Shmup

This guide explains how to modify and extend the NES Cat Mecha Shmup game.

## Project Structure

```
.
├── main.s          # Main game code (6502 assembly)
├── nes.cfg         # Linker configuration
├── Makefile        # Build system
├── README.md       # User documentation
├── FEATURES.md     # Feature documentation
└── .gitignore      # Git ignore rules
```

## Building the Game

```bash
# Clean build
make clean

# Build ROM
make

# Output: catmecha.nes
```

## Code Organization

### Segments

- **HEADER**: iNES ROM header (16 bytes)
- **ZEROPAGE**: Fast-access variables ($00-$FF)
- **BSS**: General RAM ($0200-$07FF)
- **CODE**: Game logic ($8000-$FFF9)
- **VECTORS**: Interrupt vectors ($FFFA-$FFFF)
- **CHR**: Graphics data (8KB)

### Main Code Sections

1. **Initialization** (lines 100-200)
   - Reset handler
   - PPU setup
   - Game variable initialization

2. **Game Loop** (lines 200-300)
   - Main loop waiting for NMI
   - Input reading
   - Game state updates

3. **Player System** (lines 300-500)
   - Movement handling
   - Weapon firing
   - Melee attacks

4. **Weapon System** (lines 500-700)
   - Fire weapon logic
   - Multiple weapon types
   - Bullet updates

5. **Enemy System** (lines 700-900)
   - Enemy spawning
   - Enemy movement/AI
   - Boss logic

6. **Collision System** (lines 900-1100)
   - Bullet-enemy collision
   - Bullet-boss collision
   - Player-enemy collision
   - Melee collision

7. **Graphics System** (lines 1100-1300)
   - Sprite updates
   - OAM management
   - NMI handler

8. **Data Section** (lines 1300+)
   - Palette data
   - CHR graphics

## Adding New Features

### Adding a New Weapon Type

1. **Increment weapon type counter** (line 362):
   ```asm
   lda weapon_type
   cmp #5              ; Change from 4 to 5
   ```

2. **Add new fire pattern** in `fire_weapon` (around line 500):
   ```asm
   cmp #4              ; New weapon type 4
   beq @new_weapon
   rts
   
   @new_weapon:
       ; Your weapon firing code here
       ; Set bullet positions, types, etc.
       rts
   ```

3. **Add bullet behavior** in `update_bullets` (around line 600):
   ```asm
   lda bullet_type, x
   cmp #4
   beq @new_bullet_behavior
   
   @new_bullet_behavior:
       ; Your bullet movement code
       jmp @next
   ```

### Adding a New Enemy Type

1. **Add to enemy spawning** (around line 650):
   ```asm
   ; Set enemy type
   lda frame_count
   and #$07            ; Change from #$03 to #$07 for 8 types
   sta enemy_type, x
   ```

2. **Add movement pattern** in `update_enemies` (around line 590):
   ```asm
   lda enemy_type, x
   cmp #4
   beq @new_enemy_type
   
   @new_enemy_type:
       ; Your enemy movement code
       jmp @next
   ```

3. **Set enemy properties**:
   ```asm
   ; Different HP based on type
   lda enemy_type, x
   cmp #4
   bne @normal_hp
   lda #5              ; Tougher enemy
   jmp @set_hp
   @normal_hp:
   lda #3
   @set_hp:
   sta enemy_hp, x
   ```

### Adding Power-ups

1. **Add power-up variables** to ZEROPAGE:
   ```asm
   powerup_active: .res 8
   powerup_x:      .res 8
   powerup_y:      .res 8
   powerup_type:   .res 8
   ```

2. **Add spawn logic**:
   ```asm
   spawn_powerup:
       ; Find free slot
       ldx #0
   @find_slot:
       lda powerup_active, x
       beq @found
       inx
       cpx #8
       bne @find_slot
       rts
   @found:
       lda #1
       sta powerup_active, x
       ; Set position and type
       rts
   ```

3. **Add collection detection** in `check_collisions`:
   ```asm
   ; Check player-powerup collision
   ldx #0
   @powerup_loop:
       lda powerup_active, x
       beq @next_powerup
       
       ; Check collision with player
       ; If collision:
       lda powerup_type, x
       ; Apply power-up effect
       lda #0
       sta powerup_active, x
       
   @next_powerup:
       inx
       cpx #8
       bne @powerup_loop
   ```

### Adding Sound Effects

1. **Set up APU** in initialization:
   ```asm
   ; Enable sound channels
   lda #$0F
   sta $4015           ; Enable pulse, triangle, noise
   ```

2. **Add sound effect function**:
   ```asm
   play_shoot_sound:
       lda #$01        ; Duty cycle 00, volume 1
       sta $4000       ; Pulse 1 duty/volume
       lda #$08        ; High freq byte
       sta $4002       ; Pulse 1 freq low
       lda #$02        ; Low freq byte
       sta $4003       ; Pulse 1 freq high
       rts
   ```

3. **Call in fire_weapon**:
   ```asm
   fire_weapon:
       ; ... existing code ...
       jsr play_shoot_sound
       ; ... continue ...
   ```

### Adding Background Tiles

1. **Expand CHR data** (around line 1250):
   ```asm
   ; Tile $20: Background tile 1
   .byte %10101010
   .byte %01010101
   .byte %10101010
   .byte %01010101
   .byte %10101010
   .byte %01010101
   .byte %10101010
   .byte %01010101
   .byte $00, $00, $00, $00, $00, $00, $00, $00
   ```

2. **Add nametable loading**:
   ```asm
   load_background:
       bit PPUSTATUS
       lda #$20        ; Nametable 0
       sta PPUADDR
       lda #$00
       sta PPUADDR
       
       ldx #0
       ldy #0
   @loop:
       lda background_data, x
       sta PPUDATA
       inx
       iny
       cpy #240        ; 32x30 tiles = 960
       bne @loop
       rts
   ```

### Adding Parallax Scrolling

1. **Add layer variables**:
   ```asm
   scroll_bg:    .res 1    ; Background layer
   scroll_fg:    .res 1    ; Foreground layer
   ```

2. **Update scroll differently**:
   ```asm
   update_scroll:
       lda frame_count
       and #$01
       beq @fg
       inc scroll_bg
   @fg:
       inc scroll_fg
       rts
   ```

3. **Implement in NMI** (split screen technique):
   ```asm
   nmi:
       ; ... existing code ...
       
       ; Set background scroll
       bit PPUSTATUS
       lda scroll_bg
       sta PPUSCROLL
       lda #0
       sta PPUSCROLL
       
       ; Later in NMI, change scroll for foreground
       ; (requires sprite 0 hit detection)
   ```

## Memory Map Reference

### Zero Page ($00-$FF)
- $00-$3F: Game variables
- $40-$FF: Available for expansion

### RAM ($0200-$07FF)
- $0200-$02FF: OAM buffer (sprites)
- $0300-$07FF: Available for game data

### PPU Registers
- $2000: PPUCTRL (control)
- $2001: PPUMASK (rendering enable)
- $2002: PPUSTATUS (status)
- $2003: OAMADDR (sprite address)
- $2004: OAMDATA (sprite data)
- $2005: PPUSCROLL (scroll position)
- $2006: PPUADDR (VRAM address)
- $2007: PPUDATA (VRAM data)

### APU Registers
- $4000-$4003: Pulse 1
- $4004-$4007: Pulse 2
- $4008-$400B: Triangle
- $400C-$400F: Noise
- $4015: Channel enable
- $4016: Joypad 1
- $4017: Joypad 2 / Frame counter

## Debugging Tips

### Using FCEUX Debugger

1. Load ROM in FCEUX
2. Open debugger: Debug → Debugger
3. Set breakpoints on functions
4. Step through code
5. Watch memory values

### Common Issues

**Sprites not appearing:**
- Check OAM buffer is filled correctly
- Verify PPUMASK has sprites enabled ($1E)
- Check sprite Y position (FF hides sprite)

**Graphics corrupted:**
- Only update VRAM during VBlank (in NMI)
- Don't access PPUADDR/PPUDATA outside VBlank
- Check CHR data is properly formatted

**Game running slow:**
- Reduce number of active objects
- Optimize collision detection loops
- Ensure NMI completes within VBlank (~2273 cycles)

**Controls not working:**
- Verify controller strobe sequence
- Check button masks are correct
- Debug buttons variable in memory

## Testing

### Unit Testing Approach
Since this is assembly, testing is manual:

1. **Movement Tests:**
   - Move in all 8 directions
   - Check boundary conditions
   - Verify sprite positions

2. **Combat Tests:**
   - Fire all weapon types
   - Test melee attack
   - Verify collision detection
   - Check damage values

3. **Game State Tests:**
   - Play until boss spawn
   - Defeat boss
   - Trigger game over
   - Test state transitions

### Emulator Tools
- **FCEUX**: Full debugger, trace logger
- **Mesen**: Excellent debugging, event viewer
- **Nintendulator**: Accurate emulation

## Performance Guidelines

### 6502 Cycle Budgets
- NMI (VBlank): ~2273 cycles available
- Frame: ~29780 cycles total

### Optimization Tips
1. Keep hot code in straight line (no branches)
2. Use zero page for frequently accessed vars
3. Unroll small loops when possible
4. Use lookup tables instead of calculations
5. Minimize PPU access (batch updates)

## CHR Graphics Format

Each tile is 16 bytes:
- Bytes 0-7: Bitplane 0 (low bit of color)
- Bytes 8-15: Bitplane 1 (high bit of color)

Example 8x8 tile:
```asm
.byte %11110000    ; Bitplane 0, row 0
.byte %11110000    ; row 1
.byte %11110000    ; row 2
.byte %11110000    ; row 3
.byte %00000000    ; row 4
.byte %00000000    ; row 5
.byte %00000000    ; row 6
.byte %00000000    ; row 7
.byte %11110000    ; Bitplane 1, row 0
.byte %11110000    ; row 1
.byte %00000000    ; row 2
.byte %00000000    ; row 3
.byte %11110000    ; row 4
.byte %11110000    ; row 5
.byte %00000000    ; row 6
.byte %00000000    ; row 7
```

Results in colors:
- Top-left 4x4: Color 3 (both planes 1)
- Top-right 4x4: Color 2 (plane 0 only)
- Bottom-left 4x4: Color 1 (plane 1 only)
- Bottom-right 4x4: Color 0 (both planes 0)

## Resources

- [NESdev Wiki](https://wiki.nesdev.com/): Comprehensive NES documentation
- [cc65 Documentation](https://cc65.github.io/): Assembler/linker manual
- [6502 Reference](http://www.6502.org/): CPU instruction reference
- [NES Tutorial](https://nerdy-nights.nes.science/): Beginner NES programming

## Contributing

When adding features:
1. Test thoroughly in multiple emulators
2. Document your changes
3. Keep code organized by function
4. Add comments for complex logic
5. Update this guide with new features

Happy coding!
