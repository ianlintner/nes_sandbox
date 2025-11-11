# NES Cat Mecha Shmup

A side-scrolling shoot 'em up (shmup) game for the Nintendo Entertainment System (NES) featuring a giant cat-shaped mecha!

## Features

### Gameplay
- **Side-scrolling action** inspired by classics like Life Force
- **Giant cat mecha** as the player character
- **Multiple weapon systems:**
  - Single laser (starting weapon)
  - Triple laser spread
  - 5-way spread laser
  - Homing missiles (future upgrade)
  - Energy shield for protection
  - Melee attack (B button) for close-range, high-damage attacks on tough enemies
- **Progressive difficulty** with waves of enemies
- **Epic boss battle** after reaching score threshold
- **Health system** with 5 HP
- **Rapid fire** with hold-to-fire mechanics and cooldown limit
- **Auto-scrolling** background

### Controls
- **D-Pad**: Move the cat mecha (up, down, left, right)
- **A Button**: Fire weapons (hold for rapid fire)
- **B Button**: Melee attack (double damage, close range)
- **SELECT**: Cycle weapons (cheat for demo purposes)
- **START**: Pause (future feature)

### Weapon Types
1. **Single Laser (Type 0)**: Basic forward-firing laser
2. **Triple Laser (Type 1)**: Three lasers in parallel
3. **Spread Laser (Type 2)**: Five lasers in a spread pattern
4. **Homing Missiles (Type 3)**: Smart missiles that track enemies (future upgrade)

### Game Progression
- Enemies spawn in waves with increasing frequency
- Each destroyed enemy adds to your score
- Boss appears when score reaches 512 points
- Boss has 50 HP and requires sustained fire to defeat
- Shield activates temporarily after taking damage (invincibility frames)

## Building

### Requirements
- cc65 toolchain (ca65 assembler and ld65 linker)
- Make

### Installation (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install cc65
```

### Build the ROM
```bash
make
```

This will create `catmecha.nes` in the current directory.

### Clean build artifacts
```bash
make clean
```

## Playing

### NES Emulators
You can play the game using any NES emulator:

- **FCEUX** (Linux/Windows/Mac): Full-featured emulator with debugging tools
- **Nestopia** (Linux/Windows/Mac): High accuracy
- **Mesen** (Windows): Cycle-accurate with excellent debugging
- **RetroArch** (All platforms): Multi-system emulator

Example with FCEUX:
```bash
fceux catmecha.nes
```

### On Real Hardware
You can also play this on real NES hardware using a flash cartridge like:
- EverDrive N8
- PowerPak
- Retro-Bit Generations

## Development Notes

### Technical Details
- **Mapper**: NROM (Mapper 0)
- **PRG ROM**: 32KB (2x 16KB banks)
- **CHR ROM**: 8KB for graphics
- **Mirroring**: Vertical
- **Platform**: 6502 Assembly for NES

### Game Architecture
- **Main game loop**: Updates at 60 FPS (NES refresh rate)
- **Sprite system**: Uses OAM DMA for smooth sprite updates
- **Collision detection**: Simple AABB (Axis-Aligned Bounding Box)
- **Enemy AI**: Wave-based spawning with simple movement patterns
- **Boss AI**: Vertical movement pattern with health system

### Memory Layout
- **Zero Page ($0000-$00FF)**: Game variables and fast access data
- **RAM ($0200-$07FF)**: OAM buffer and additional game data
- **PRG ROM ($8000-$FFFF)**: Game code and data
- **CHR ROM**: Sprite and tile graphics

## Code Structure

- `main.s`: Main game code (assembly)
- `nes.cfg`: Linker configuration
- `Makefile`: Build system
- `.gitignore`: Git ignore file

### Key Functions
- `init_game`: Initialize all game variables
- `update_player`: Handle player movement and input
- `fire_weapon`: Spawn bullets based on current weapon type
- `update_enemies`: Enemy movement and AI
- `spawn_enemies`: Wave-based enemy spawning
- `update_boss`: Boss movement and AI
- `check_collisions`: Handle all collision detection
- `update_sprites`: Update sprite positions in OAM

## Future Enhancements

- [ ] Add homing missile functionality
- [ ] Implement shield pickup system
- [ ] Add weapon upgrade pickups
- [ ] Create more enemy types with varied AI
- [ ] Add multiple boss patterns/phases
- [ ] Implement background scrolling with parallax
- [ ] Add sound effects and music
- [ ] Create title screen and game over screen
- [ ] Add high score system
- [ ] Implement power-up system
- [ ] Add stage progression

## Credits

Inspired by classic NES shmups like:
- Life Force (Salamander)
- Gradius
- R-Type
- Thunder Force

Built with the cc65 toolchain and following NES development best practices.

## License

This is a demonstration project for educational purposes.
