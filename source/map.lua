import "item"
import "wall"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Map').extends(gfx.sprite)

function Map:init()
    self.items = {}
    self.sprites = {}
    self.walls = {}
    self.walls = json.decodeFile("map.json")
    self.items[#self.items+1] = Item(2, 2, 5, 5, 5)
    for ix=1,10 do
        -- self.walls[ix] = {}
        for iy=1,10 do
           --  self.walls[ix][iy] = {}
            self.sprites[#self.sprites+1] = Wall(ix, iy)
            --[[for iz=1,10 do
                self.walls[ix][iy][iz] = {}
                for iv=1,10 do
                    self.walls[ix][iy][iz][iv] = {}
                    for iw=1,10 do
                        self.walls[ix][iy][iz][iv][iw] = 1
                    end
                end
            end
            ]]
        end
    end
    self.walls[2][2][2][2][2] = 0 -- Player's starting position
    self:add()
end

function Map:saveMap()
    json.encodeToFile("map.json", true, self.walls)
end

function Map:updateSprites()
    -- Called when the player moves
    -- self.walls[PLAYER.X][PLAYER.Y][PLAYER.Z][PLAYER.V][PLAYER.W] = 0
    for _, sprite in ipairs(self.sprites) do
        sprite:changeImage()
    end
end

function Map:update()
end
