--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = params.balls
    self.level = params.level
    self.powerups = params.powerups
    
    self.lockTimer = 0
    self.recoverPoints = 5000
    self.paddle_increase_points = 1000
    self.powerups_chance = 0.2

    -- give ball random starting velocity
    for k, ball in pairs(self.balls) do
        ball.dx = math.random(-200, 200)
        ball.dy = math.random(-50, -60)
    end 
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    self.lockTimer = self.lockTimer + dt
    if self.lockTimer >= math.random(5,15) then
        local counterLockPowerups = 0
        for k, powerup in pairs(self.powerups) do
            if powerup.type == 10 then
                counterLockPowerups = counterLockPowerups + 1
            end
        end
        if counterLockPowerups == 0 then
            for k, brick in pairs(self.bricks) do 
                if brick.locked == nil then
                    table.insert(self.powerups, Powerup(10, math.random(16, VIRTUAL_WIDTH-16), 0))
                    self.lockTimer = 0
                    break
                end
            end
        end
    end
    -- update positions based on velocity
    self.paddle:update(dt)
    
    for k, ball in pairs(self.balls) do
        ball:update(dt)
    end

    for k, powerup in pairs(self.powerups) do
        powerup:update(dt)
    end

    for i=#self.powerups, 1, -1 do
        if self.powerups[i].type <= 9 and self.powerups[i]:collides(self.paddle) then
            for i = 0, 1 do
                ballX = self.paddle.x + (self.paddle.width / 2) - 4
                ballY = self.paddle.y - 8
                balldx = math.random(-200, 200)
                balldy = math.random(-50, -60)
                table.insert(self.balls, Ball(math.random(7), ballX, ballY, balldx, balldy))
            end
            table.remove(self.powerups, i)
        elseif self.powerups[i].type == 10 and self.powerups[i]:collides(self.paddle) then
            for k, brick in pairs(self.bricks) do
                if brick.locked == 1 then
                    brick.locked = 0
                    break
                end
            end
            table.remove(self.powerups, i)
        elseif self.powerups[i].y > VIRTUAL_HEIGHT + 8 then
            table.remove(self.powerups, i)
        end

    end

    for k, ball in pairs(self.balls) do 
        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()    
        end
    end

    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do
        for n, ball in pairs(self.balls) do  

        -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then
                if brick.locked == nil then 
                -- add to score
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)
                    self.paddle.paddle_gained_score = self.paddle.paddle_gained_score + (brick.tier * 200 + brick.color * 25)
                    if self.paddle.paddle_gained_score > self.paddle_increase_points then
                        self.paddle:increase_size()
                    end
                end

                -- trigger the brick's hit function, which removes it from play
                brick:hit()

                if not brick.inPlay then
                    -- triger new powerup if the brick is destroyed
                    if math.random(0,100)/100 < self.powerups_chance then
                        table.insert(self.powerups, Powerup(math.random(1,9), brick.x+brick.width/2, brick.y+brick.height/2))
                    end
                end 

                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)

                    -- multiply recover points by 2
                    self.recoverPoints = math.min(100000, self.recoverPoints * 2)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = {Ball(math.random(7))},
                        recoverPoints = self.recoverPoints,
                        powerups = {}
                    })
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end
    end

    -- if ball goes below bounds, revert to serve state and decrease health
    for i = #self.balls, 1, -1 do
        if self.balls[i].y >= VIRTUAL_HEIGHT then
            table.remove(self.balls, i)
        end
    end

    if not next(self.balls) then
        self.health = self.health - 1
        self.paddle:decrease_size()
        gSounds['hurt']:play()

        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints,
                powerups = {}
            })
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    for k, ball in pairs(self.balls) do
        ball:render()
    end

    for k, powerup in pairs(self.powerups) do
        powerup:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end