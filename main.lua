function love.load()
    love.window.setTitle("first love game")
end
function love.draw()
    love.graphics.printf(
        "Pong game",
        0,
        love.graphics.getHeight()/2,
        love.graphics.getWidth(),
        'center')
end