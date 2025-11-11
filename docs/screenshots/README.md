# NES Cat Mecha Shmup - Screenshots

This directory contains screenshots of the game for documentation purposes.

## How to Add Screenshots

Screenshots should be captured manually due to limitations with automated headless screenshot capture in CI environments.

### Capture Process

1. **Build the ROM**:
   ```bash
   make
   ```

2. **Run the game in FCEUX**:
   ```bash
   fceux catmecha.nes
   ```

3. **Capture screenshots during gameplay** by pressing `F12` at key moments:
   - Initial game screen (1-2 seconds)
   - Player movement and controls demonstration
   - Enemy encounters  
   - Combat with multiple enemies
   - Boss fight (after reaching 512 points)
   - Power-up/weapon switching demonstration

4. **Find screenshots** in your FCEUX snaps directory:
   ```bash
   ls ~/.fceux/snaps/
   ```

5. **Copy and rename screenshots**:
   ```bash
   cp ~/.fceux/snaps/*.png docs/screenshots/
   cd docs/screenshots/
   # Rename to descriptive names:
   mv snap_0001.png 01_initial_screen.png
   mv snap_0002.png 02_player_controls.png
   mv snap_0003.png 03_enemy_combat.png
   mv snap_0004.png 04_multiple_enemies.png
   mv snap_0005.png 05_boss_fight.png
   # etc.
   ```

6. **Commit screenshots**:
   ```bash
   git add docs/screenshots/
   git commit -m "Add/update gameplay screenshots"
   ```

## Screenshot Guidelines

- **Resolution**: NES native resolution is 256x224 pixels
- **Format**: PNG format is preferred
- **File naming**: Use descriptive names like `01_initial_screen.png`, `02_player_controls.png`, etc.
- **Quantity**: Capture 5-8 key screenshots that demonstrate:
  - Initial game state
  - Player character and controls
  - Enemy types and combat
  - Boss fight
  - Different weapon types
  - UI elements (score, health, etc.)

## Current Screenshots

**Placeholder**: A placeholder image (`placeholder.png`) is included to demonstrate the expected format. Replace with actual gameplay screenshots following the capture process above.

*Actual gameplay screenshots should be added here by maintainers following the capture process described above.*

## Technical Note

Automated screenshot capture in CI has been investigated but is not currently functional due to:
- NES emulators requiring proper graphics context (not available in headless CI)
- Lua scripting limitations in FCEUX when running headless
- Window focus and keyboard input challenges with xdotool in CI environments

For details on the attempted approaches, see [`scripts/README.md`](../../scripts/README.md).

## Alternative: Video Demonstration

If preferred, a short video demonstration could be recorded and hosted externally (YouTube, etc.) and linked from the main README. This would show gameplay more effectively than static screenshots.
