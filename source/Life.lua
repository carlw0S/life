import "CoreLibs/graphics"
import "CoreLibs/object"

import "./globals"



class("Life").extends()

-- Constants

local CELL_SIZES <const> = {1, 2, 4, 5, 8, 10, 16, 20, 40, 80}
N_LIFE_SIZES = #CELL_SIZES

-- Public functions

function Life:init(iCellSize)
    self.cellSize = CELL_SIZES[iCellSize]
    self.xEnd = PLAYDATE_W - self.cellSize
    self.yEnd = PLAYDATE_H - self.cellSize
    self.neighborsOffsets = {-self.cellSize, 0, self.cellSize}
    self.grid = {}
    self.nextGrid = {}
    self:_initGrids()
    self.savedGrids = {}
end

-- Returns the number of generations advanced (positive) or restored (negative)
function Life:update(nGens)
    if nGens > 0 then
        for _ = 1, nGens do
            self:_advance()
        end
        return nGens -- Advanced generations
    elseif nGens < 0 then
        if #self.savedGrids > 0 then
            return self:_restore(-nGens) -- Restored generations
        end
    end
    return 0 -- No changes
end

function Life:draw()
    for i = 0, self.xEnd, self.cellSize do
        for j = 0, self.yEnd, self.cellSize do
            if self.grid[i][j] == 1 then
                gfx.fillRect(i, j, self.cellSize, self.cellSize)
            end
        end
    end
end



-- Private functions

-- > init

function Life:_initGrids()
    -- I'm using sparse arrays to avoid doing too many calculations with indices hehe
    for i = 0, self.xEnd, self.cellSize do
        self.grid[i] = {}
        self.nextGrid[i] = {}
        for j = 0, self.yEnd, self.cellSize do
            self.grid[i][j] = self:_spawnNewCell()
            self.nextGrid[i][j] = 0
        end
    end
end

function Life:_spawnNewCell()
    return math.random(0, 1)
end

-- > update

function Life:_advance()
    local nSaved = #self.savedGrids + 1
    self.savedGrids[nSaved] = {}
    for i = 0, self.xEnd, self.cellSize do
        self.savedGrids[nSaved][i] = {}
        for j = 0, self.yEnd, self.cellSize do
            self.savedGrids[nSaved][i][j] = self.grid[i][j]
            self:_advanceCell(i, j)
        end
    end
    self.grid, self.nextGrid = self.nextGrid, self.grid
end

function Life:_advanceCell(x, y)
    local neighbors = self:_count(x, y)
    if neighbors == 3 then
        self.nextGrid[x][y] = 1
    elseif neighbors == 2 then
        self.nextGrid[x][y] = self.grid[x][y]
    else
        self.nextGrid[x][y] = 0
    end
end

function Life:_count(x, y)
    local count = -self.grid[x][y] -- To avoid counting the cell itself
    for _, i in ipairs(self.neighborsOffsets) do
        i = (x + i) % PLAYDATE_W
        for _, j in ipairs(self.neighborsOffsets) do
            j = (y + j) % PLAYDATE_H
            if self.grid[i][j] == 1 then
                count += 1
            end
        end
    end
    return count
end

function Life:_restore(n)
    local nSavedGrids = #self.savedGrids
    local iGen = nSavedGrids - (n - 1)
    iGen = (iGen > 0) and iGen or 1 -- Using kind of a ternary operator
    for i = 0, self.xEnd, self.cellSize do
        for j = 0, self.yEnd, self.cellSize do
            self.grid[i][j] = self.savedGrids[iGen][i][j]
        end
    end
    for k = nSavedGrids, iGen, -1 do
        self.savedGrids[k] = nil
    end
    return nSavedGrids - (iGen - 1)
end
