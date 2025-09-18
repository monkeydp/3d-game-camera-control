#Requires AutoHotkey v2.0

class Zoom
{
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
                this._uniformCurrentInterval := this._uniformInitialInterval
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
                this._uniformCurrentInterval := this._uniformInitialInterval
                this._uniformDownAction()
                SetTimer(this._boundStop, -this._uniformDuration)
            }
        }
    }

    ; =============================================
    ;          “私有”属性 (实例属性)
    ; =============================================
    
    _uniformDuration := 5000 
    _uniformInitialInterval := 100
    _uniformSpeedIncrement := 10
    _uniformMinInterval := 10
    _uniformSpeedUpKey := "Insert"
    _uniformSpeedDownKey := "Delete"
    _uniformCurrentInterval := 100
    
    _smoothDuration := 2000
    _minSmoothInterval := 30
    _maxSmoothInterval := 100
    
    _currentState := "none"
    _smoothStartTime := 0
    
    _boundUniformDownAction := ""
    _boundUniformUpAction := ""
    _boundSmoothEngine := ""
    _boundStop := ""
    
    ; =============================================
    ;          “私有”方法 (实例方法)
    ; =============================================
    
    ; --- 实例构造函数 ---
    __New()
    {
        this._boundUniformDownAction := ObjBindMethod(this, "_uniformDownAction")
        this._boundUniformUpAction := ObjBindMethod(this, "_uniformUpAction")
        this._boundSmoothEngine := ObjBindMethod(this, "_smoothEngine")
        this._boundStop := ObjBindMethod(this, "_stop")
        
        Hotkey(this._uniformSpeedUpKey, ObjBindMethod(this, "_increaseUniformSpeed"))
        Hotkey(this._uniformSpeedDownKey, ObjBindMethod(this, "_decreaseUniformSpeed"))
    }
    
    _easeOutQuad(p) => p * (2 - p)
    
    _uniformDownAction()
    {
        Send("{WheelDown}")
        SetTimer(this._boundUniformDownAction, this._uniformCurrentInterval)
    }
    _uniformUpAction()
    {
        Send("{WheelUp}")
        SetTimer(this._boundUniformUpAction, this._uniformCurrentInterval)
    }

    _increaseUniformSpeed()
    {
        if (this._currentState = "in" or this._currentState = "out")
        {
            this._uniformCurrentInterval -= this._uniformSpeedIncrement
            if (this._uniformCurrentInterval < this._uniformMinInterval)
                this._uniformCurrentInterval := this._uniformMinInterval
        }
    }
    _decreaseUniformSpeed()
    {
        if (this._currentState = "in" or this._currentState = "out")
            this._uniformCurrentInterval += this._uniformSpeedIncrement
    }
    
    _smoothEngine()
    {
        if (this._currentState = "none")
            return
        

        if (this._currentState = "in")
            Send("{WheelDown}")
        else
            Send("{WheelUp}")

        local elapsedTime := A_TickCount - this._smoothStartTime
        if (elapsedTime >= this._smoothDuration) {
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