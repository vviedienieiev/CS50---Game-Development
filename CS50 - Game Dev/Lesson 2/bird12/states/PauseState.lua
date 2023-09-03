PauseState = Class{__includes = BaseState}

function PauseState:enter(params)
    self.params = params
end

function PauseState:update(dt)
    if love.keyboard.wasPressed('q') then
        gStateMachine:change('play', {
            bird = self.params["bird"],
            pipePairs = self.params["pipePairs"],
            pipe_interval = self.params["pipe_interval"],
            timer = self.params["timer"],
            score = self.params["score"],
            lastY = self.params["lastY"]
        })
    end
end

function PauseState:render()
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Pause', 0, 64, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Score: ' .. tostring(self.params["score"]), 0, 100, VIRTUAL_WIDTH, 'center')
end