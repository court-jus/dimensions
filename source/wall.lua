import "item"

local pd <const> = playdate
local gfx <const> = pd.graphics
local ladderImage <const> = gfx.image.new("Images/ladder")

class('Wall').extends(gfx.sprite)

local vWalls = {}
local wWalls = {}

for i = 1, 10 do
    local image = gfx.image.new(24, 24)
    gfx.pushContext(image)
    gfx.drawRect(0, 0, 24, 24)
    for j = 1, i do
        local x = math.floor(24 / i * (j - 0.5))
        gfx.drawLine(x, 0, x, 24)
    end
    gfx.popContext()
    vWalls[#vWalls + 1] = image
    image = gfx.image.new(24, 24)
    gfx.pushContext(image)
    gfx.drawRect(0, 0, 24, 24)
    for j = 1, i do
        local x = math.floor(24 / i * (j - 0.5))
        gfx.drawLine(0, x, 24, x)
    end
    gfx.popContext()
    wWalls[#wWalls + 1] = image
end

function Wall:init(x, y)
    self.X = x
    self.Y = y
    self.sprite = gfx.sprite.new(gfx.image.new(24, 24))
    self.sprite:moveTo(self.X * 24 - 12, self.Y * 24 - 12)
    self.sprite:setZIndex(0)
    self.sprite:setImage(self:chooseImage())
    self.sprite:add()
    self:add()
end

function Wall:getType()
    if PLAYER == nil or MAP == nil then return false end
    local ud = ROTATIONS[PLAYER.directions].ud -- mapped to self.Y
    local lr = ROTATIONS[PLAYER.directions].lr -- mapped to self.X
    local dimensions = {
        X = PLAYER.X,
        Y = PLAYER.Y,
        Z = PLAYER.Z,
        V = PLAYER.V,
        W = PLAYER.W,
    }
    dimensions[ud] = self.Y
    dimensions[lr] = self.X
    return MAP.walls[dimensions.X][dimensions.Y][dimensions.Z][dimensions.V][dimensions.W]
end

function Wall:chooseImage()
    local image = self.sprite:getImage()
    if PLAYER == nil or MAP == nil then return image end
    gfx.pushContext(image)
    gfx.clear()
    local cellType = self:getType()
    if cellType == 1 then -- Wall
        local ud = ROTATIONS[PLAYER.directions].ud -- mapped to self.Y
        local lr = ROTATIONS[PLAYER.directions].lr -- mapped to self.X
        local dimensions = {
            V = PLAYER.V,
            W = PLAYER.W,
        }
        dimensions[ud] = self.Y
        dimensions[lr] = self.X
        vWalls[dimensions.V]:draw(0, 0)
        wWalls[dimensions.W]:draw(0, 0)
    elseif cellType == 2 and PLAYER.directions == DIR_PLATFORMER then -- Ladder
        ladderImage:draw(0, 0)
    end
    gfx.popContext()
    return image
end

function Wall:changeImage()
    if PLAYER == nil then return end
    self.sprite:setImage(self:chooseImage())
end
