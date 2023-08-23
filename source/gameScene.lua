import "gameOverScene"
import "player"
import "map"

local pd <const> = playdate
local gfx <const> = playdate.graphics

PLAYER = nil
MAP = nil
CAN_DIG = false

class('GameScene').extends(gfx.sprite)

function GameScene:init(_)
    PLAYER = Player()
    MAP = Map()
    self:add()
    MAP:updateSprites()
    PLAYER:updateHud()
end

function GameScene:update()
    if pd.buttonJustPressed(pd.kButtonA) and (MAP == nil or MAP.visibleDialog == nil) then
        -- MAP:saveMap()
        SCENE_MANAGER:switchScene(GameOverScene, nil)
    end
end