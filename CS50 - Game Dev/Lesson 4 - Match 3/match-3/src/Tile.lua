--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety, block)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety
    self.block = block
    if math.random(100)/100 <= 0.3 then
        self.diamond = true
    else
        self.diamond = false
    end

    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)
    self.psystem:setParticleLifetime(0.5, 1)
    self.psystem:setLinearAcceleration(0, 0, 0, 0)
    self.psystem:setEmissionArea('normal', 5, 5)

    self.psystem:setColors(
        255 / 255,
        255 / 255,
        255 / 255,
        55 / 255
    )
    self.psystem:emit(64)
end

function Tile:update(dt)
    self.psystem:update(dt)
end

function Tile:emitNew(x)
    self.psystem:emit(x)
end


function Tile:render(x, y)
    if not self.block then
    -- draw shadow
        love.graphics.setColor(34, 32, 52, 255)
        love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
            self.x + x + 2, self.y + y + 2)

        -- draw tile itself
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
            self.x + x, self.y + y)
    else
        -- draw shadow
        love.graphics.setColor(34, 32, 52, 0)
        love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
            self.x + x + 2, self.y + y + 2)

        -- draw tile itself
        love.graphics.setColor(255, 255, 255, 0)
        love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
            self.x + x, self.y + y)
    end
end

function Tile:renderParticles()
    if self.diamond and not self.block then
        love.graphics.draw(self.psystem, VIRTUAL_WIDTH - 256 + self.x , self.y + 32)
    end
end