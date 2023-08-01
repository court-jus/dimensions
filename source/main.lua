import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "sceneManager"
import "gameScene"

local pd <const> = playdate
local gfx <const> = pd.graphics
SCENE_MANAGER = SceneManager()
GameScene()

local function loadMain()
end

local function updateMain()
	pd.timer.updateTimers()
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