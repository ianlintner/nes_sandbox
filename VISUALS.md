# Game Layout and Visual Guide

## Screen Layout (256x240 pixels)

```
┌────────────────────────────────────────────────────────────┐
│                    NES Cat Mecha Shmup                     │
│  HP: ●●●●●                                  Score: 00128   │
├────────────────────────────────────────────────────────────┤
│         ┌──┐                                               │
│         │  │                                  ┌──┐         │
│         │▓▓│ ←Cat Mecha                      │▓▓│ Enemy   │
│         └──┘                                 └──┘         │
│           ●→  ●→  ●→                                       │
│         Laser Bullets                                      │
│                                                            │
│                                              ┌──┐          │
│                                              │▓▓│ Enemy    │
│                                              └──┘          │
│                                                            │
│         Scrolling Background ════════════════════▶         │
│                                                            │
│                                              ┌──┐          │
│                                              │▓▓│ Enemy    │
│                                              └──┘          │
├────────────────────────────────────────────────────────────┤
│ Controls: D-Pad=Move | A=Fire | B=Melee | SELECT=Weapon   │
└────────────────────────────────────────────────────────────┘
```

## Boss Battle Layout

```
┌────────────────────────────────────────────────────────────┐
│              BOSS BATTLE - 50 HP REMAINING                 │
│  HP: ●●●                                    Score: 00512   │
├────────────────────────────────────────────────────────────┤
│                                                            │
│         ┌──┐                            ┌────┐            │
│         │  │                            │    │            │
│         │▓▓│ ←Cat Mecha                 │ ██ │ BOSS       │
│         └──┘                            │    │            │
│           ●→  ●→  ●→  ●→                │ ██ │            │
│         Laser Barrage                   └────┘            │
│                                           ↕                │
│                                     Boss Movement          │
│                                                            │
│                                                            │
│         Rapid Fire Engaged ═════════════════════▶          │
│                                                            │
│                                                            │
│                                                            │
├────────────────────────────────────────────────────────────┤
│ Defeat the Boss to Continue! Use Sustained Fire!          │
└────────────────────────────────────────────────────────────┘
```

## Weapon Types Visual

### Single Laser (Type 0)
```
   Cat Mecha
     ┌──┐
     │▓▓│  →●
     └──┘
     
   Single forward shot
```

### Triple Laser (Type 1)
```
            →●
   Cat Mecha  
     ┌──┐
     │▓▓│  →●
     └──┘
            →●
   Three parallel shots
```

### Spread Laser (Type 2)
```
           ↗●
          ↗●
   Cat Mecha
     ┌──┐   →●
     │▓▓│
     └──┘   ↘●
          ↘●
   Five-way spread
```

### Melee Attack (B Button)
```
   Cat Mecha    
     ┌──┐ ⚡⚔⚡
     │▓▓│ ⚡⚔⚡ (Close range, 2x damage)
     └──┘ ⚡⚔⚡
     
   Powerful close-range attack
```

## Enemy Types

### Type 0 - Basic Enemy
```
   ┌──┐
   │▓▓│  HP: 3
   └──┘  
   Movement: Sine wave down
```

### Type 1 - Swooper
```
   ┌──┐
   │▓▓│  HP: 3
   └──┘  
   Movement: Sine wave up
```

### Type 2-3 - Variants
```
   Different movement patterns
   HP: 3 each
```

### Boss
```
   ┌────┐
   │    │
   │ ██ │  HP: 50
   │    │
   │ ██ │  Size: 32x32
   └────┘
   Movement: Vertical pattern
   Threat: High HP, requires sustained fire
```

## Collision Zones

```
Player Collision Box (8x8 hitbox on 16x16 sprite):
     ┌──────┐
     │      │
     │ ┌──┐ │
     │ └──┘ │  ← Collision area (center)
     │      │
     └──────┘

Bullet Collision (8x8):
     ●  ← Full sprite is hitbox

Enemy Collision (8x8):
   ┌──┐
   │▓▓│ ← Full sprite is hitbox
   └──┘

Boss Collision (32x32):
   ┌────┐
   │████│ ← Larger hitbox
   │████│
   └────┘
```

## Color Palette

### Sprite Palette 0 (Cat Mecha)
```
█ Background (transparent)
█ Orange/Brown primary
█ Light orange highlight
█ Dark brown shadow
```

### Sprite Palette 1 (Bullets)
```
█ Background (transparent)
█ Blue primary
█ Light blue
█ White core
```

### Sprite Palette 2 (Enemies)
```
█ Background (transparent)
█ Pink/Red primary
█ Light pink
█ Dark red
```

