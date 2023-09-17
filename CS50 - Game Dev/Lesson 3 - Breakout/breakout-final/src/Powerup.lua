Powerup = Class()

function Powerup:init(type, x, y)
    self.type = type
    self.x = x
    self.y = y
    self.dy = 30

    self.width = 8
    self.height = 8
end

function Powerup:update(dt)
    self.y = self.y + self.dy * dt
end

function Powerup:collides(target)
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end 

function Powerup:render()
    love.graphics.draw(gTextures['main'], 
        -- multiply color by 4 (-1) to get our color offset, then add tier to that
        -- to draw the correct tier and color brick onto the screen
        gFrames['powerup'][self.type],
        self.x, self.y)
end