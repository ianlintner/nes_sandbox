# Screenshot Capture for NES ROMs in CI

## Overview

This directory contains scripts to assist with capturing screenshots from the NES ROM for documentation purposes.

## Challenge: Headless Screenshot Capture

Capturing screenshots from NES emulators in CI environments (headless, no GPU) presents several technical challenges:

1. **FCEUX Lua Support**: While FCEUX supports Lua scripting, the screenshot API functions are not consistently available or functional in headless environments
2. **Graphics Rendering**: NES emulators use various graphics backends (OpenGL, SDL) that may not render properly in headless Xvfb environments
3. **Window Focus**: Tools like `xdotool` require proper window focus which is difficult to achieve in CI

## Current Limitations

**Automated screenshot capture in CI is not currently functional** due to the above limitations. The scripts in this directory demonstrate the approach but may not produce valid screenshots in GitHub Actions or similar CI environments.

## Workarounds

### Option 1: Manual Screenshot Capture (Recommended)

For documentation purposes, screenshots should be captured manually:

1. Build the ROM locally:
   ```bash
   make
   ```

2. Run in an emulator with GUI:
   ```bash
   fceux catmecha.nes
   ```

3. Capture screenshots using:
   - **FCEUX**: Press `F12` to save screenshots to `~/.fceux/snaps/`
   - **Screen capture tools**: Use system screenshot tools
   - **OBS/Recording software**: Record gameplay and extract frames

4. Copy screenshots to the docs directory:
   ```bash
   mkdir -p docs/screenshots
   cp ~/.fceux/snaps/*.png docs/screenshots/
   ```

### Option 2: Video Recording in CI

Instead of screenshots, we could record a short video demonstration:

1. Use `mednafen` with `-qtrecord` to create a video
2. Extract frames from the video using `ffmpeg`
3. Upload video as an artifact

This is more reliable but produces larger artifacts.

### Option 3: Example/Placeholder Screenshots

For CI purposes, we can include pre-captured screenshots in the repository:

```bash
# Add to git
git add docs/screenshots/*.png
git commit -m "Add gameplay screenshots"
```

## Scripts

### `capture-screenshots.sh`

Attempts to capture screenshots using FCEUX with xdotool. This works in environments with proper X11 display but not in headless CI.

**Usage** (local development only):
```bash
./scripts/capture-screenshots.sh catmecha.nes screenshots 30
```

### `capture-screenshots.py`

Python-based approach using nes-py emulator. Currently has compatibility issues with the ROM format.

##Future Improvements

To make automated CI screenshots work, we would need:

1. **Headless-compatible emulator**: An emulator specifically designed for automation (e.g., using a framebuffer that can be captured)
2. **Custom rendering**: Modify an open-source emulator to add screenshot hooks
3. **Docker with GPU**: Use GitHub Actions runners with GPU support
4. **Alternative approach**: Generate visual representations from CHR data rather than actual gameplay

## Recommendation

For this project, **manual screenshot capture is the most practical solution**. The screenshots should be captured once, added to the repository in a `docs/screenshots/` directory, and updated only when significant visual changes occur.

## Example Workflow for Maintainers

```bash
# Build the ROM
make

# Run and play the game
fceux catmecha.nes

# During gameplay, press F12 at key moments:
# - Initial screen (1s)
# - Player movement (3s)
# - Enemy combat (6s)
# - Multiple enemies (10s)
# - Boss fight (20s+)

# Copy screenshots to docs
mkdir -p docs/screenshots
cp ~/.fceux/snaps/*.png docs/screenshots/

# Rename for clarity
cd docs/screenshots
mv snap_0001.png 01_initial_screen.png
mv snap_0002.png 02_player_movement.png
# ... etc

# Add to git
git add docs/screenshots/
git commit -m "Add gameplay screenshots"
```

## Conclusion

While fully automated screenshot capture in CI would be ideal, the technical limitations make it impractical for this project. The manual workflow above provides a reliable way to maintain up-to-date screenshots for documentation.
