local constants = {}

constants.SCENES = {
    MENU = "src.scenes.menu",
    PLAY = "src.scenes.play",
    SETTINGS = "src.scenes.settings",
    EXIT = "src.scenes.exit"
}
-- Load the background music
    music = love.audio.newSource("assets/BLgamemenumusic.wav", "stream") -- Replace with the correct path to BLgamemenumusic
    music:setLooping(true) -- Loop the music
    music:play() -- Start playing the music
return constants