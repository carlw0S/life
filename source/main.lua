import "CoreLibs/crank"

import "./globals"
import "./Life"



-- Main variables

local life

local DEFAULT_LIFE_SIZE <const> = 7
local DEFAULT_TICKS_PER_REVOLUTION <const> = 6

-- > Options

local lifeSize = DEFAULT_LIFE_SIZE
local ticksPerRevolution = DEFAULT_TICKS_PER_REVOLUTION
local autoPlayGens = 0



-- Main functions

local function resetLife()
    life = Life(lifeSize)
    autoPlayGens = 0
end

local function initGame()
    playdate.display.setRefreshRate(50)
    math.randomseed(playdate.getSecondsSinceEpoch())
    resetLife()
end

local function processPlayerInput()
    -- Set auto play/rewind
    if playdate.buttonJustPressed(playdate.kButtonA) then
        autoPlayGens = (autoPlayGens ~= 1) and 1 or 0
        -- autoPlayGens = (autoPlayGens < 0) and 0 or (autoPlayGens + 1)
    elseif playdate.buttonJustPressed(playdate.kButtonB) then
        autoPlayGens = (autoPlayGens ~= -1) and -1 or 0
        -- autoPlayGens = (autoPlayGens > 0) and 0 or (autoPlayGens - 1)
    end
    -- Change cell size
    if playdate.buttonJustPressed(playdate.kButtonUp) then
        if lifeSize < N_LIFE_SIZES then
            lifeSize += 1
            resetLife()
        end
    elseif playdate.buttonJustPressed(playdate.kButtonDown) then
        if lifeSize > 1 then
            lifeSize -= 1
            resetLife()
        end
    end
    -- Reset
    if playdate.buttonJustPressed(playdate.kButtonLeft) then
        resetLife()
    end
end

local function updateGame()
    if autoPlayGens == 0 then
        life:update(playdate.getCrankTicks(ticksPerRevolution))
    else
        if not life:update(autoPlayGens) then
            autoPlayGens = 0
        end
    end
end

local function drawGame()
    gfx.clear()
    life:draw()
    playdate.drawFPS(0,0)
end



-- Main logic

initGame()

function playdate.update()
    processPlayerInput()
    updateGame()
    drawGame()
end
