import "item"
import "wall"

local pd <const> = playdate
local gfx <const> = pd.graphics
local load_map <const> = "map_third.json"

class('Map').extends(gfx.sprite)

function Map:init()
    self.items = {}
    self.sprites = {}
    if load_map ~= nil then
        self.walls = json.decodeFile("Maps/" .. load_map)
        for ix = 1, 10 do
            for iy = 1, 10 do
                self.sprites[#self.sprites + 1] = Wall(ix, iy)
            end
        end
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
    self.items[#self.items+1] = Item(5, 5, 5, 5, 5)
    self:add()
end

function Map:saveMap()
    json.encodeToFile("map.json", true, self.walls)
    local items = {}
    for _, item in ipairs(self.items) do
        items[#items+1] = item:dumpState()
    end
    json.encodeToFile("save.json", true, {
        walls = self.walls,
        items = items,
        player = PLAYER:dumpState()
    })
end

function Map:updateSprites()
    -- Called when the player moves
    if CAN_DIG then
        self.walls[PLAYER.X][PLAYER.Y][PLAYER.Z][PLAYER.V][PLAYER.W] = 0
    end
    for _, sprite in ipairs(self.sprites) do
        sprite:changeImage()
    end
end
