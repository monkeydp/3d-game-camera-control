#Requires AutoHotkey v2.0

class Zoom
{
    ; =============================================
    ;          公共接口 (Public API)
    ; =============================================
    
    static zoomIn(isSmooth := true)
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
                SetTimer(this._boundUniformUpAction, this._uniformInterval)
                SetTimer(this._boundStop, -this._uniformDuration)
            }
        }
    }

    static zoomOut(isSmooth := true)
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
                SetTimer(this._boundUniformDownAction, this._uniformInterval)
                SetTimer(this._boundStop, -this._uniformDuration)
            }
        }
    }

    ; =============================================
    ;          “私有”属性 (Internal Properties)
    ; =============================================
    
    static _uniformInterval := 100 
    static _uniformDuration := 5000
    static _smoothDuration := 2000
    static _minSmoothInterval := 30
    static _maxSmoothInterval := 100
    static _currentState := "none"
    static _smoothStartTime := 0
    
    static _boundUniformDownAction := ObjBindMethod(Zoom, "_uniformDownAction")
    static _boundUniformUpAction := ObjBindMethod(Zoom, "_uniformUpAction")
    static _boundSmoothEngine := ObjBindMethod(Zoom, "_smoothEngine")
    static _boundStop := ObjBindMethod(Zoom, "_stop")
    
    ; =============================================
    ;          “私有”方法 (Internal Methods)
    ; =============================================

    static _easeOutQuad(p) => p * (2 - p)
    
    static _uniformDownAction() => Send("{WheelDown}")
    static _uniformUpAction() => Send("{WheelUp}")
    
    static _smoothEngine()
    {
        if (this._currentState = "none")
        {
            return
        }

        if (this._currentState = "in")
        {
            Send("{WheelDown}")
        }
        else
        {
            Send("{WheelUp}")
        }

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

    static _stop()
    {
        SetTimer(this._boundUniformDownAction, 0)
        SetTimer(this._boundUniformUpAction, 0)
        SetTimer(this._boundSmoothEngine, 0)
        this._currentState := "none"
    }
}