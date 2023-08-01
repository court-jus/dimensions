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
    {ud="Y", lr="X"},
    {ud="Z", lr="X"},
    {ud="Y", lr="X"},
    {ud="Y", lr="V"},
    {ud="Y", lr="X"},
    {ud="Z", lr="W"},
}

function Player:init()
    self.V = 2
    self.W = 2
    self.X = 2
    self.Y = 2
    self.Z = 2
    self.coordDisplay = gfx.sprite.new(gfx.image.new(160, 240))
    self.coordDisplay:moveTo(320, 120)
    self.coordDisplay:add()
    self.sprite = gfx.sprite.new(images[self.Z])
    self.sprite:moveTo(self.X * 24 - 12, self.Y * 24 - 12)
    self.sprite:setZIndex(100)
    self.sprite:add()
    self.directions = 1
    self:add()
end

function Player:playerMove(direction, delta)
    print("move along", direction,":",delta)
    local newPos = { X=self.X, Y=self.Y, Z=self.Z, V=self.V, W=self.W }
    newPos[direction] += delta
    printTable(newPos)
    print((MAP ~= nil and MAP.walls[newPos.X][newPos.Y][newPos.Z][newPos.V][newPos.W] or nil))
    if (
        (self[direction] + delta < 2) or
        (self[direction] + delta > 9) or
        (MAP ~= nil and MAP.walls[newPos.X][newPos.Y][newPos.Z][newPos.V][newPos.W] == 1)
    ) then
        return
    end
    self[direction] += delta
    MAP:updateSprites()
    self.sprite:setImage(images[self.Z])
    self.sprite:moveTo(self.X * 24 - 12, self.Y * 24 - 12)
    self:updateHud()
end

function Player:updateHud()
    local image = self.coordDisplay:getImage()
    local text = PLAYER:getText()
    print(text)
    gfx.pushContext(image)
      gfx.clear()
      gfx.drawTextAligned(text, 150, 10, 1)
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
        print("Will now move along", ROTATIONS[self.directions]["ud"], "and", ROTATIONS[self.directions]["lr"])
        self:updateHud()
    end
end

function Player:getText()
    local ud = ROTATIONS[self.directions]["ud"]
    local lr = ROTATIONS[self.directions]["lr"]
    local text  = (ud == "V" and "ud  " or (lr == "V" and "lr  " or "")).."V "..PLAYER.V.."\n"
    text = text ..(ud == "W" and "ud  " or (lr == "W" and "lr  " or "")).."W "..PLAYER.W.."\n"
    text = text ..(ud == "X" and "ud  " or (lr == "X" and "lr  " or "")).."X "..PLAYER.X.."\n"
    text = text ..(ud == "Y" and "ud  " or (lr == "Y" and "lr  " or "")).."Y "..PLAYER.Y.."\n"
    text = text ..(ud == "Z" and "ud  " or (lr == "Z" and "lr  " or "")).."Z "..PLAYER.Z
    return text
end