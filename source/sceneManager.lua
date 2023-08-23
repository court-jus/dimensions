import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('SceneManager').extends()

function SceneManager:init()
    local loadedData = pd.datastore.read("settings")
    self.lang = (loadedData ~= nil and loadedData.lang ~= nil) and loadedData.lang or "en"
    self.introSeen = (loadedData ~= nil and loadedData.introSeen ~= nil) and loadedData.introSeen or false
end

function SceneManager:saveSettings()
    pd.datastore.write({
        lang = self.lang,
        introSeen = self.introSeen,
    }, "settings")
end

function SceneManager:toggleLang()
    self.lang = self.lang == "fr" and "en" or "fr"
    self:saveSettings()
end

function SceneManager:switchScene(scene, options)
    self.newScene = scene
    self:loadNewScene(options)
end

function SceneManager:loadNewScene(options)
    self:cleanupScene()
    self.newScene(options)
end

function SceneManager:cleanupScene()
    gfx.sprite.removeAll()
    self:removeAllTimers()
    gfx.setDrawOffset(0, 0)
end

function SceneManager:removeAllTimers()
    local allTimers = pd.timer.allTimers()
    if allTimers == nil then
        return
    end
    for _, timer in ipairs(allTimers) do
        timer:remove()
    end
end