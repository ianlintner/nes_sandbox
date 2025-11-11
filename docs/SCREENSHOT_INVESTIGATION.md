# Screenshot Capture Investigation - Summary

## Issue Request

The original issue asked: "Is it possible with the CI build to take screenshots? If possible implement and add screenshots to docs if not comment why not."

## Investigation

Multiple approaches were tested to enable automated screenshot capture in CI:

### 1. FCEUX with Lua Scripting
- **Approach**: Use FCEUX's Lua API (`gui.savescreenshotas()`) to capture screenshots at specific frames
- **Result**: ❌ Failed
- **Reason**: The Lua screenshot functions are either not available or non-functional in headless environments. The Lua scripts load but don't execute or produce output.

### 2. FCEUX with xdotool (F12 Key)
- **Approach**: Run FCEUX in Xvfb and use xdotool to send F12 keypresses to trigger built-in screenshots
- **Result**: ❌ Failed  
- **Reason**: Window focus issues and FCEUX doesn't respond to simulated keypresses in headless mode. Screenshots directory remains empty.

### 3. Screen Capture Tools (scrot/import)
- **Approach**: Use scrot or ImageMagick's import to capture the X11 display
- **Result**: ❌ Failed
- **Reason**: Captured images are blank or minimal (192-1491 bytes). FCEUX's OpenGL rendering doesn't properly display in the Xvfb framebuffer.

### 4. Python nes-py Emulator
- **Approach**: Use Python-based NES emulator that can render to a numpy array
- **Result**: ❌ Failed
- **Reason**: Compatibility issues with the ROM format and numpy version conflicts.

### 5. Mednafen
- **Approach**: Check if mednafen has better headless support
- **Result**: ❌ Not pursued
- **Reason**: While mednafen can record videos (`-qtrecord`), it doesn't have direct screenshot support and would require additional processing.

## Root Cause

The fundamental issue is that NES emulators are designed for interactive use with proper graphics contexts. They typically use:
- OpenGL/SDL for rendering (requires GPU or proper graphics drivers)
- Window management systems that expect user interaction
- Graphics pipelines not optimized for headless framebuffer rendering

CI environments (GitHub Actions, etc.) run headless with:
- Virtual framebuffers (Xvfb) that may not support all graphics operations
- No GPU acceleration
- Limited OpenGL support
- No real window management

## Conclusion

**Automated screenshot capture in CI is not currently practical** for this NES project due to technical limitations with headless emulator operation.

## Solution Implemented

Instead of forcing an unreliable automated solution, we've implemented a **documented manual workflow**:

### 1. Documentation
- **`scripts/README.md`**: Explains the technical challenges and provides context
- **`docs/screenshots/README.md`**: Detailed instructions for manual screenshot capture
- **Updated `README.md`**: Points users to screenshot documentation

### 2. Scripts (for reference)
- `capture-screenshots.sh`: Demonstrates the xdotool approach (non-functional in CI)
- `capture-screenshots.lua`: FCEUX Lua script example (non-functional in CI)
- `capture-screenshots.py`: Python nes-py approach (has compatibility issues)

These scripts are included for:
- Documentation of attempted approaches
- Potential future improvements if better tools become available
- Local development use (may work with proper X11 display)

### 3. Placeholder
- `docs/screenshots/placeholder.png`: Demonstrates expected screenshot format

### 4. CI Workflow Update
- Added comment in `.github/workflows/build.yml` explaining the limitation
- References documentation for manual workflow

## Manual Workflow

Maintainers should capture screenshots by:

1. Building the ROM: `make`
2. Running in FCEUX: `fceux catmecha.nes`
3. Playing and pressing F12 at key moments
4. Copying from `~/.fceux/snaps/` to `docs/screenshots/`
5. Committing screenshots to the repository

## Future Possibilities

To make automated CI screenshots work in the future, potential approaches include:

1. **Custom Emulator Fork**: Modify an open-source NES emulator to add a headless screenshot mode
2. **Docker with GPU**: Use GitHub Actions runners that support GPU passthrough
3. **CHR Data Visualization**: Generate static images from CHR ROM data rather than actual gameplay
4. **Video Recording**: Record short video in CI, extract frames with ffmpeg (more reliable but larger)
5. **Dedicated Tool**: Create a minimal NES renderer specifically for CI screenshot generation

## Recommendation

The manual workflow is **simple, reliable, and maintainable**. Screenshots only need to be updated when visual changes occur, which is infrequent for a project like this. The overhead of maintaining a complex automated solution would outweigh the benefits.

## Files Changed

- `.github/workflows/build.yml` - Added comment about screenshot limitation
- `README.md` - Added link to screenshots documentation
- `scripts/README.md` - Technical explanation and manual workflow
- `scripts/capture-screenshots.sh` - Bash script (non-functional in CI)
- `scripts/capture-screenshots.lua` - Lua script (non-functional in CI)
- `scripts/capture-screenshots.py` - Python script (has compatibility issues)
- `docs/screenshots/README.md` - User guide for screenshot capture
- `docs/screenshots/placeholder.png` - Format demonstration

## Summary

**Issue Resolution**: The issue asked if CI screenshots are possible. The answer is: **Not practically with current tools**, but we've provided comprehensive documentation for manual screenshot capture, which is the recommended approach for this type of project.
