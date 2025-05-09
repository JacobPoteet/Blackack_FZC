local constants = require("src.constants")
local menu = {}

local options = { "Play", "Settings", "Exit" }
local selectedIndex = 1
local keyPressed = false -- Debounce flag

function menu.load()
    menu.font = love.graphics.newFont(24)
    love.graphics.setFont(menu.font)
end

function menu.update(dt)
    -- Detect mouse hover
    local mouseX, mouseY = love.mouse.getPosition()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local totalHeight = #options * menu.font:getHeight() + (#options - 1) * 20
    local startY = (screenHeight - totalHeight) / 2

    for i, option in ipairs(options) do
        local textWidth = menu.font:getWidth(option)
        local textHeight = menu.font:getHeight()
        local textX = (screenWidth - textWidth) / 2
        local textY = startY + (i - 1) * (textHeight + 20)

        local padding = 10
        if mouseX >= textX - padding and mouseX <= textX + textWidth + padding and
           mouseY >= textY - padding and mouseY <= textY + textHeight + padding then
            selectedIndex = i -- Update the selected index based on hover
        end
    end

    -- Handle keyboard input
    if not keyPressed then
        if love.keyboard.isDown("up") then
            selectedIndex = selectedIndex > 1 and selectedIndex - 1 or #options
            keyPressed = true
        elseif love.keyboard.isDown("down") then
            selectedIndex = selectedIndex < #options and selectedIndex + 1 or 1
            keyPressed = true
        elseif love.keyboard.isDown("return") then
            menu.selectOption(selectedIndex)
            keyPressed = true
        end
    end

    -- Reset the debounce flag when no keys are pressed
    if not love.keyboard.isDown("up") and not love.keyboard.isDown("down") and not love.keyboard.isDown("return") then
        keyPressed = false
    end
end

function menu.draw()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local totalHeight = #options * menu.font:getHeight() + (#options - 1) * 20 -- Total height of all options with spacing
    local startY = (screenHeight - totalHeight) / 2 -- Start drawing from the center

    for i, option in ipairs(options) do
        local textWidth = menu.font:getWidth(option)
        local textHeight = menu.font:getHeight()
        local x = (screenWidth - textWidth) / 2 -- Center horizontally
        local y = startY + (i - 1) * (textHeight + 20) -- Add spacing between options

        if i == selectedIndex then
            love.graphics.setColor(1, 1, 0) -- Highlight the selected option
        else
            love.graphics.setColor(1, 1, 1) -- Default color
        end

        love.graphics.print(option, x, y)
    end
end

function menu.mousepressed(x, y, button)
    if button == 1 then
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local totalHeight = #options * menu.font:getHeight() + (#options - 1) * 20
        local startY = (screenHeight - totalHeight) / 2

        for i, option in ipairs(options) do
            local textWidth = menu.font:getWidth(option)
            local textHeight = menu.font:getHeight()
            local textX = (screenWidth - textWidth) / 2
            local textY = startY + (i - 1) * (textHeight + 20)

            local padding = 10
            if x >= textX - padding and x <= textX + textWidth + padding and
               y >= textY - padding and y <= textY + textHeight + padding then
                menu.selectOption(i)
            end
        end
    end
end

function menu.keypressed(key)
    if key == "escape" then
        love.event.quit() -- Close the game
    end
end

function menu.selectOption(index)
    if index == 1 then
        SwitchScene(require(constants.SCENES.PLAY))
    elseif index == 2 then
        SwitchScene(require(constants.SCENES.SETTINGS))
    elseif index == 3 then
        SwitchScene(require(constants.SCENES.EXIT))
    end
end

return menu