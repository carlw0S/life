import "CoreLibs/crank"

import "./globals"
import "./Life"



-- Main variables

local life

local evolution

local DEFAULT_LIFE_SIZE <const> = 7
local DEFAULT_TICKS_PER_REVOLUTION <const> = 6

local SYNTH <const> = playdate.sound.synth.new(playdate.sound.kWaveSine)
local NOTE_VOLUME <const> = 0.5
local NOTE_LENGTH <const> = 0.005
local FORWARD_NOTE <const> = "B4"
local REWIND_NOTE <const> = "G4"

-- > Options

local lifeSize = DEFAULT_LIFE_SIZE
local ticksPerRevolution = DEFAULT_TICKS_PER_REVOLUTION
local autoPlayGens = 0



-- Main functions

local function resetLife()
    gfx.clear()
    life = Life(lifeSize)
    life:draw()
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
        evolution = life:update(playdate.getCrankTicks(ticksPerRevolution))
    else
        evolution = life:update(autoPlayGens)
        if evolution == 0 then
            autoPlayGens = 0 -- Basically, stop Auto-play when stagnated or rewound to the initial state
        end
    end
end

local function drawGame()
    if evolution ~= 0 then
        gfx.clear()
        life:draw()
        if evolution > 0 then
            SYNTH:playMIDINote(FORWARD_NOTE, NOTE_VOLUME, NOTE_LENGTH)
        else
            SYNTH:playMIDINote(REWIND_NOTE, NOTE_VOLUME, NOTE_LENGTH)
        end
    end
    playdate.drawFPS(0,0)
end



-- Main logic

initGame()

function playdate.update()
    processPlayerInput()
    updateGame()
    drawGame()
end
