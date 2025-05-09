local constants = require("src.constants")
local menu = {}

local options = { "Play", "Settings", "Exit" }
local selectedIndex = 1
local keyPressed = false -- Debounce flag

local chips = {} -- Table to hold all chips
local numChips = 30 -- Number of chips to spawn

local lastMouseX, lastMouseY = 0, 0 -- To track the previous mouse position

function menu.load()
    menu.font = love.graphics.newFont(50) -- Increase font size
    love.graphics.setFont(menu.font)

    -- Define specific colors for chips
    local predefinedColors = {
        {1, 0, 0}, -- Red
        {0, 1, 0}, -- Green
        {0, 0, 1}, -- Blue
        {1, 1, 0}, -- Yellow
        {1, 0, 1}, -- Magenta
        {0, 1, 1}  -- Cyan
    }

    -- Load the chip images
    local chipImage = love.graphics.newImage("assets/chip.png") -- Base chip image
    local chipAlphaImage = love.graphics.newImage("assets/chipalpha.png") -- Alpha mask image

    -- Spawn multiple chips
    for i = 1, numChips do
        local chip = {
            baseImage = chipImage, -- Base chip image
            alphaImage = chipAlphaImage, -- Alpha mask image
            x = math.random(100, 700), -- Random initial x position
            y = math.random(100, 500), -- Random initial y position
            width = chipImage:getWidth() * 0.2, -- Scale the width
            height = chipImage:getHeight() * 0.2, -- Scale the height
            dx = math.random(-100, 100), -- Random horizontal velocity
            dy = math.random(-100, 100), -- Random vertical velocity
            color = predefinedColors[(i - 1) % #predefinedColors + 1] -- Assign colors in a round-robin manner
        }
        table.insert(chips, chip)
    end

    -- Initialize the last mouse position
    lastMouseX, lastMouseY = love.mouse.getPosition()
end

function menu.update(dt)
    -- Get the current mouse position
    local mouseX, mouseY = love.mouse.getPosition()

    -- Calculate the mouse velocity
    local mouseDX = mouseX - lastMouseX
    local mouseDY = mouseY - lastMouseY

    -- Update each chip
    for _, chip in ipairs(chips) do
        -- Check if the mouse is near or colliding with the chip
        if mouseX >= chip.x and mouseX <= chip.x + chip.width and
           mouseY >= chip.y and mouseY <= chip.y + chip.height then
            -- Apply the mouse velocity to the chip
            chip.dx = chip.dx + mouseDX * 5 -- Amplify the effect for better movement
            chip.dy = chip.dy + mouseDY * 5
        end

        -- Update chip position based on velocity
        chip.x = chip.x + chip.dx * dt
        chip.y = chip.y + chip.dy * dt

        -- Apply friction to gradually stop the chip
        chip.dx = chip.dx * 0.99
        chip.dy = chip.dy * 0.99

        -- Bounce the chip off the screen edges
        local screenWidth, screenHeight = love.graphics.getDimensions()
        if chip.x < 0 then
            chip.x = 0
            chip.dx = -chip.dx
        elseif chip.x + chip.width > screenWidth then
            chip.x = screenWidth - chip.width
            chip.dx = -chip.dx
        end

        if chip.y < 0 then
            chip.y = 0
            chip.dy = -chip.dy
        elseif chip.y + chip.height > screenHeight then
            chip.y = screenHeight - chip.height
            chip.dy = -chip.dy
        end
    end

    -- Detect mouse hover over menu options
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

    -- Handle chip-to-chip collisions
    for i = 1, #chips do
        for j = i + 1, #chips do
            local chipA = chips[i]
            local chipB = chips[j]

            -- Check for collision
            if chipA.x < chipB.x + chipB.width and
               chipA.x + chipA.width > chipB.x and
               chipA.y < chipB.y + chipB.height and
               chipA.y + chipA.height > chipB.y then
                -- Resolve collision by swapping velocities
                chipA.dx, chipB.dx = chipB.dx, chipA.dx
                chipA.dy, chipB.dy = chipB.dy, chipA.dy

                -- Separate the chips to prevent overlap
                local overlapX = math.min(chipA.x + chipA.width - chipB.x, chipB.x + chipB.width - chipA.x)
                local overlapY = math.min(chipA.y + chipA.height - chipB.y, chipB.y + chipB.height - chipA.y)

                if overlapX < overlapY then
                    if chipA.x < chipB.x then
                        chipA.x = chipA.x - overlapX / 2
                        chipB.x = chipB.x + overlapX / 2
                    else
                        chipA.x = chipA.x + overlapX / 2
                        chipB.x = chipB.x - overlapX / 2
                    end
                else
                    if chipA.y < chipB.y then
                        chipA.y = chipA.y - overlapY / 2
                        chipB.y = chipB.y + overlapY / 2
                    else
                        chipA.y = chipA.y + overlapY / 2
                        chipB.y = chipB.y - overlapY / 2
                    end
                end
            end
        end
    end

    -- Update the last mouse position
    lastMouseX, lastMouseY = mouseX, mouseY
end

function menu.draw()
    -- Set the background color
    love.graphics.clear(0.149, 0.302, 0.145) -- Example: Dark green background

    -- Draw all chips
    for _, chip in ipairs(chips) do
        -- Draw the base chip image (white base)
        love.graphics.setColor(1, 1, 1) -- White color
        love.graphics.draw(chip.baseImage, chip.x, chip.y, 0, 0.2, 0.2)

        -- Draw the alpha mask with the chip's color
        love.graphics.setBlendMode("add") -- Use additive blending for brightness
        love.graphics.setColor(chip.color[1], chip.color[2], chip.color[3], 1)
        love.graphics.draw(chip.alphaImage, chip.x, chip.y, 0, 0.2, 0.2)
        love.graphics.setBlendMode("alpha") -- Reset to default blend mode
    end

    -- Draw menu options on top of everything else
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
    elseif index == 2 then
        SwitchScene(require(constants.SCENES.EXIT))
    end
end

return menu