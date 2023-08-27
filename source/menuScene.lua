import "gameScene"
import "cutScene"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('MenuScene').extends(gfx.sprite)

local background <const> = gfx.image.new("Images/title")
local cursorImage <const> = gfx.image.new("Images/cursor")

local menuChoices <const> = {
    {
        text_fr = "Nouvelle partie",
        text_en = "New game",
        scene = GameScene,
        options = {
            loadGame = false
        }
    },
    {
        text_fr = "Continuer partie",
        text_en = "Continue game",
        scene = GameScene,
        options = {
            loadGame = true
        }
    },
    {
        text_fr = "Switch to english",
        text_en = "Passer au francais",
        scene = nil,
        options = nil,
        action = "toggleLang"
    },
    {
        text_fr = "Revoir l'intro",
        text_en = "Replay intro",
        scene = CutScene,
        options = {
            sceneName = "intro",
            nextScene = MenuScene,
            nextSceneOptions = {
                introSeen = true
            }
        }
    }
}

function MenuScene:init(options)
    self.menuImage = gfx.image.new(400, 240)
    self.currentChoice = 1
    self.sprite = gfx.sprite.new(self.menuImage)
    self.sprite:moveTo(200, 120)
    self.sprite:add()
    self.cursor = gfx.sprite.new(cursorImage)
    self.cursor:add()
    self:add()
    self:drawMenu()
    if options ~= nil and options.introSeen then
        SCENE_MANAGER.introSeen = true
        SCENE_MANAGER:saveSettings()
    end
end

function MenuScene:setCursorPosition()
    if self.currentChoice == 0 then self.currentChoice = #menuChoices end
    if self.currentChoice > #menuChoices then self.currentChoice = 1 end
    local item <const> = menuChoices[self.currentChoice]
    local textSize = gfx.getTextSize(item["text_" .. SCENE_MANAGER.lang])
    self.cursor:moveTo(180 - math.floor(textSize/2), self.currentChoice * 25 + 50)
end

function MenuScene:action()
    local currentItem = menuChoices[self.currentChoice]
    if currentItem.action ~= nil then
        self[currentItem.action](self)
    else
        SCENE_MANAGER:switchScene(currentItem.scene, currentItem.options)
    end
end

function MenuScene:toggleLang()
    SCENE_MANAGER:toggleLang()
    self:drawMenu()
end


function MenuScene:drawMenu()
    gfx.pushContext(self.menuImage)
        gfx.clear()
        background:draw(0, 0)
        gfx.drawTextAligned("Menu", 200, 10, kTextAlignment.center)
        gfx.drawTextAligned("Menu", 201, 11, kTextAlignment.center)
        for idx, item in ipairs(menuChoices) do
            gfx.drawTextAligned(item["text_" .. SCENE_MANAGER.lang], 200, 40 + 25 * idx, kTextAlignment.center)
        end
    gfx.popContext()
    self:setCursorPosition()
    self.sprite:setImage(self.menuImage)
end

function MenuScene:update()
    if pd.buttonJustPressed(pd.kButtonDown) then
        self.currentChoice += 1
        self:setCursorPosition()
    elseif pd.buttonJustPressed(pd.kButtonUp) then
        self.currentChoice += -1
        self:setCursorPosition()
    elseif pd.buttonJustPressed(pd.kButtonA) then
        self:action()
    end
end