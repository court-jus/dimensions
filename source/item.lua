import "dialog"

local pd <const> = playdate
local gfx <const> = playdate.graphics

local images <const> = {
    item = gfx.image.new("Images/item"),
    pnj = gfx.image.new("Images/pnj"),
    house = gfx.image.new("Images/house"),
    flower = gfx.image.new("Images/flower"),
    sign = gfx.image.new("Images/sign"),
}



class('Item').extends(gfx.sprite)

function Item:init(parameters)
    self.type = "item"
    self.extra = {}
    self.sprite = gfx.sprite.new(self:chooseImage())
    self.sprite:setZIndex(50)
    self.sprite:setVisible(false)
    self:loadState(parameters)
    self.sprite:add()
    self:add()
end

function Item:chooseImage()
    return images[self.type]
end

function Item:update()
end

function Item:updateVisibility()
    if PLAYER == nil then return end
    local ud = ROTATIONS[PLAYER.directions].ud
    local lr = ROTATIONS[PLAYER.directions].lr
    self.sprite:moveTo(self[lr] * 24 - 12, self[ud] * 24 - 12)
    if (
        (ud ~= "X" and lr ~= "X" and self.X ~= PLAYER.X) or
        (ud ~= "Y" and lr ~= "Y" and self.Y ~= PLAYER.Y) or
        (ud ~= "Z" and lr ~= "Z" and self.Z ~= PLAYER.Z) or
        (ud ~= "V" and lr ~= "V" and self.V ~= PLAYER.V) or
        (ud ~= "W" and lr ~= "W" and self.W ~= PLAYER.W)
    ) then
        self.sprite:setVisible(false)
        self.visible = false
    else
        self.sprite:setImage(self:chooseImage())
        self.sprite:setVisible(true)
        self.visible = true
    end
end

function Item:action()
    if PLAYER.flags.levelEditor then return end
    if (self.type == "pnj" or self.type == "sign" or self.type == "house") and self.extra["text_" .. SCENE_MANAGER.lang] ~= nil and MAP ~= nil and MAP.visibleDialog == nil then
        local text = self.extra["text_" .. SCENE_MANAGER.lang]
        MAP.visibleDialog = Dialog(text)
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
        type = self.type,
        extra = self.extra,
    }
end

function Item:loadState(state)
    self.X = state.X
    self.Y = state.Y
    self.Z = state.Z
    self.V = state.V
    self.W = state.W
    self.visible = state.visible
    self.type = state.type
    self.extra = state.extra
    self.sprite:setImage(self:chooseImage())
    self.sprite:moveTo(self.X * 24 - 12, self.Y * 24 - 12)
    if self.visible then
        self.sprite:setVisible(true)
    else
        self.sprite:setVisible(false)
    end
end
