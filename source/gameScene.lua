import "gameOverScene"
import "player"
import "map"

local pd <const> = playdate
local gfx <const> = playdate.graphics

PLAYER = nil
MAP = nil

class('GameScene').extends(gfx.sprite)

function GameScene:init(_)
    PLAYER = Player()
    MAP = Map()
    self:add()
    MAP:updateSprites()
    PLAYER:updateHud()
    local menu = pd.getSystemMenu()
    local items = menu:getMenuItems()
    printTable(items)

    local menuItem, error = menu:addMenuItem("Item 1", function()
        print("Item 1 selected")
    end)

    local checkmarkMenuItem, error = menu:addCheckmarkMenuItem("Editor", PLAYER.flags.levelEditor, function(value)
        PLAYER.flags.levelEditor = value
        print("Level editor: ", value)
    end)
end


function GameScene:update()
    if pd.buttonJustPressed(pd.kButtonA) and (MAP == nil or MAP.visibleDialog == nil) then
        -- act depending on the flags and the system menu
        -- MAP:saveMap()
        SCENE_MANAGER:switchScene(GameOverScene, nil)
    end
end