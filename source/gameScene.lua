import "gameOverScene"
import "menuScene"
import "player"
import "map"

local pd <const> = playdate
local gfx <const> = playdate.graphics

PLAYER = nil
MAP = nil

class('GameScene').extends(gfx.sprite)

function GameScene:init(options)
    PLAYER = Player()
    if options.loadGame then
        MAP = Map({loadGame=true})
    else
        MAP = Map({loadGame=false})
    end
    self:add()
    MAP:updateSprites()
    PLAYER:updateHud()
    local menu = pd.getSystemMenu()

    menu:addMenuItem("Save map", function()
        MAP:saveMap()
    end)

    menu:addMenuItem("to menu", function()
        SCENE_MANAGER:switchScene(MenuScene, nil)
    end)

    menu:addCheckmarkMenuItem("Editor", PLAYER.flags.levelEditor, function(value)
        PLAYER.flags.levelEditor = value
        PLAYER:updateHud()
    end)
end


function GameScene:update()
end