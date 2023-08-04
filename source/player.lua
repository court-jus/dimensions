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

JUMP_FORCE = -3

PLATFORMER_FALL_DELAY = 200
GRAVITY_DELAY = 60

function Player:init()
    self.X = 8
    self.Y = 9
    self.Z = 9
    self.V = 9
    self.W = 2
    self.directions = 3
    self.coordDisplay = gfx.sprite.new(gfx.image.new(100, 240))
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
            (self[direction] + delta < 2) or
            (self[direction] + delta > 9) or
            (not CAN_DIG and MAP ~= nil and MAP.walls[newPos.X][newPos.Y][newPos.Z][newPos.V][newPos.W] == 1)
        ) then
        return
    end
    self[direction] += delta
    self.redrawNeeded = true
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

function Player:handleInputLaby()
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
end

function Player:handleInputPlatformer()
    if pd.buttonJustPressed(pd.kButtonUp) and self.platformerState.state == "standing" then
        self.platformerState.velocity = JUMP_FORCE
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
    if self.platformerState.velocity < 0 and mapSlice[self.V - 1][self.W] == 1 then
        self.platformerState.velocity = 0
    elseif self.platformerState.velocity < 0 and mapSlice[self.V - 1][self.W] ~= 1 then
        self.platformerState.velocity += 1
        self:playerMove("V", -1)
    end
    if self.platformerState.state ~= "falling" and mapSlice[self.V + 1][self.W] ~= 1 then
        self.platformerState.state = "falling"
    elseif self.platformerState.state ~= "standing" and mapSlice[self.V+1][self.W] == 1 then
        self.platformerState.state = "standing"
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
        self.gravityState.gravity = "up"
    end
    if pd.buttonJustPressed(pd.kButtonLeft) then
        self.gravityState.gravity = "left"
    end
    if pd.buttonJustPressed(pd.kButtonRight) then
        self.gravityState.gravity = "right"
    end
    if pd.buttonJustPressed(pd.kButtonDown) then
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
    if self.directions == 4 then
        self:handleInputPlatformer()
    elseif self.directions == 3 then
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
        self.redrawNeeded = true
    end
end

function Player:updatePhysics()
    if self.directions == 4 then
        self:updatePhysicsPlatformer()
    else
        self.platformerState = {
            state = nil,
            nextFall = nil,
            velocity = 0,
        }
    end
    if self.directions == 3 then
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
    if CAN_DIG then
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
    return text
end
