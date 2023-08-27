import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/frameTimer"

import "sceneManager"
import "homeScene"

local pd <const> = playdate
local gfx <const> = pd.graphics

local font = gfx.font.new("Fonts/MatchupPro/MatchupPro18")
gfx.setFont(font)

SCENE_MANAGER = SceneManager()
HomeScene()

local function loadMain()
end

local function updateMain()
	pd.timer.updateTimers()
	pd.frameTimer.updateTimers()
	gfx.sprite.update()
end

local function drawMain()
end

loadMain()

function pd.update()
	updateMain()
	drawMain()
	pd.drawFPS(0,0) -- FPS widget
end

--[[ Do stuff when opening/closing the system menu
function playdate.gameWillPause()
end
function playdate.gameWillResume()
end
]]
function pd.gameWillTerminate()
	SCENE_MANAGER:saveSettings()
end
function pd.deviceWillLock()
	SCENE_MANAGER:saveSettings()
end
function pd.deviceWillSleep()
	SCENE_MANAGER:saveSettings()
end
