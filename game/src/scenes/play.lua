local play = {}

local tableImage -- Variable to hold the table image

function play.load()
    print("Starting the game...")
    -- Load the table image
    tableImage = love.graphics.newImage("assets/table.png") -- Adjust the path as needed
    print("Game in progress...")
end

function play.draw()
    if tableImage then
        -- Draw the table image at the center of the screen
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local imageWidth, imageHeight = tableImage:getDimensions()
        love.graphics.draw(tableImage, (screenWidth - imageWidth) / 2, (screenHeight - imageHeight) / 2)
    end
end

return play