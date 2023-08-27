import "item"
import "wall"
import "spinner"

local pd <const> = playdate
local gfx <const> = pd.graphics
local default_map <const> = "map_5.json"

class('Map').extends(gfx.sprite)

function Map:init(options)
    local spinner = Spinner()
    self.items = {}
    self.sprites = {}
    self.visibleDialog = nil
    local loadedMap = nil
    if options.loadGame then
        loadedMap = json.decodeFile("save.json")
    elseif default_map ~= nil then
        loadedMap = json.decodeFile("Maps/" .. default_map)
    end
    if loadedMap ~= nil then
        self.walls = loadedMap.walls
        for _, item in ipairs(loadedMap.items) do
            self.items[#self.items+1] = Item(item)
        end
    
        for ix = 1, 10 do
            for iy = 1, 10 do
                self.sprites[#self.sprites + 1] = Wall(ix, iy)
            end
        end
        PLAYER:loadState(loadedMap.player)
    else
        -- Initialize an empty map
        self.walls = {}
        for ix=1,10 do
            self.walls[ix] = {}
            for iy=1,10 do
             self.walls[ix][iy] = {}
                self.sprites[#self.sprites+1] = Wall(ix, iy)
                for iz=1,10 do
                    self.walls[ix][iy][iz] = {}
                    for iv=1,10 do
                        self.walls[ix][iy][iz][iv] = {}
                        for iw=1,10 do
                            self.walls[ix][iy][iz][iv][iw] = 1
                        end
                    end
                end
            end
        end
        self.walls[2][2][2][2][2] = 0 -- Player's starting position
    end
    self:add()
    spinner:remove()
end

function Map:saveMap()
    local spinner = Spinner()
    local items = {}
    for _, item in ipairs(self.items) do
        items[#items+1] = item:dumpState()
    end
    json.encodeToFile("save.json", true, {
        walls = self.walls,
        items = items,
        player = PLAYER:dumpState()
    })
    spinner:remove()
end

function Map:updateSprites()
    -- Called when the player moves
    if PLAYER.flags.digging then
        self.walls[PLAYER.X][PLAYER.Y][PLAYER.Z][PLAYER.V][PLAYER.W] = 0
    end
    for _, sprite in ipairs(self.sprites) do
        sprite:changeImage()
    end
    for _, item in ipairs(self.items) do
        item:updateVisibility()
    end
end

function Map:activateItem()
    for _, item in ipairs(self.items) do
        if (
            item.X == PLAYER.X and
            item.Y == PLAYER.Y and
            item.Z == PLAYER.Z and
            item.V == PLAYER.V and
            item.W == PLAYER.W
        ) then
            item:action()
        end
    end
end

function Map:switchCellAtPlayerPosition()
    local currentType = self.walls[PLAYER.X][PLAYER.Y][PLAYER.Z][PLAYER.V][PLAYER.W]
    newType = currentType + 1
    if newType > CT_MAX or (newType == CT_LADDER and PLAYER.directions ~= DIR_PLATFORMER) then
        newType = 0
    end
    self.walls[PLAYER.X][PLAYER.Y][PLAYER.Z][PLAYER.V][PLAYER.W] = newType
    self:updateSprites()
end

function Map:update()
    if pd.buttonJustPressed(pd.kButtonA) and MAP.visibleDialog == nil then
        if PLAYER.flags.levelEditor then
            self:switchCellAtPlayerPosition()
        end
    end
end