local settings = {}

local volume = 1 -- Default volume level (1 = 100%)
local options = { "Volume", "Back" }
local selectedIndex = 1

function settings.load()
    settings.font = love.graphics.newFont(50) -- Font for the settings menu
    love.graphics.setFont(settings.font)
end

function settings.update(dt)
    -- Update logic for the settings menu (if needed)
end

function settings.draw()
    -- Do not clear the screen to allow the previous scene to remain visible

    -- Draw the settings menu
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local totalHeight = #options * settings.font:getHeight() + (#options - 1) * 20
    local startY = (screenHeight - totalHeight) / 2

    for i, option in ipairs(options) do
        local text = option
        local textWidth = settings.font:getWidth(option)
        local textHeight = settings.font:getHeight()
        local x = (screenWidth - textWidth) / 2
        local y = startY + (i - 1) * (textHeight + 20)

        -- Highlight the option if the mouse is hovering over it
        local mouseX, mouseY = love.mouse.getPosition()
        if mouseX >= x and mouseX <= x + textWidth and mouseY >= y and mouseY <= y + textHeight then
            love.graphics.setColor(1, 1, 0) -- Highlight the option
            selectedIndex = i -- Update the selected index
        else
            love.graphics.setColor(1, 1, 1) -- Default color
        end

        love.graphics.print(option, x, y)

        -- Draw the volume adjustment for the "Volume" option
        if i == 1 then
            local minusX = x + textWidth + 20 -- Position "-" to the right of "Volume"
            local plusX = minusX + 100 -- Position "+" to the right of "-"
            local plusMinusY = y -- Align "-" and "+" with the "Volume" text

            -- Draw the "-" symbol
            love.graphics.setColor(1, 1, 1) -- White color
            love.graphics.print("-", minusX, plusMinusY)

            -- Draw the "+" symbol
            love.graphics.print("+", plusX, plusMinusY)

            -- Calculate and draw the current volume level (0 to 9)
            local volumeLevel = math.floor(volume * 9) -- Convert volume (0 to 1) to 0 to 9
            local volumeText = tostring(volumeLevel)
            local volumeTextWidth = settings.font:getWidth(volumeText)
            local volumeTextX = (minusX + plusX) / 2 - volumeTextWidth / 2 -- Center the volume level text
            love.graphics.print(volumeText, volumeTextX, plusMinusY)
        end
    end
end

function settings.keypressed(key)
    if key == "up" then
        selectedIndex = selectedIndex - 1
        if selectedIndex < 1 then
            selectedIndex = #options
        end
    elseif key == "down" then
        selectedIndex = selectedIndex + 1
        if selectedIndex > #options then
            selectedIndex = 1
        end
    elseif key == "left" and selectedIndex == 1 then
        -- Decrease volume
        volume = volume - 0.1
        if volume < 0 then
            volume = 0
        end
        love.audio.setVolume(volume) -- Apply the volume change
    elseif key == "right" and selectedIndex == 1 then
        -- Increase volume
        volume = volume + 0.1
        if volume > 1 then
            volume = 1
        end
        love.audio.setVolume(volume) -- Apply the volume change
    elseif key == "return" then
        if selectedIndex == 2 then
            -- Go back to the menu
            SwitchScene(require("src.scenes.menu"))
        end
    end
end

function settings.mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local totalHeight = #options * settings.font:getHeight() + (#options - 1) * 20
        local startY = (screenHeight - totalHeight) / 2

        for i, option in ipairs(options) do
            local textWidth = settings.font:getWidth(option)
            local textHeight = settings.font:getHeight()
            local textX = (screenWidth - textWidth) / 2
            local textY = startY + (i - 1) * (textHeight + 20)

            -- Check if the mouse clicked on an option
            if x >= textX and x <= textX + textWidth and y >= textY and y <= textY + textHeight then
                if i == 1 then
                    -- Calculate positions for "-" and "+" symbols
                    local minusX = textX + textWidth + 50
                    local plusX = minusX + 100
                    local plusMinusY = textY

                    -- Check if the mouse clicked on the "-" symbol
                    if x >= minusX and x <= minusX + settings.font:getWidth("-") and
                       y >= plusMinusY and y <= plusMinusY + settings.font:getHeight() then
                        -- Decrease volume
                        volume = volume - 0.1
                        if volume < 0 then
                            volume = 0
                        end
                        love.audio.setVolume(volume) -- Apply the volume change
                    -- Check if the mouse clicked on the "+" symbol
                    elseif x >= plusX and x <= plusX + settings.font:getWidth("+") and
                           y >= plusMinusY and y <= plusMinusY + settings.font:getHeight() then
                        -- Increase volume
                        volume = volume + 0.1
                        if volume > 1 then
                            volume = 1
                        end
                        love.audio.setVolume(volume) -- Apply the volume change
                    end
                elseif i == 2 then
                    -- Go back to the menu
                    SwitchScene(require("src.scenes.menu"))
                end
            end
        end
    end
end

return settings