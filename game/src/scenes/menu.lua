local constants = require("src.constants")
local menu = {}

local options = { "Play", "Settings", "Exit" }
local selectedIndex = 1

function menu.load()
    menu.font = love.graphics.newFont(24)
    love.graphics.setFont(menu.font)
end

function menu.update(dt)
    if love.keyboard.isDown("up") then
        selectedIndex = selectedIndex > 1 and selectedIndex - 1 or #options
    elseif love.keyboard.isDown("down") then
        selectedIndex = selectedIndex < #options and selectedIndex + 1 or 1
    elseif love.keyboard.isDown("return") then
        menu.selectOption(selectedIndex)
    end
end

function menu.draw()
    for i, option in ipairs(options) do
        if i == selectedIndex then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.printf(option, 0, 100 + (i - 1) * 50, love.graphics.getWidth(), "center")
    end
end

function menu.mousepressed(x, y, button)
    if button == 1 then
        for i, option in ipairs(options) do
            local textWidth = menu.font:getWidth(option)
            local textHeight = menu.font:getHeight()
            local textX = (love.graphics.getWidth() - textWidth) / 2
            local textY = 100 + (i - 1) * 50

            local padding = 10
            if x >= textX - padding and x <= textX + textWidth + padding and
               y >= textY - padding and y <= textY + textHeight + padding then
                menu.selectOption(i)
            end
        end
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