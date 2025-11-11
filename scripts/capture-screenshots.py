#!/usr/bin/env python3
"""
NES Screenshot Capture Script using nes-py

This script loads a NES ROM and captures screenshots at specific frames
for documentation and CI purposes.
"""

import sys
import os
from pathlib import Path
from nes_py import NESEnv
from PIL import Image
import numpy as np


def capture_screenshots(rom_path, output_dir, frames_to_capture=None, max_frames=1800):
    """
    Capture screenshots from NES ROM at specified frames.
    
    Args:
        rom_path: Path to the NES ROM file
        output_dir: Directory to save screenshots
        frames_to_capture: List of frame numbers to capture screenshots at
        max_frames: Maximum number of frames to run
    """
    if frames_to_capture is None:
        # Default frames: 1s, 3s, 6s, 10s, 15s, 20s, 25s, 30s at 60fps
        frames_to_capture = [60, 180, 360, 600, 900, 1200, 1500, 1800]
    
    # Create output directory
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    print(f"=== NES Screenshot Capture ===")
    print(f"ROM: {rom_path}")
    print(f"Output Directory: {output_dir}")
    print(f"Frames to capture: {frames_to_capture}")
    print(f"Max frames: {max_frames}")
    print()
    
    # Initialize NES environment
    env = NESEnv(rom_path)
    env.reset()
    
    screenshot_index = 0
    frame_count = 0
    
    try:
        while frame_count < max_frames and screenshot_index < len(frames_to_capture):
            # Step the emulator (no action = 0)
            state, reward, done, info = env.step(0)
            frame_count += 1
            
            # Check if we should capture a screenshot at this frame
            if screenshot_index < len(frames_to_capture) and frame_count >= frames_to_capture[screenshot_index]:
                # Convert state to image
                img = Image.fromarray(state)
                
                # Save screenshot
                filename = f"gameplay_{screenshot_index+1:02d}_frame_{frame_count:04d}.png"
                filepath = output_path / filename
                img.save(filepath)
                
                print(f"[Frame {frame_count:04d}] Screenshot {screenshot_index+1}/{len(frames_to_capture)} saved: {filename}")
                screenshot_index += 1
            
            # Reset if game over (shouldn't happen in 30 seconds, but just in case)
            if done:
                env.reset()
    
    finally:
        env.close()
    
    print()
    print("=== Capture Complete ===")
    print(f"Screenshots captured: {screenshot_index}")
    
    # List created files
    screenshots = sorted(output_path.glob("*.png"))
    if screenshots:
        print(f"\nScreenshots saved to {output_dir}:")
        for screenshot in screenshots:
            size_kb = screenshot.stat().st_size / 1024
            print(f"  {screenshot.name} ({size_kb:.1f} KB)")
    else:
        print("Warning: No screenshots were created!")
        return 1
    
    return 0


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("Usage: python3 capture-screenshots.py <rom_file> [output_dir] [max_frames]")
        print()
        print("Example:")
        print("  python3 capture-screenshots.py catmecha.nes screenshots 1800")
        sys.exit(1)
    
    rom_file = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else "screenshots"
    max_frames = int(sys.argv[3]) if len(sys.argv) > 3 else 1800
    
    if not os.path.exists(rom_file):
        print(f"Error: ROM file not found: {rom_file}")
        sys.exit(1)
    
    try:
        result = capture_screenshots(rom_file, output_dir, max_frames=max_frames)
        sys.exit(result)
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
