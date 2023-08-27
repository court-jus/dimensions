import "dialog"
import "CoreLibs/frameTimer"

local pd <const> = playdate
local gfx <const> = pd.graphics

local spinnerImage <const> = gfx.imagetable.new("Images/spinner")

class('Spinner').extends(gfx.sprite)

function Spinner:init()
    self:setZIndex(4000)
    self:setImage(spinnerImage:getImage(1))
    self:moveTo(200, 120)
    self:add()
    local timer = pd.frameTimer.new(20, 1, 10, pd.easingFunctions.inCubic)
    timer.repeats = true
    timer.updateCallback = function(timer)
        self:setImage(spinnerImage:getImage(math.floor(timer.value)))
    end
end
