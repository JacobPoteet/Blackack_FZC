local play = {}

local tableImage -- Variable to hold the table image
local cardBaseImage -- Base card image for the card
local cardFont -- Font for card ranks and suits
local suits = { "♠", "♣", "♦", "♥" } -- Suits: Spades, Clubs, Diamonds, Hearts
local ranks = { "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K" } -- Card ranks
local displayedCard = nil -- Card to display
local dealButton = {} -- Deal button properties
local hitButton = {} -- Hit button properties
local standButton = {} -- Stand button properties
local resetButton = {} -- Reset button properties
local stackedCards = {} -- Table to hold all generated cards
local totalValue = 0 -- Total value of the cards
local dealerHand = {} -- Table to hold the dealer's cards
local dealerActionTimer = 0 -- Timer to manage delays for dealer actions
local dealerActionState = "reveal" -- State to track dealer actions ("reveal", "draw", or "done")

function play.load()
    print("Starting the game...")

    -- Seed the random number generator
    math.randomseed(os.time())

    -- Load the table image
    tableImage = love.graphics.newImage("assets/table.png") -- Adjust the path as needed

    -- Load the base card image
    cardBaseImage = love.graphics.newImage("assets/cardbase.png") -- Replace with the correct path to your card base image

    -- Load a font that supports suit symbols
    cardFont = love.graphics.newFont("assets/BIZUDPGothic-Bold.ttf", 36) -- Replace with the correct path to a font that supports Unicode
    love.graphics.setFont(cardFont)

    -- Initialize the hit button
    local screenWidth, screenHeight = love.graphics.getDimensions()
    hitButton = {
        x = screenWidth / 2 - 150,
        y = screenHeight - 100,
        width = 100,
        height = 50,
        label = "Hit"
    }

    -- Initialize the stand button
    standButton = {
        x = screenWidth / 2 + 50,
        y = screenHeight - 100,
        width = 100,
        height = 50,
        label = "Stand"
    }

    -- Initialize the reset button
    resetButton = {
        x = screenWidth - 150, -- Position on the right side of the screen
        y = screenHeight - 100,
        width = 100,
        height = 50,
        label = "Reset"
    }

    -- Generate the dealer's hand
    play.generateDealerHand()
end

