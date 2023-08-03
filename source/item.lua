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
    self.visible = false
    self.sprite = gfx.sprite.new(self:chooseImage())
    self.sprite:moveTo(self.X * 24 - 12, self.Y * 24 - 12)
    self.sprite:setZIndex(50)
    self.sprite:setVisible(false)
    self.sprite:add()
    self:add()
end

function Item:chooseImage()
    return itemImage
end

function Item:update()
    if PLAYER == nil then return end
    local ud = ROTATIONS[PLAYER.directions].ud
    local lr = ROTATIONS[PLAYER.directions].lr
    if (
        (ud ~= "X" and lr ~= "X" and self.X ~= PLAYER.X) or
        (ud ~= "Y" and lr ~= "Y" and self.Y ~= PLAYER.Y) or
        (ud ~= "Z" and lr ~= "Z" and self.Z ~= PLAYER.Z) or
        (ud ~= "V" and lr ~= "V" and self.V ~= PLAYER.V) or
        (ud ~= "W" and lr ~= "W" and self.W ~= PLAYER.W)
    ) then
        if self.visible then
            self.sprite:setVisible(false)
            self.visible = false
        end
    else
        if not self.visible then
            self.sprite:setImage(self:chooseImage())
            self.sprite:setVisible(true)
            self.visible = true
        end
    end
end

function Item:dumpState()
    return {
        X = self.X,
        Y = self.Y,
        Z = self.Z,
        V = self.V,
        W = self.W,
        visible = self.visible,
    }
end

function Item:loadState(state)
    self.X = state.X
    self.Y = state.Y
    self.Z = state.Z
    self.V = state.V
    self.W = state.W
    self.visible = state.visible
    self.sprite:setImage(self:chooseImage())
    if self.visible then
        self.sprite:setVisible(true)
    end
end
