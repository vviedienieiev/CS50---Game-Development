--[[
    GD50
    -- Super Mario Bros. Remake --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Tile = Class{}

function Tile:init(x, y, id, topper, tileset, topperset, flagColor, flagPart)
    self.x = x
    self.y = y

    self.width = TILE_SIZE
    self.height = TILE_SIZE

    self.id = id
    self.tileset = tileset
    self.topper = topper
    self.topperset = topperset
    self.flagColor = flagColor
    self.flagPart = flagPart
end

--[[
    Checks to see whether this ID is whitelisted as collidable in a global constants table.
]]
function Tile:collidable(target)
    for k, v in pairs(COLLIDABLE_TILES) do
        if v == self.id then
            return true
        end
    end

    return false
end

function Tile:render()
    if self.id == 4 then
        love.graphics.draw(gTextures['tiles'], gFrames['tilesets'][self.tileset][TILE_ID_EMPTY],
        (self.x - 1) * TILE_SIZE, (self.y - 1) * TILE_SIZE)

        love.graphics.draw(gTextures['flags'], gFrames['flags'][self.flagColor][self.flagPart],
            (self.x - 1) * TILE_SIZE, (self.y - 1) * TILE_SIZE)
    else
        love.graphics.draw(gTextures['tiles'], gFrames['tilesets'][self.tileset][self.id],
        (self.x - 1) * TILE_SIZE, (self.y - 1) * TILE_SIZE)
    end

    -- tile top layer for graphical variety
    if self.topper then
        love.graphics.draw(gTextures['toppers'], gFrames['toppersets'][self.topperset][self.id],
            (self.x - 1) * TILE_SIZE, (self.y - 1) * TILE_SIZE)
    end
end    