### Sprite Palette 3 (Boss)
```
█ Background (transparent)
█ Yellow primary
█ Light yellow
█ Orange accent
```

## Game Flow Diagram

```
┌──────────────┐
│    START     │
│  Initialize  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   GAMEPLAY   │
│ Spawn Enemies│
│ Player Moves │
│ Fire Weapons │
│ Check Hits   │
└──────┬───────┘
       │
       ├──────────────┐
       │              │
   Score < 512    Score >= 512
       │              │
       ▼              ▼
┌──────────────┐ ┌──────────────┐
│  Continue    │ │  BOSS FIGHT  │
│  Waves       │ │  50 HP Boss  │
└──────┬───────┘ └──────┬───────┘
       │              │
       │         Boss Defeated
       │              │
       └──────┬───────┘
              │
         Player HP > 0
              │
              ▼
         (Loop Back)
              
         Player HP = 0
              │
              ▼
        ┌──────────────┐
        │  GAME OVER   │
        └──────────────┘
```

## Memory Map

```
Zero Page ($00-$FF):
├─ $00-$01: Player position (X, Y)
├─ $02-$03: Player HP, Shield
├─ $04-$07: Weapon state
├─ $08-$0F: Bullet active flags
├─ $10-$17: Bullet X positions
├─ $18-$1F: Bullet Y positions
├─ $20-$27: Bullet types
├─ $28-$2F: Enemy active flags
├─ $30-$37: Enemy X positions
├─ $38-$3F: Enemy Y positions
├─ $40-$47: Enemy HP
├─ $48-$4F: Enemy types
├─ $50-$54: Boss state (active, X, Y, HP, phase)
├─ $55-$5A: Game state variables
└─ $5B-$FF: Available

RAM ($0200-$07FF):
├─ $0200-$02FF: OAM Sprite Buffer (256 bytes)
└─ $0300-$07FF: Available (1280 bytes)

ROM ($8000-$FFFF):
├─ $8000-$FFF9: Game Code
├─ $FFFA-$FFFB: NMI Vector
├─ $FFFC-$FFFD: Reset Vector
└─ $FFFE-$FFFF: IRQ Vector

CHR ($0000-$1FFF):
├─ $0000-$0FFF: Sprite patterns (tiles 0-255)
└─ $1000-$1FFF: Background patterns (tiles 0-255)
```

## Performance Stats

```
Frame Budget (60 FPS):
├─ Total Cycles: 29,780 per frame
├─ VBlank Cycles: ~2,273 available
│
Game Object Limits:
├─ Player: 1 (4 sprites = 16x16)
├─ Bullets: 8 max (1 sprite each)
├─ Enemies: 8 max (1 sprite each)
├─ Boss: 1 (4 sprites = 16x16)
└─ Total Sprites: Up to 21 (out of 64 available)
│
Update Performance:
├─ Input Reading: ~30 cycles
├─ Player Update: ~200 cycles
├─ Bullet Update: ~800 cycles (8 bullets)
├─ Enemy Update: ~1200 cycles (8 enemies)
├─ Collision Check: ~2000 cycles
├─ Sprite Update: ~1500 cycles
└─ Total: ~5,730 cycles (19% of frame)
```

## Quick Start Visual Guide

```
1. Build the Game:
   $ make
   
2. Load in Emulator:
   $ fceux catmecha.nes
   
3. Controls:
   Keyboard       │ Action
   ───────────────┼────────────────
   Arrow Keys     │ Move cat mecha
   Z or X         │ Fire weapons
   A or S         │ Melee attack
   Enter          │ Cycle weapons
   
4. Gameplay Tips:
   • Hold fire button for rapid fire
   • Use melee (B) on tough enemies
   • Collect 512 points to fight boss
   • Shield activates when hit (30 frames)
   • Try different weapons with SELECT
```

## Sprite Sheet Layout

```
CHR ROM Layout (Tile Indices):

$00: Cat Mecha Top-Left      $02: Bullet
$01: Cat Mecha Top-Right     $03: Enemy
$10: Cat Mecha Bottom-Left   $04: Boss Top-Left
$11: Cat Mecha Bottom-Right  $05: Boss Top-Right
                             $14: Boss Bottom-Left
                             $15: Boss Bottom-Right

Visual Representation:
┌────┬────┬────┬────┐
│ 00 │ 01 │ 02 │ 03 │ Row 0
├────┼────┼────┼────┤
│ 10 │ 11 │    │    │ Row 1
├────┼────┼────┼────┤
│    │    │ 04 │ 05 │ Row 2
├────┼────┼────┼────┤
│    │    │ 14 │ 15 │ Row 3
└────┴────┴────┴────┘
```

This visual guide should help you understand the game's structure and layout!
