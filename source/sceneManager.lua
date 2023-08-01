-- Scene manager
-- based on awesome video by SquidGod
-- https://www.youtube.com/watch?v=3LoMft137z8
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('SceneManager').extends()

function SceneManager:switchScene(scene)
    self.newScene = scene
    self:loadNewScene()
end

function SceneManager:loadNewScene()
    self:cleanupScene()
    self.newScene()
end

function SceneManager:cleanupScene()
    gfx.sprite.removeAll()
    self:removeAllTimers()
    gfx.setDrawOffset(0, 0)
end

function SceneManager:removeAllTimers()
    local allTimers = pd.timer.allTimers()
    if allTimers == nil then
        return
    end
    for _, timer in ipairs(allTimers) do
        timer:remove()
    end
end