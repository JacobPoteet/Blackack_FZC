local play = {}

local tableImage -- Variable to hold the table image
local cardBaseImage -- Base card image for the card
local cardFont -- Font for card ranks and suits
local suits = { "♠", "♣", "♦", "♥" } -- Suits: Spades, Clubs, Diamonds, Hearts
local ranks = { "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K" } -- Card ranks
local displayedCard = nil -- Card to display
local dealButton = {} -- Deal button properties
local stackedCards = {} -- Table to hold all generated cards
local totalValue = 0 -- Total value of the cards

function play.load()
    print("Starting the game...")

    -- Load the table image
    tableImage = love.graphics.newImage("assets/table.png") -- Adjust the path as needed

    -- Load the base card image
    cardBaseImage = love.graphics.newImage("assets/cardbase.png") -- Replace with the correct path to your card base image

    -- Load a font that supports suit symbols
    cardFont = love.graphics.newFont("assets/BIZUDPGothic-Bold.ttf", 36) -- Replace with the correct path to a font that supports Unicode
    love.graphics.setFont(cardFont)

    -- Initialize the deal button
    local screenWidth, screenHeight = love.graphics.getDimensions()
    dealButton = {
        x = screenWidth / 2,
        y = screenHeight - 100,
        radius = 50,
        label = "Deal"
    }
end

function play.draw()
    -- Draw the table image
    if tableImage then
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local imageWidth, imageHeight = tableImage:getDimensions()
        love.graphics.draw(tableImage, (screenWidth - imageWidth) / 2, (screenHeight - imageHeight) / 2)
    end

    -- Draw the deal button
    love.graphics.setColor(0.2, 0.6, 0.2) -- Green color for the button
    love.graphics.circle("fill", dealButton.x, dealButton.y, dealButton.radius)
    love.graphics.setColor(1, 1, 1) -- White color for the text
    love.graphics.setFont(cardFont)
    love.graphics.printf(dealButton.label, dealButton.x - dealButton.radius, dealButton.y - 18, dealButton.radius * 2, "center")

    -- Draw all stacked cards
    for _, card in ipairs(stackedCards) do
        love.graphics.draw(cardBaseImage, card.x, card.y)

        -- Set the color for the suit (red for Diamonds and Hearts, black for Spades and Clubs)
        if card.suit == "♦" or card.suit == "♥" then
            love.graphics.setColor(1, 0, 0) -- Red
        else
            love.graphics.setColor(0, 0, 0) -- Black
        end

        -- Draw the rank and suit in the top-left corner
        love.graphics.print(card.rank, card.x + 20, card.y + 20)
        love.graphics.print(card.suit, card.x + 20, card.y + 60)

        -- Draw the rank and suit in the bottom-right corner (rotated 180 degrees)
        love.graphics.push() -- Save the current transformation state
        love.graphics.translate(card.x + cardBaseImage:getWidth() - 20, card.y + cardBaseImage:getHeight() - 60)
        love.graphics.rotate(math.rad(180)) -- Rotate 180 degrees
        love.graphics.print(card.rank, 0, -20)
        love.graphics.print(card.suit, 0, 30)
        love.graphics.pop() -- Restore the previous transformation state

        -- Draw the suit symbol in the middle of the card
        love.graphics.setFont(cardFont) -- Use the same font for the center symbol
        local middleX = card.x + cardBaseImage:getWidth() / 2
        local middleY = card.y + cardBaseImage:getHeight() / 2
        love.graphics.printf(card.suit, middleX - 24, middleY - 24, 48, "center")

        -- Reset the color to white to avoid affecting other elements
        love.graphics.setColor(1, 1, 1)
    end

    -- Draw the total value above the cards
    if #stackedCards > 0 then
        local firstCard = stackedCards[1]
        local totalX = firstCard.x + cardBaseImage:getWidth() / 2
        local totalY = firstCard.y - 50 -- Position above the first card
        love.graphics.setColor(0, 0, 0) -- Black color for the circle
        love.graphics.circle("fill", totalX, totalY, 50) -- Draw a circle
        love.graphics.setColor(1, 1, 1) -- White color for the text
        love.graphics.printf(totalValue, totalX - 25, totalY - 20, 70, "left")
    end

    -- Display "BUST" if the total exceeds 21
    if totalValue > 21 then
        love.graphics.setColor(1, 0, 0) -- Red color for "BUST"
        love.graphics.printf("BUST", 0, love.graphics.getHeight() / 2 - 2, love.graphics.getWidth(), "center")
    end
end

-- Function to generate a random card
function play.generateRandomCard()
    local randomRank = ranks[math.random(#ranks)]
    local randomSuit = suits[math.random(#suits)]
    local cardX = dealButton.x - cardBaseImage:getWidth() / 2
    local cardY = dealButton.y - 400 -- Initial position for the first card

    -- Offset the position slightly for stacking
    if #stackedCards > 0 then
        local lastCard = stackedCards[#stackedCards]
        cardX = lastCard.x + 47 -- Offset to the right
        cardY = lastCard.y + 8 -- Offset downward
    end

    -- Calculate the value of the card
    local cardValue = 0
    if randomRank == "A" then
        cardValue = 11
    elseif randomRank == "K" or randomRank == "Q" or randomRank == "J" then
        cardValue = 10
    else
        cardValue = tonumber(randomRank)
    end

    -- Add the card to the stack and update the total value
    table.insert(stackedCards, { rank = randomRank, suit = randomSuit, x = cardX, y = cardY, value = cardValue })
    totalValue = totalValue + cardValue
end

-- Handle mouse clicks
function play.mousepressed(x, y, button)
    if button == 1 then
        -- Check if the click is inside the deal button
        local dx = x - dealButton.x
        local dy = y - dealButton.y
        if math.sqrt(dx * dx + dy * dy) <= dealButton.radius then
            play.generateRandomCard() -- Generate a new card
        end
    end
end

return play