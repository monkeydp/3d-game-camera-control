; AHIRemapper.ahk
#Requires AutoHotkey v2.0

; 加载库
#include <AutoHotInterception>

class AHIRemapper
{
    ; --- 私有属性 ---
    _AHI := ""
    _keyboardId := 0
    _keyMappings := ""
    _winTitle := ""

    __New(config)
    {
        this._AHI := AutoHotInterception()
        this._keyboardId := config.keyboardId
        this._keyMappings := config.keyMappings
        this._winTitle := config.HasOwnProp("winTitle") ? config.winTitle : ""
    }

    start()
    {
        this._AHI.SubscribeKeyboard(this._keyboardId, true, this._keyEvent.Bind(this))
    }

    _handleRemap(triggerCode, state) {
        local targetKeys := this._keyMappings[triggerCode]
        for keyCode in targetKeys {
            this._AHI.SendKeyEvent(this._keyboardId, keyCode, state)
        }
    }

    _keyEvent(code, state) {
        local shouldRemap := this._keyMappings.Has(code)
        local isWindowActive := (this._winTitle = "" or WinActive(this._winTitle))

        if (shouldRemap and isWindowActive)
        {
            this._handleRemap(code, state)
            return 0
        }

        this._AHI.SendKeyEvent(this._keyboardId, code, state)
        return 0
    }
}