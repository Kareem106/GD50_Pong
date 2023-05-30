-- get the required classes
Class = require 'class'
require 'Paddle'
require 'Ball'
push = require 'push'

--initial window size
window_width = 1280
window_height = 720
-- in game resolution
game_width = 432
game_height = 243

paddle_speed=200

--load funtion called when the game started
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())
    -- define all the fonts used 
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)
    -- store all the sounds will be used in the game inside a table
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    -- setup the game screen width and heigh and the resolution
    push:setupScreen(game_width, game_height, window_width, window_height, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })
    love.window.setTitle("Pong")
    -- players score
    player1Score=0
    player2Score=0
    -- served player
    servingPlayer=1
    --create the paddles instance
    player1=Paddle(10,30,5,30)
    player2=Paddle(game_width-15,game_height-50,5,30)
    winningPlayer=0
    --the ball instance
    ball=Ball(game_width/2-2,game_height /2-2,4,4)
    gameState = 'start'
end
-- this funtion used to make the game window resizable
function love.resize(w, h)
    push:resize(w, h)
end
-- check enter and escape key press to start or quit the game
function love.keypressed(key)
    if key== 'escape' then
        love.event.quit()
    elseif key=='enter' or key == 'return' then
        if gameState=='start'then
            gameState='serve'
        elseif gameState=='serve' then
            gameState = 'play'
        elseif gameState=='done' then
            gameState='serve'
            ball:reset()
            player1Score=0
            player2Score=0
            
            if winningPlayer==1 then
                servingPlayer=2
            else
                servingPlayer=1
            end
        end
    end
end
function love.update(dt)
    if gameState=='serve' then
        ball.dy=math.random(-50,50)
        if servingPlayer==1 then
            ball.dx=math.random(140,200)
        else
            ball.dx=-math.random(140,200)
        end
    elseif gameState=='play' then
        --left paddle collides with the ball
        if ball:collides(player1) then
            ball.dx=-ball.dx * 1.03
            ball.x=player1.x + 5
            if ball.dy < 0 then
                ball.dy=-math.random(10,150)
            else
                ball.dy=math.random(10,150)
            end
            sounds['paddle_hit']:play()
        end
        -- right paddle collides with the ball
        if ball:collides(player2) then
            ball.dx=-ball.dx * 1.03
            ball.x=player2.x - 4
            if ball.dy < 0 then
                ball.dy=-math.random(10,150)
            else
                ball.dy=math.random(10,150)
            end
            sounds['paddle_hit']:play()
        end
        -- upper and lower screen collistion
        if ball.y <= 0 then
            ball.y=0
            ball.dy=-ball.dy
            sounds['wall_hit']:play()
        end
        if ball.y >= game_height - 4 then
            ball.y=game_height-4
            ball.dy=-ball.dy
            sounds['wall_hit']:play()
        end
        --player 1 serving update
        if ball.x < 0 then
            servingPlayer=1
            player2Score=player2Score + 1
            sounds['score']:play()
            if player2Score==10 then
                winningPlayer=2
                gameState='done'
            else
                gameState='serve'
                ball:reset()
            end
        end
        --player 2 serving update
        if ball.x > game_width then
            servingPlayer=2
            player1Score=player1Score + 1
            sounds['score']:play()
            if player1Score==10 then
                winningPlayer=1
                gameState='done'
            else
                gameState='serve'
                ball:reset()
            end
        end
    end
    --players paddles movement update
    if love.keyboard.isDown('w') then
        player1.dy=-paddle_speed
    elseif love.keyboard.isDown('s') then
        player1.dy=paddle_speed
    else 
        player1.dy=0
    end
    if love.keyboard.isDown('up') then
        player2.dy=-paddle_speed
    elseif love.keyboard.isDown('down') then
        player2.dy=paddle_speed
    else
        player2.dy=0
    end

    if gameState == 'play' then
        ball:update(dt)
    end
    player1:update(dt)
    player2:update(dt)
end



function love.draw()
    push:start()

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
    --display welcome text when the game starts
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, game_width, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, game_width, 'center')

    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, game_width, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, game_width, 'center')

    elseif gameState == 'play' then
        --when the game ends it displays the winner name
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, game_width, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, game_width, 'center')
    end
    displayFPS()
    displayScore()
    --left paddle
    player1:render()
    --right paddle
    player2:render()
    --ball
    ball:render()
    -- end rendering at virtual resolution
    push:finish()
end

--funtion used to display each player score
function displayScore()
    -- score display
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), game_width / 2 - 50,
        game_height / 3)
    love.graphics.print(tostring(player2Score), game_width / 2 + 30,
        game_height / 3)
end

--funtion used to display fps of the game
function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(255, 255, 255, 255)
end