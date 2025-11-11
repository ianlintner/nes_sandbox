# GitHub Copilot Agent Instructions for NES Development

## Project Context

This is a Nintendo Entertainment System (NES) homebrew game development repository featuring a side-scrolling shoot 'em up (shmup) game with a giant cat mecha protagonist.

## Technology Stack

- **Language**: 6502 Assembly
- **Toolchain**: cc65 (ca65 assembler, ld65 linker)
- **Platform**: NES (Nintendo Entertainment System)
- **ROM Format**: iNES (NROM mapper, 32KB PRG + 8KB CHR)
- **Build System**: Make

## Code Guidelines

### Assembly Code Standards

1. **Labels and Naming**:
   - Use descriptive snake_case for labels and variables
   - Prefix with `@` for local labels within functions
   - Use UPPER_CASE for constants and hardware addresses

2. **Comments**:
   - Add section headers with `; ======` separators
   - Document complex logic and hardware-specific operations
   - Explain NES-specific constraints (PPU timing, VBlank, etc.)

3. **Memory Organization**:
   - Zero Page ($00-$FF): Fast-access game variables
   - RAM ($0200-$07FF): OAM buffer and additional data
   - Avoid indexed addressing with `inc`/`dec` (not supported)
   - Use load-modify-store pattern instead: `lda var,x; clc; adc #1; sta var,x`

4. **NES Hardware Constraints**:
   - Only update VRAM during VBlank (in NMI handler)
   - Keep NMI handler under ~2273 cycles
   - Use OAM DMA for sprite updates
   - Respect sprite limit (64 sprites, 8 per scanline)

### Performance Guidelines

1. **Optimization**:
   - Use zero page for frequently accessed variables
   - Minimize branching in hot code paths
   - Unroll small loops when appropriate
   - Use lookup tables instead of calculations

2. **Cycle Budget**:
   - Total frame: ~29,780 cycles
   - VBlank: ~2,273 cycles available
   - Monitor cycle usage in critical sections

### Game Development Patterns

1. **Game Loop**:
   - Wait for NMI flag
   - Read controller input
   - Update game logic
   - Update sprite positions
   - Repeat at 60 FPS

2. **Collision Detection**:
   - Use AABB (Axis-Aligned Bounding Box)
   - Keep collision boxes simple
   - Optimize with early exits

3. **State Management**:
   - Use game_state variable for high-level states
   - Implement separate update functions per state
   - Handle transitions cleanly

## Building and Testing

### Build Commands

```bash
# Clean build
make clean

# Build ROM
make

# Build output
catmecha.nes (40KB iNES ROM)
```

### Testing

- Use emulators: FCEUX, Mesen, Nestopia, or RetroArch
- Test on real hardware via flash cartridge (optional)
- Verify ROM format: `file catmecha.nes`
- Check header: `hexdump -C catmecha.nes | head -3`

## Common Patterns to Follow

### Weapon System Extension

```asm
; Add new weapon type in fire_weapon
fire_weapon:
    lda weapon_type
    cmp #4              ; New weapon type
    beq @new_weapon
    ; ... existing weapons ...
    
@new_weapon:
    ; Your weapon logic here
    rts
```

### Enemy AI Addition

```asm
; Add new enemy pattern in update_enemies
update_enemies:
    lda enemy_type, x
    cmp #4              ; New enemy type
    beq @new_pattern
    ; ... existing patterns ...
    
@new_pattern:
    ; Your AI logic here
    jmp @next
```

### Power-up System

```asm
; Add power-up variables to ZEROPAGE
powerup_active: .res 8
powerup_x:      .res 8
powerup_y:      .res 8
powerup_type:   .res 8

; Implement spawn and collection logic
```

## Documentation Standards

- Keep README.md updated with build instructions
- Document new features in FEATURES.md
- Add code examples to DEVELOPMENT.md
- Update QUICKREF.md for player-facing changes
- Use ASCII art in VISUALS.md for visual explanations

## File Structure

```
.
├── main.s           # Main game code (6502 assembly)
├── nes.cfg          # Linker configuration
├── Makefile         # Build system
├── README.md        # User documentation
├── QUICKREF.md      # Quick reference card
├── FEATURES.md      # Feature documentation
├── DEVELOPMENT.md   # Developer guide
├── VISUALS.md       # Visual guide
└── .github/
    ├── workflows/   # CI/CD workflows
    └── agents/      # Copilot agent instructions
```

## Common Pitfalls to Avoid

1. **Indexed Inc/Dec**: Don't use `inc var,x` or `dec var,x` (not supported by 6502)
2. **PPU Updates**: Never write to PPU outside VBlank
3. **Cycle Overrun**: Keep NMI handler under cycle budget
4. **Sprite Limit**: Don't exceed 64 total sprites or 8 per scanline
5. **Zero Page**: Don't exceed 256 bytes in zero page segment

## When Making Changes

1. Test build after each change: `make clean && make`
2. Verify ROM format: `file catmecha.nes`
3. Test in emulator if possible
4. Update documentation for user-facing changes
5. Add comments for complex logic
6. Follow existing code style and patterns

## Resources

- [NESdev Wiki](https://wiki.nesdev.com/): NES hardware reference
- [cc65 Documentation](https://cc65.github.io/): Toolchain manual
- [6502 Reference](http://www.6502.org/): CPU instruction set
- Project docs: README.md, DEVELOPMENT.md, FEATURES.md

## Suggestions for Copilot

When asked to:
- **Add features**: Follow existing patterns in main.s
- **Fix bugs**: Check zero page usage, cycle budget, PPU timing
- **Optimize**: Focus on zero page usage and loop reduction
- **Document**: Update all relevant .md files
- **Test**: Build and verify ROM format

Always maintain the clean, well-commented assembly style established in the codebase.
