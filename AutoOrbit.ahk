#Requires AutoHotkey v2.0

class AutoOrbit
{
    ; --- 可配置参数 ---
    _step_x := 2                  ; 每次向【右】移动的像素距离。
    _step_y := -0.3               ; 每次向【下】移动的像素距离 (允许小数)。
    _step_delay := 20             ; 每次移动之间的延迟 (毫秒)。
    _edge_margin := [100]         ; 屏幕边缘的安全距离 (上右下左)。
    _duration := 25.5             ; 主动环绕的时长 (秒)，0 为禁用。
    _release_delay_on_edge := 1   ; 碰到边缘或达到时长后，延迟多久松开右键 (秒)。
    _timeout := 60                ; 安全超时，防止脚本失控 (秒)。

    ; --- 内部状态变量 ---
    _isOrbiting := false
    _parsed_margins := ""
    _accumulated_y := 0.0
    _boundOrbitAction := ""
    _boundStop := ""
    _boundStopByCondition := ""

    __New(config := 0) {
        if (IsObject(config)) {
            for key, value in config.OwnProps() {
                local internalPropName := "_" . key
                if (this.HasOwnProp(internalPropName))
                    this.%internalPropName% := value
            }
        }
        this._parseMargins()
        this._boundOrbitAction := this._orbitAction.Bind(this)
        this._boundStop := this.stop.Bind(this)
        this._boundStopByCondition := this._stopByCondition.Bind(this)
    }

    /**
     * 关键方法: 切换环绕的开始或停止。
     */
    toggle() {
        if (this._isOrbiting)
            this.stop()
        else
            this.start()
    }

    /**
     * 关键方法: 启动环绕。
     */
    start() {
        this._isOrbiting := true
        this._accumulated_y := 0.0
        Click "Right Down"
        
        SetTimer(this._boundOrbitAction, this._step_delay)
        SetTimer(this._boundStop, -(this._timeout * 1000))
        if (this._duration > 0)
            SetTimer(this._boundStopByCondition, -(this._duration * 1000))
    }

    /**
     * 关键方法: 完全停止环绕。
     */
    stop() {
        if (!this._isOrbiting)
            return
        this._isOrbiting := false
        
        SetTimer(this._boundOrbitAction, 0)
        SetTimer(this._boundStop, 0)
        SetTimer(this._boundStopByCondition, 0)
        Click "Right Up"
    }

    _stopByCondition() {
        SetTimer(this._boundOrbitAction, 0)
        if (this._release_delay_on_edge = 0)
            this.stop()
        else
            SetTimer(this._boundStop, -(this._release_delay_on_edge * 1000))
    }

    _orbitAction() {
        MouseGetPos(&current_x, &current_y)
        if ( (current_x + this._step_x >= A_ScreenWidth - this._parsed_margins.right)
          || (current_x + this._step_x <= this._parsed_margins.left)
          || (current_y + this._step_y >= A_ScreenHeight - this._parsed_margins.bottom)
          || (current_y + this._step_y <= this._parsed_margins.top) )
            this._stopByCondition()
        else {
            local y_move_this_tick := 0
            this._accumulated_y += this._step_y
            if (Abs(this._accumulated_y) >= 1) {
                y_move_this_tick := Integer(this._accumulated_y)
                this._accumulated_y -= y_move_this_tick
            }
            MouseMove(this._step_x, y_move_this_tick, 0, "Relative")
        }
    }

    _parseMargins() {
        local top, right, bottom, left
        if IsObject(this._edge_margin) {
            switch this._edge_margin.Length {
                case 1: top := right := bottom := left := this._edge_margin[1]
                case 2: top := bottom := this._edge_margin[1], right  := left   := this._edge_margin[2]
                case 3: top := this._edge_margin[1], right  := left   := this._edge_margin[2], bottom := this._edge_margin[3]
                case 4: top := this._edge_margin[1], right  := this._edge_margin[2], bottom := this._edge_margin[3], left   := this._edge_margin[4]
                default: top := right := bottom := left := 50
            }
        } else
            top := right := bottom := left := 50
        this._parsed_margins := {top: top, right: right, bottom: bottom, left: left}
    }
}