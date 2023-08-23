import "CoreLibs/timer"

import "cutScene"
import "menuScene"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('HomeScene').extends(gfx.sprite)

local background <const> = gfx.image.new("Images/title")
local buttonAImage <const> = gfx.image.new("Images/buttonA")

function HomeScene:init(_)
    self.sprite = gfx.sprite.new(background)
    self.sprite:moveTo(200, 120)
    self.sprite:add()
    self.buttonASprite = gfx.sprite.new(buttonAImage)
    self.buttonASprite:moveTo(200, 100)
    self.buttonASprite:add()
    self:blink()
    self:add()
end

function HomeScene:blink()
    self.buttonASprite:setVisible(not self.buttonASprite:isVisible())
    pd.timer.performAfterDelay(500, self.blink, self)
end

function HomeScene:update()
    if pd.buttonJustPressed(pd.kButtonA) then
        if SCENE_MANAGER.introSeen then
            SCENE_MANAGER:switchScene(MenuScene, nil)
        else
            SCENE_MANAGER:switchScene(CutScene, {
                sceneName = "intro",
                nextScene = MenuScene,
                nextSceneOptions = {
                    introSeen = true
                }
            })
        end
    end
end