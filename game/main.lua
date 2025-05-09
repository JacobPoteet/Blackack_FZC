local constants = require("src.constants")
local menu = require(constants.SCENES.MENU)
local play = require(constants.SCENES.PLAY)
local settings = require(constants.SCENES.SETTINGS)
local exit = require(constants.SCENES.EXIT)

local currentScene = menu -- Start with the main menu

function love.load()
    currentScene.load()
end

function love.update(dt)
    if currentScene.update then
        currentScene.update(dt)
    end
end

function love.draw()
    if currentScene.draw then
        currentScene.draw()
    end
end

function love.mousepressed(x, y, button)
    if currentScene.mousepressed then
        currentScene.mousepressed(x, y, button)
    end
end

function love.keypressed(key)
    if key == "escape" then
        -- Return to the main menu
        SwitchScene(menu)
    elseif currentScene.keypressed then
        -- Pass the keypress to the current scene
        currentScene.keypressed(key)
    end
end

-- Function to switch scenes
function SwitchScene(scene)
    if currentScene.unload then
        currentScene.unload() -- Unload the current scene if it has an unload function
    end
    currentScene = scene
    if currentScene.load then
        currentScene.load()
    end
end