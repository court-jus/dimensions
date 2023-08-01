local pd <const> = playdate
local gfx <const> = playdate.graphics

local itemImage = gfx.image.new("Images/item")

class('Item').extends(gfx.sprite)

function Item:init(v, w, x, y, z)
    self.V = v
    self.W = w
    self.X = x
    self.Y = y
    self.Z = z
    self.sprite = gfx.sprite.new(self:chooseImage())
    self.sprite:moveTo(self.X * 24 - 12, self.Y * 24 - 12)
    self.sprite:setZIndex(50)
    self.sprite:add()
    self:add()
end

function Item:chooseImage()
    return itemImage
end

function Item:update()
    if PLAYER == nil then return end
    if (self.V ~= PLAYER.V or self.W ~= PLAYER.W or self.Z ~= PLAYER.Z) then
        self.sprite:setVisible(false)
    else
        self.sprite:setImage(self:chooseImage())
        self.sprite:setVisible(true)
    end
end
