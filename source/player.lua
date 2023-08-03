local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Player').extends(gfx.sprite)

local images = {
    gfx.image.new("Images/player01"),
    gfx.image.new("Images/player02"),
    gfx.image.new("Images/player03"),
    gfx.image.new("Images/player04"),
    gfx.image.new("Images/player05"),
    gfx.image.new("Images/player06"),
    gfx.image.new("Images/player07"),
    gfx.image.new("Images/player08"),
    gfx.image.new("Images/player09"),
    gfx.image.new("Images/player10"),
}

ROTATIONS = {
    { ud = "Y", lr = "X" },
    { ud = "Y", lr = "Z" },
    { ud = "V", lr = "Z" },
    { ud = "V", lr = "W" },
}

function Player:init()
    self.X = 2
    self.Y = 2
    self.Z = 2
    self.V = 2
    self.W = 2
    self.coordDisplay = gfx.sprite.new(gfx.image.new(100, 240))
    self.coordDisplay:moveTo(380, 120)
    self.coordDisplay:add()
    self.sprite = gfx.sprite.new(images[self.Z])
    self.sprite:setZIndex(100)
    self.sprite:add()
    self.directions = 1
    self:add()
    self:updateSprite()
end

function Player:dumpState()
    return {
        X = self.X,
        Y = self.Y,
        Z = self.Z,
        V = self.V,
        W = self.W,
        directions = self.directions
    }
end

function Player:loadState(state)
    self.X = state.X
    self.Y = state.Y
    self.Z = state.Z
    self.V = state.V
    self.W = state.W
    self.directions = state.directions
    if MAP ~= nil then
        MAP:updateSprites()
    end
    self:updateSprite()
    self:updateHud()
end

function Player:playerMove(direction, delta)
    local newPos = { X = self.X, Y = self.Y, Z = self.Z, V = self.V, W = self.W }
    newPos[direction] += delta
    if (
            (self[direction] + delta < 2) or
            (self[direction] + delta > 9) or
            (not CAN_DIG and MAP ~= nil and MAP.walls[newPos.X][newPos.Y][newPos.Z][newPos.V][newPos.W] == 1)
        ) then
        return
    end
    self[direction] += delta
    if MAP ~= nil then
        MAP:updateSprites()
    end
    self:updateSprite()
    self:updateHud()
end

function Player:updateSprite()
    self.sprite:setImage(images[self.Z])
    self.sprite:moveTo(self[ROTATIONS[self.directions].lr] * 24 - 12, self[ROTATIONS[self.directions].ud] * 24 - 12)
end

function Player:updateHud()
    local image = self.coordDisplay:getImage()
    local text = PLAYER:getText()
    gfx.pushContext(image)
    gfx.clear()
    gfx.drawTextAligned(text, 50, 10, 1)
    gfx.popContext()
    self.coordDisplay:setImage(image)
end

function Player:update()
    if pd.buttonJustPressed(pd.kButtonUp) then
        self:playerMove(ROTATIONS[self.directions]["ud"], -1)
    end
    if pd.buttonJustPressed(pd.kButtonDown) then
        self:playerMove(ROTATIONS[self.directions]["ud"], 1)
    end
    if pd.buttonJustPressed(pd.kButtonLeft) then
        self:playerMove(ROTATIONS[self.directions]["lr"], -1)
    end
    if pd.buttonJustPressed(pd.kButtonRight) then
        self:playerMove(ROTATIONS[self.directions]["lr"], 1)
    end
    if pd.buttonJustPressed(pd.kButtonB) then
        self.directions = self.directions + 1
        if self.directions > #ROTATIONS then
            self.directions = 1
        end
        if MAP ~= nil then
            MAP:updateSprites()
        end
        self:updateSprite()
        self:updateHud()
    end
end

function Player:getText()
    local ud = ROTATIONS[self.directions]["ud"]
    local lr = ROTATIONS[self.directions]["lr"]
    local text = ""
    text = text .. (ud == "X" and "ud  " or (lr == "X" and "lr  " or "")) .. "X " .. PLAYER.X .. "\n"
    text = text .. (ud == "Y" and "ud  " or (lr == "Y" and "lr  " or "")) .. "Y " .. PLAYER.Y .. "\n"
    text = text .. (ud == "Z" and "ud  " or (lr == "Z" and "lr  " or "")) .. "Z " .. PLAYER.Z .. "\n"
    text = text .. (ud == "V" and "ud  " or (lr == "V" and "lr  " or "")) .. "V " .. PLAYER.V .. "\n"
    text = text .. (ud == "W" and "ud  " or (lr == "W" and "lr  " or "")) .. "W " .. PLAYER.W .. "\n"
    return text
end