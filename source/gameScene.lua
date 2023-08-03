import "gameOverScene"
import "player"
import "map"

local pd <const> = playdate
local gfx <const> = playdate.graphics

PLAYER = nil
MAP = nil
CAN_DIG = false

class('GameScene').extends(gfx.sprite)

function GameScene:init()
    PLAYER = Player()
    MAP = Map()
    self:add()
    MAP:updateSprites()
    PLAYER:updateHud()
end

function GameScene:update()
    if pd.buttonJustPressed(pd.kButtonA) then
        MAP:saveMap()
        SCENE_MANAGER:switchScene(GameOverScene)
    end
end