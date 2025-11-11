-- FCEUX Lua script to capture screenshots at specific frames
-- This script automatically runs the game and captures screenshots at defined intervals
-- for documentation and CI purposes.

local outputDir = os.getenv("SCREENSHOT_DIR") or "screenshots"
local maxFrames = tonumber(os.getenv("MAX_FRAMES")) or 1800  -- 30 seconds at 60fps

-- Define frames to capture screenshots at (in frames, 60 fps)
-- Frame 60 = 1 second, 120 = 2 seconds, etc.
local screenshotFrames = {
    60,    -- 1 second  - Initial gameplay
    180,   -- 3 seconds - Player movement started
    360,   -- 6 seconds - Some enemies on screen
    600,   -- 10 seconds - Active combat
    900,   -- 15 seconds - More advanced gameplay
    1200,  -- 20 seconds - Lots of action
    1500,  -- 25 seconds - Near boss spawn threshold
    1800   -- 30 seconds - Should have boss or high score
}

local currentIndex = 1
local startTime = os.time()

print(string.format("Screenshot capture started. Output dir: %s", outputDir))
print(string.format("Will capture %d screenshots over %d frames", #screenshotFrames, maxFrames))

-- Main game loop
while true do
    local currentFrame = emu.framecount()
    
    -- Check if we should take a screenshot at this frame
    if currentIndex <= #screenshotFrames and currentFrame >= screenshotFrames[currentIndex] then
        local filename = string.format("%s/gameplay_%02d_frame_%04d.png", outputDir, currentIndex, currentFrame)
        gui.savescreenshotas(filename)
        print(string.format("[Frame %04d] Screenshot %d/%d saved: %s", 
            currentFrame, currentIndex, #screenshotFrames, filename))
        currentIndex = currentIndex + 1
    end
    
    -- Exit conditions
    if currentFrame >= maxFrames then
        print(string.format("Reached max frames (%d). Exiting.", maxFrames))
        break
    end
    
    if currentIndex > #screenshotFrames then
        print("All screenshots captured. Exiting.")
        break
    end
    
    -- Safety timeout (5 minutes)
    if os.time() - startTime > 300 then
        print("Timeout reached. Exiting.")
        break
    end
    
    emu.frameadvance()
end

print("Screenshot capture complete!")
os.exit(0)
