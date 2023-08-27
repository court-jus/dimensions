local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Player').extends(gfx.sprite)

local images <const> = {
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
local topImage <const> = gfx.image.new("Images/playertop")

ROTATIONS = {
    { ud = "Y", lr = "X" },
    { ud = "Y", lr = "Z" },
    { ud = "V", lr = "Z" },
    { ud = "V", lr = "W" },
}

-- Cell types
CT_EMPTY = 0
CT_WALL = 1
CT_LADDER = 2
CT_MAX = 2

-- Direction (aka plane)
DIR_XY = 1
DIR_YZ = 2
DIR_ZV = 3
DIR_GRAVITY = DIR_ZV
DIR_VW = 4
DIR_PLATFORMER = DIR_VW

JUMP_FORCE = -3

PLATFORMER_FALL_DELAY = 200
GRAVITY_DELAY = 60

function Player:init()
    self.X = 2
    self.Y = 2
    self.Z = 2
    self.V = 2
    self.W = 2
    self.directions = 1
    self.coordDisplay = gfx.sprite.new(gfx.image.new(160, 240))
    self.coordDisplay:moveTo(380, 120)
    self.coordDisplay:add()
    self.sprite = gfx.sprite.new(images[self.Z])
    self.sprite:setZIndex(100)
    self.sprite:add()
    self.platformerState = {
        state = nil,
        nextFall = nil,
        velocity = 0,
    }
    self.gravityState = {
        state = nil,
        nextFall = nil,
        gravity = "down",
    }
    self.flags = {
        levelEditor = true,
        digging = false,
    }
    self.redrawNeeded = true
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
            (newPos[direction] < 2) or
            (newPos[direction] > 9) or
            (not (self.flags.levelEditor or self.flags.digging) and MAP ~= nil and MAP.walls[newPos.X][newPos.Y][newPos.Z][newPos.V][newPos.W] == CT_WALL)
        ) then
        return
    end
    self[direction] += delta
    if MAP ~= nil then
        MAP:activateItem()
    end
    self.redrawNeeded = true
end

function Player:updateSprite()
    if self.directions == 1 or self.directions == 2 then
        self.sprite:setImage(topImage)
    else
        self.sprite:setImage(images[2])
    end
    self.sprite:moveTo(self[ROTATIONS[self.directions].lr] * 24 - 12, self[ROTATIONS[self.directions].ud] * 24 - 12)
end

function Player:updateHud()
    local image = self.coordDisplay:getImage()
    local text = PLAYER:getText()
    gfx.pushContext(image)
    gfx.clear()
    gfx.drawTextAligned(text, 80, 10, 1)
    gfx.popContext()
    self.coordDisplay:setImage(image)
end

function Player:handleInputLaby()
    if pd.buttonJustPressed(pd.kButtonUp) then
        self.sprite:setRotation(180)
        self:playerMove(ROTATIONS[self.directions]["ud"], -1)
    end
    if pd.buttonJustPressed(pd.kButtonDown) then
        self.sprite:setRotation(0)
        self:playerMove(ROTATIONS[self.directions]["ud"], 1)
    end
    if pd.buttonJustPressed(pd.kButtonLeft) then
        self.sprite:setRotation(90)
        self:playerMove(ROTATIONS[self.directions]["lr"], -1)
    end
    if pd.buttonJustPressed(pd.kButtonRight) then
        self.sprite:setRotation(-90)
        self:playerMove(ROTATIONS[self.directions]["lr"], 1)
    end
end

function Player:handleInputPlatformer()
    if pd.buttonJustPressed(pd.kButtonUp) and self.platformerState.state == "climbing" then
        self:playerMove(ROTATIONS[self.directions]["ud"], -1)
    end
    if pd.buttonJustPressed(pd.kButtonDown) and self.platformerState.state == "climbing" then
        self:playerMove(ROTATIONS[self.directions]["ud"], 1)
    end
    if pd.buttonJustPressed(pd.kButtonLeft) then
        self:playerMove(ROTATIONS[self.directions]["lr"], -1)
    end
    if pd.buttonJustPressed(pd.kButtonRight) then
        self:playerMove(ROTATIONS[self.directions]["lr"], 1)
    end
end

