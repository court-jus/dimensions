import "CoreLibs/graphics"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Dialog').extends(gfx.sprite)

local buttonBImage <const> = gfx.image.new("Images/buttonB")

function Dialog:init(text_or_list)
    self.text_or_list = text_or_list
    self.currentItem = 1
    self.sprite = gfx.sprite.new(gfx.image.new(360, 200))
    --self.sprite:setCenter(160, 100)
    self.sprite:moveTo(200, 120)
    self.sprite:setZIndex(1000)
    self.sprite:setVisible(true)
    self.sprite:add()
    self:add()
    local text = nil
    if type(self.text_or_list) == "table" then
        text = self.text_or_list[self.currentItem]
    else
        text = self.text_or_list
    end
    self:setText(text)
end

function Dialog:setText(text)
    local image = self.sprite:getImage()
    gfx.pushContext(image)
    gfx.clear()
    gfx.setLineWidth(3)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, 360, 200)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(5, 5, 350, 190, 4)
    gfx.drawTextAligned(text, 10, 10, kTextAlignment.left)
    buttonBImage:drawAnchored(350, 190, 1, 1)
    gfx.popContext()
    self.sprite:setImage(image)
end

function Dialog:update()
    if pd.buttonJustPressed(pd.kButtonB) then
        if type(self.text_or_list) == "table" then
            self.currentItem += 1
            if self.currentItem > #self.text_or_list then
                self:dismiss()
            else
                self:setText(self.text_or_list[self.currentItem])
            end
        else
            self:dismiss()
        end
    end
end

function Dialog:dismiss()
    self.sprite:remove()
    self:remove()
    MAP.visibleDialog = nil
end
