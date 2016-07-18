local dispatcher = require("dispatcher")
local game = dispatcher.createDispatcher()

function love.load()
end

function love.update(dt)
end

function love.draw()
  love.graphics.print("Hello sailor", 10, 10)
end
