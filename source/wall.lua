import "item"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Wall').extends(gfx.sprite)

local vWalls = {}
local wWalls = {}

for i=1,10 do
    local image = gfx.image.new(24, 24)
    gfx.pushContext(image)
      gfx.drawRect(0, 0, 24, 24)
      for j=1,i do
        local x = math.floor(24/i*(j-0.5))
        gfx.drawLine(x, 0, x, 24)
      end
    gfx.popContext()
    vWalls[#vWalls+1] = image
    image = gfx.image.new(24, 24)
    gfx.pushContext(image)
      gfx.drawRect(0, 0, 24, 24)
      for j=1,i do
        local x = math.floor(24/i*(j-0.5))
        gfx.drawLine(0, x, 24, x)
      end
    gfx.popContext()
    wWalls[#wWalls+1] = image
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

function Wall:chooseImage()
    local image = self.sprite:getImage()
    gfx.pushContext(image)
      gfx.clear()
    if PLAYER ~= nil and MAP ~= nil and (self.X == 1 or self.X == 10 or self.Y == 1 or self.Y == 10 or MAP.walls[self.X][self.Y][PLAYER.Z][PLAYER.V][PLAYER.W] == 1) then
        vWalls[PLAYER.V]:draw(0, 0)
        wWalls[PLAYER.W]:draw(0, 0)
    end
    gfx.popContext()
    return image
end

function Wall:changeImage()
    if PLAYER == nil then return end
    self.sprite:setImage(self:chooseImage())
end

function Wall:update()
end