function play.draw()
    -- Draw the table image
    if tableImage then
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local imageWidth, imageHeight = tableImage:getDimensions()
        love.graphics.draw(tableImage, (screenWidth - imageWidth) / 2, (screenHeight - imageHeight) / 2)
    end

    -- Draw the dealer's hand
    local dealerX = 700 -- Starting x position for the dealer's cards
    local dealerY = 50 -- y position for the dealer's cards
    for i, card in ipairs(dealerHand) do
        if card.hidden then
            -- Draw the back of the card for hidden cards
            love.graphics.setColor(0.2, 0.2, 0.8) -- Blue color for the card back
            love.graphics.rectangle("fill", dealerX, dealerY, cardBaseImage:getWidth(), cardBaseImage:getHeight())
        else
            -- Draw the card face
            love.graphics.draw(cardBaseImage, dealerX, dealerY)

            -- Set the color for the suit (red for Diamonds and Hearts, black for Spades and Clubs)
            if card.suit == "♦" or card.suit == "♥" then
                love.graphics.setColor(1, 0, 0) -- Red
            else
                love.graphics.setColor(0, 0, 0) -- Black
            end

            -- Draw the rank and suit in the top-left corner
            love.graphics.print(card.rank, dealerX + 20, dealerY + 20)
            love.graphics.print(card.suit, dealerX + 20, dealerY + 60)
        end

        -- Move to the next card position
        dealerX = dealerX + cardBaseImage:getWidth() + 20
    end

    -- Reset the color to white to avoid affecting other elements
    love.graphics.setColor(1, 1, 1)

    -- Draw the hit button
    love.graphics.setColor(0.2, 0.6, 0.2) -- Green color for the button
    love.graphics.rectangle("fill", hitButton.x, hitButton.y, hitButton.width, hitButton.height)
    love.graphics.setColor(1, 1, 1) -- White color for the text
    love.graphics.printf(hitButton.label, hitButton.x, hitButton.y + 15, hitButton.width, "center")

    -- Draw the stand button
    love.graphics.setColor(0.2, 0.6, 0.2) -- Green color for the button
    love.graphics.rectangle("fill", standButton.x, standButton.y, standButton.width, standButton.height)
    love.graphics.setColor(1, 1, 1) -- White color for the text
    love.graphics.printf(standButton.label, standButton.x, standButton.y + 15, standButton.width, "center")

    -- Draw the reset button
    love.graphics.setColor(0.2, 0.6, 0.2) -- Green color for the button
    love.graphics.rectangle("fill", resetButton.x, resetButton.y, resetButton.width, resetButton.height)
    love.graphics.setColor(1, 1, 1) -- White color for the text
    love.graphics.printf(resetButton.label, resetButton.x, resetButton.y + 15, resetButton.width, "center")

    -- Display the dealer's total if all cards are revealed
    if dealerTotal then
        love.graphics.setColor(1, 1, 1) -- White color for the text
        love.graphics.printf("Dealer Total: " .. dealerTotal, 0, 20, love.graphics.getWidth(), "center")
    end

    -- Draw all stacked cards (player's hand)
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

    -- Display the total value above the cards
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

    -- Display the game result (Win or Lose)
    if gameResult then
        love.graphics.setColor(1, 1, 0) -- Yellow color for the result
        love.graphics.printf(gameResult, 0, love.graphics.getHeight() / 2 + 50, love.graphics.getWidth(), "center")
    end
end

-- Function to generate a random card
function play.generateRandomCard()
    local randomRank = ranks[math.random(#ranks)]
    local randomSuit = suits[math.random(#suits)]
    local cardX = hitButton.x + 50 -- Start near the center of the "Hit" button
    local cardY = hitButton.y - 390 -- Position above the buttons

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

function play.generateDealerHand()
    dealerHand = {
        { rank = ranks[math.random(#ranks)], suit = suits[math.random(#suits)], hidden = false },
        { rank = ranks[math.random(#ranks)], suit = suits[math.random(#suits)], hidden = true }
    }
end

function play.stand()
    -- Flip the dealer's hidden card
    for _, card in ipairs(dealerHand) do
        card.hidden = false
    end

    -- Calculate the dealer's total
    dealerTotal = 0
    for _, card in ipairs(dealerHand) do
        local cardValue = 0
        if card.rank == "A" then
            cardValue = 11
        elseif card.rank == "K" or card.rank == "Q" or card.rank == "J" then
            cardValue = 10
        else
            cardValue = tonumber(card.rank)
        end
        dealerTotal = dealerTotal + cardValue
    end

    -- Dealer must draw cards if their total is 16 or under
    while dealerTotal <= 16 do
        local randomRank = ranks[math.random(#ranks)]
        local randomSuit = suits[math.random(#suits)]
        local cardValue = 0

        if randomRank == "A" then
            cardValue = 11
        elseif randomRank == "K" or randomRank == "Q" or randomRank == "J" then
            cardValue = 10
        else
            cardValue = tonumber(randomRank)
        end

        -- Add the new card to the dealer's hand
        table.insert(dealerHand, { rank = randomRank, suit = randomSuit, hidden = false })
        dealerTotal = dealerTotal + cardValue
    end

    -- Determine win or lose
    if totalValue > dealerTotal and totalValue <= 21 then
        gameResult = "Win"
    elseif totalValue < dealerTotal and dealerTotal <= 21 then
        gameResult = "Lose"
    elseif totalValue > 21 then
        gameResult = "Lose" -- Player busts
    elseif dealerTotal > 21 then
        gameResult = "Win" -- Dealer busts
    else
        gameResult = "Tie" -- Optional: Handle ties
    end
end

function play.reset()
    -- Reset the player's hand and total value
    stackedCards = {}
    totalValue = 0

    -- Reset the dealer's hand and total value
    play.generateDealerHand()
    dealerTotal = nil

    -- Reset the game result
    gameResult = nil
end

-- Handle mouse clicks
function play.mousepressed(x, y, button)
    if button == 1 then
        -- Check if the click is inside the hit button
        if x >= hitButton.x and x <= hitButton.x + hitButton.width and
           y >= hitButton.y and y <= hitButton.y + hitButton.height then
            play.generateRandomCard() -- Generate a new card
        end

        -- Check if the click is inside the stand button
        if x >= standButton.x and x <= standButton.x + standButton.width and
           y >= standButton.y and y <= standButton.y + standButton.height then
            play.stand() -- Flip the dealer's hidden card and calculate total
        end

        -- Check if the click is inside the reset button
        if x >= resetButton.x and x <= resetButton.x + resetButton.width and
           y >= resetButton.y and y <= resetButton.y + resetButton.height then
            play.reset() -- Reset the game state
        end
    end
end

return play