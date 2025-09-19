#Requires AutoHotkey v2.0

class Zoom
{
    ; =============================================
    ;          可配置参数
    ; =============================================
    _uniformDuration := 5000     ; 匀速缩放的总时长 (毫秒)。
    _uniformInterval := 50       ; 匀速滚动的固定时间间隔 (毫秒)，决定了匀速模式的速度。
    _smoothDuration := 2000      ; 平滑缩放的总时长 (毫秒)。
    _minSmoothInterval := 50      ; 平滑缩放的最小时间间隔 (毫秒)，决定了结束时的最快速度。
    _maxSmoothInterval := 150     ; 平滑缩放的最大时间间隔 (毫秒)，决定了开始时的最慢速度。

    ; =============================================
    ;          内部状态变量
    ; =============================================
    _currentState := "none"        ; 标记当前的缩放状态 ("in", "out", 或 "none")。
    _smoothStartTime := 0          ; 记录平滑缩放的开始时间 (A_TickCount)。
    _boundUniformDownAction := ""  ; 预先绑定的 _uniformDownAction 方法，以确保 SetTimer 能被正确关闭。
    _boundUniformUpAction := ""    ; 预先绑定的 _uniformUpAction 方法。
    _boundSmoothEngine := ""       ; 预先绑定的 _smoothEngine 方法。
    _boundStop := ""               ; 预先绑定的 _stop 方法。

    ; =============================================
    ;          公共接口 (Public API)
    ; =============================================

    zoomIn(isSmooth := true)
    {
        local previousState := this._currentState
        this._stop()

        if (previousState != "out")
        {
            this._currentState := "out"
            if (isSmooth)
            {
                this._smoothStartTime := A_TickCount
                this._smoothEngine()
            }
            else
            {
                this._uniformUpAction()
                SetTimer(this._boundStop, -this._uniformDuration)
            }
        }
    }

    zoomOut(isSmooth := true)
    {
        local previousState := this._currentState
        this._stop()

        if (previousState != "in")
        {
            this._currentState := "in"
            if (isSmooth)
            {
                this._smoothStartTime := A_TickCount
                this._smoothEngine()
            }
            else
            {
                this._uniformDownAction()
                SetTimer(this._boundStop, -this._uniformDuration)
            }
        }
    }

    ; =============================================
    ;          “私有”方法
    ; =============================================

    __New(config := 0)
    {
        if (IsObject(config))
            for key, value in config.OwnProps()
            {
                local internalPropName := "_" . key
                if (this.HasOwnProp(internalPropName))
                    this.%internalPropName% := value
            }

        this._boundUniformDownAction := ObjBindMethod(this, "_uniformDownAction")
        this._boundUniformUpAction := ObjBindMethod(this, "_uniformUpAction")
        this._boundSmoothEngine := ObjBindMethod(this, "_smoothEngine")
        this._boundStop := ObjBindMethod(this, "_stop")
    }

    _easeOutQuad(p) => p * (2 - p)

    _uniformDownAction()
    {
        SendInput("{WheelDown}")
        SetTimer(this._boundUniformDownAction, this._uniformInterval)
    }
    _uniformUpAction()
    {
        SendInput("{WheelUp}")
        SetTimer(this._boundUniformUpAction, this._uniformInterval)
    }

    _smoothEngine()
    {
        if (this._currentState = "none")
        {
            return
        }

        if (this._currentState = "in")
            SendInput("{WheelDown}")
        else
            SendInput("{WheelUp}")

        local elapsedTime := A_TickCount - this._smoothStartTime
        if (elapsedTime >= this._smoothDuration)
        {
            this._stop()
            return
        }
        local progress := elapsedTime / this._smoothDuration
        local easedProgress := this._easeOutQuad(progress)
        local nextInterval := Round(this._minSmoothInterval + easedProgress * (this._maxSmoothInterval - this._minSmoothInterval))

        SetTimer(this._boundSmoothEngine, -nextInterval)
    }

    _stop()
    {
        SetTimer(this._boundUniformDownAction, 0)
        SetTimer(this._boundUniformUpAction, 0)
        SetTimer(this._boundSmoothEngine, 0)
        this._currentState := "none"
    }
}

if (A_ScriptFullPath == A_LineFile) {
    #HotIf WinActive("ahk_exe ck3.exe")
    #MaxThreadsPerHotkey 2
    #SingleInstance Force

    global zoom_g := Zoom()

    NumpadMult:: zoom_g.zoomIn()
    NumpadDiv:: zoom_g.zoomOut()
    ^NumpadMult:: zoom_g.zoomIn(false)
    ^NumpadDiv:: zoom_g.zoomOut(false)
}