function Player:updatePhysicsPlatformer()
    if MAP == nil then return end
    local mapSlice = MAP.walls[self.X][self.Y][self.Z]
    if self.platformerState.velocity < 0 and mapSlice[self.V - 1][self.W] == CT_WALL then
        self.platformerState.velocity = 0
    elseif self.platformerState.velocity < 0 and mapSlice[self.V - 1][self.W] ~= CT_WALL then
        self.platformerState.velocity += 1
        self:playerMove("V", -1)
    end
    local newState = self.platformerState.state
    local currentCell = mapSlice[self.V][self.W]
    local belowCell = mapSlice[self.V + 1][self.W]
    if currentCell == CT_LADDER or belowCell == CT_LADDER then
        newState = "climbing"
    elseif belowCell == CT_EMPTY then
        newState = "falling"
    elseif belowCell == CT_WALL then
        newState = "standing"
    end
    if newState ~= self.platformerState.state then
        self.redrawNeeded = true
        self.platformerState.state = newState
    end
    now = pd.getCurrentTimeMilliseconds()
    if self.platformerState.state == "falling" and (self.platformerState.nextFall == nil or self.platformerState.nextFall < now) then
        self.platformerState.nextFall = now + PLATFORMER_FALL_DELAY
        self:playerMove("V", 1)
    end
end

function Player:handleInputGravity()
    if self.gravityState.state ~= "standing" then return end
    if pd.buttonJustPressed(pd.kButtonUp) then
        self.sprite:setRotation(180)
        self.gravityState.gravity = "up"
    end
    if pd.buttonJustPressed(pd.kButtonLeft) then
        self.sprite:setRotation(90)
        self.gravityState.gravity = "left"
    end
    if pd.buttonJustPressed(pd.kButtonRight) then
        self.sprite:setRotation(-90)
        self.gravityState.gravity = "right"
    end
    if pd.buttonJustPressed(pd.kButtonDown) then
        self.sprite:setRotation(0)
        self.gravityState.gravity = "down"
    end
end

function Player:updatePhysicsGravity()
    if MAP == nil then return end
    local mapSlice = MAP.walls[self.X][self.Y]
    local neighbors = {
        up = mapSlice[self.Z][self.V - 1][self.W],
        down = mapSlice[self.Z][self.V + 1][self.W],
        left = mapSlice[self.Z - 1][self.V][self.W],
        right = mapSlice[self.Z + 1][self.V][self.W],
    }
    if self.gravityState.state ~= "falling" and neighbors[self.gravityState.gravity] ~= 1 then
        self.gravityState.state = "falling"
    elseif self.gravityState.state ~= "standing" and neighbors[self.gravityState.gravity] == 1 then
        self.gravityState.state = "standing"
    end
    now = pd.getCurrentTimeMilliseconds()
    if self.gravityState.state == "falling" and (self.gravityState.nextFall == nil or self.gravityState.nextFall < now) then
        local fallDirection = {
            up = {direction="V", delta=-1},
            down = { direction = "V", delta = 1 },
            left = { direction = "Z", delta = -1 },
            right = { direction = "Z", delta = 1 },
        }
        self.gravityState.nextFall = now + GRAVITY_DELAY
        self:playerMove(fallDirection[self.gravityState.gravity].direction, fallDirection[self.gravityState.gravity].delta)
    end
end

function Player:handleInput()
    if MAP.visibleDialog ~= nil then
        return
    end
    if self.directions == DIR_PLATFORMER then
        self:handleInputPlatformer()
    elseif self.directions == DIR_GRAVITY then
        self:handleInputGravity()
    else
        self:handleInputLaby()
    end
    self:handleInputGlobal()
end

function Player:handleInputGlobal()
    if pd.buttonJustPressed(pd.kButtonB) then
        self.directions = self.directions + 1
        if self.directions > #ROTATIONS then
            self.directions = 1
        end
        if self.directions == DIR_PLATFORMER or self.directions == DIR_GRAVITY then
            self.sprite:setRotation(0)
        end
        self.redrawNeeded = true
    end
end

function Player:updatePhysics()
    if self.directions == DIR_PLATFORMER then
        self:updatePhysicsPlatformer()
    else
        self.platformerState = {
            state = nil,
            nextFall = nil,
            velocity = 0,
        }
    end
    if self.directions == DIR_GRAVITY then
        self:updatePhysicsGravity()
    else
        self.gravityState = {
            state = nil,
            nextFall = nil,
            gravity = "down",
        }
    end
end

function Player:handleUpdateGui()
    if not self.redrawNeeded then return end
    if MAP ~= nil then
        MAP:updateSprites()
    end
    self:updateSprite()
    self:updateHud()
    self.redrawNeeded = false
end

function Player:update()
    if self.flags.levelEditor then
        self:handleInputLaby()
        self:handleInputGlobal()
    else
        self:handleInput()
        self:updatePhysics()
    end
    self:handleUpdateGui()
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
    if self.directions == DIR_PLATFORMER then
        text = text .. (self.platformerState.state ~= nil and self.platformerState.state or "meh") .. "\n"
    else
        text = text .. "DIR" .. self.directions .. "\n"
    end
    for flag, enabled in pairs(self.flags) do
        if enabled then
            text = text .. flag .. "\n"
        end
    end
    return text
end
