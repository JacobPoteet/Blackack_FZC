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

    -- Load the background image
    menu.background = love.graphics.newImage("assets/greenfabric.png") -- Replace with the correct path to greenfabric.png

    -- Define specific colors for chips
    local predefinedColors = {
        {0.608, 0.224, 0.231}, -- Red
        {0.11, 0.463, 0.294}, -- Green
        {0.188, 0.231, 0.486}, -- Blue
        {0.835, 0.706, 0.267}, -- Yellow
        {0.969, 0.969, 0.969}, -- White
        {0.035, 0.047, 0.063}  -- Black
    }

    -- Load the chip image and symbols image
    local chipImage = love.graphics.newImage("assets/chip.png") -- Base chip image
    local symbolsImage = love.graphics.newImage("assets/whitesymbols.png") -- White symbols image

    -- Only spawn chips if the `chips` table is empty
    if #chips == 0 then
        local screenWidth, screenHeight = love.graphics.getDimensions()

        for i = 1, numChips do
            local chip = {
                image = chipImage, -- Use the base chip image
                symbols = symbolsImage, -- White symbols image
                x = math.random(50, screenWidth - 50), -- Random initial x position with padding
                y = math.random(50, screenHeight - 50), -- Random initial y position with padding
                width = chipImage:getWidth() * 0.2, -- Scale the width
                height = chipImage:getHeight() * 0.2, -- Scale the height
                dx = math.random(-100, 100), -- Random horizontal velocity
                dy = math.random(-100, 100), -- Random vertical velocity
                color = predefinedColors[(i - 1) % #predefinedColors + 1] -- Assign colors in a round-robin manner
            }
            table.insert(chips, chip)
        end
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
    -- Draw the background image
    love.graphics.setColor(1, 1, 1, 1) -- Reset color to white to ensure the image is drawn correctly
    love.graphics.draw(menu.background, 0, 0) -- Draw the background image at the top-left corner

    -- Draw all chips
    for _, chip in ipairs(chips) do
        -- Draw the drop shadow
        love.graphics.setColor(0, 0, 0, 0.5) -- Semi-transparent black for the shadow
        love.graphics.draw(chip.image, chip.x + 2, chip.y + 2, 0, 0.2, 0.2) -- Offset the shadow slightly

        -- Draw the base chip with its color
        love.graphics.setColor(chip.color[1], chip.color[2], chip.color[3], 1) -- Apply the chip's color
        love.graphics.draw(chip.image, chip.x, chip.y, 0, 0.2, 0.2) -- Scale the chip to 20% of its original size

        -- Draw the white symbols on top of the chip
        love.graphics.setColor(1, 1, 1, 1) -- Reset to white for the symbols
        love.graphics.draw(chip.symbols, chip.x, chip.y, 0, 0.2, 0.2) -- Scale the symbols to match the chip
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

        -- Check if the mouse is hovering over the option
        local mouseX, mouseY = love.mouse.getPosition()
        local isHovered = mouseX >= x and mouseX <= x + textWidth and mouseY >= y and mouseY <= y + textHeight

        -- Apply hover effects
        if isHovered then
            love.graphics.setColor(1, 1, 0) -- Highlight the selected option
            love.graphics.setFont(love.graphics.newFont(60)) -- Increase font size for hover effect
        else
            love.graphics.setColor(1, 1, 1) -- Default color
            love.graphics.setFont(menu.font) -- Reset to default font size
        end

        -- Draw black outline for the text
        love.graphics.setColor(0, 0, 0) -- Black color for the outline
        love.graphics.print(option, x - 3, y) -- Left outline
        love.graphics.print(option, x + 3, y) -- Right outline
        love.graphics.print(option, x, y - 3) -- Top outline
        love.graphics.print(option, x, y + 3) -- Bottom outline

        -- Draw the actual text on top of the outline
        love.graphics.setColor(1, 1, 1) -- White color for the text
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
        menu.music:stop() -- Stop the music when exiting
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