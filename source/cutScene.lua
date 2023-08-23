local pd <const> = playdate
local gfx <const> = playdate.graphics

class('CutScene').extends(gfx.sprite)
local buttonAImage <const> = gfx.image.new("Images/buttonA")

function CutScene:init(options)
    self.currentPage = 1
    self.options = options
    self.parameters = json.decodeFile("CutScenes/" .. self.options.sceneName .. "/data.json")
    self.image = gfx.image.new(400, 240)
    self.sprite = gfx.sprite.new(image)
    self.sprite:moveTo(200, 120)
    self.sprite:add()
    self:add()
    self:drawCurrentPage()
end

function CutScene:drawImage(image)
    local imageToDraw <const> = gfx.image.new("CutScenes/" .. self.options.sceneName .. "/" .. image)
    gfx.pushContext(self.image)
    gfx.clear()
    imageToDraw:draw(0, 0)
    gfx.popContext()
    self.sprite:setImage(self.image)
end

function CutScene:drawText(text)
    gfx.pushContext(self.image)
    gfx.clear()
    gfx.setLineWidth(3)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(5, 5, 390, 230, 4)
    gfx.drawTextAligned(text, 200, 10, kTextAlignment.center)
    buttonAImage:drawAnchored(390, 230, 1, 1)
    gfx.popContext()
    self.sprite:setImage(self.image)
end

function CutScene:drawCurrentPage()
    local page = self.parameters[self.currentPage]
    if page.type == "text" then
        self:drawText(page["text_" .. SCENE_MANAGER.lang])
    elseif page.type == "image" then
        self:drawImage(page.name)
    end
end

function CutScene:update()
    if pd.buttonJustPressed(pd.kButtonA) then
        if self.currentPage == #self.parameters then
            SCENE_MANAGER:switchScene(self.options.nextScene, self.options.nextSceneOptions)
        else
            self.currentPage += 1
            self:drawCurrentPage()
        end
    end
end