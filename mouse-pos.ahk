#Requires AutoHotkey v2.0

class MousePos
{
    ; =============================================
    ;          公共接口 (Public API)
    ; =============================================
    
    record(key, *) {
        this._recordPosition(key)
    }

    moveTo(key, *) {
        this._moveToPosition(key)
    }

    ; =============================================
    ;          “私有”属性 (实例属性)
    ; =============================================

    _positions := []
    _posFile := A_ScriptDir . "\pos.txt"
    
    ; =============================================
    ;          “私有”方法 (实例方法)
    ; =============================================

    __New()
    {
        this._initializeAndLoadPositions()
    }
    
    _hideToolTip() {
        ToolTip()
    }

    _getKeyAsIndex(key) {
        return Integer(key) + 1
    }

    _getIndexAsKey(index) {
        return index - 1
    }

    _initializeAndLoadPositions() {
        this._positions := []
        Loop 10 {
            this._positions.Push({x: "", y: "", remark: ""})
        }
        if !FileExist(this._posFile) {
            return
        }
        try {
            local lineNum := 0
            Loop Read this._posFile
            {
                lineNum += 1
                if (lineNum > 10) {
                    break
                }
                if (A_LoopReadLine = "") {
                    continue
                }
                local parts := StrSplit(A_LoopReadLine, ",",, 4)
                if (parts.Length >= 3) {
                    this._positions[lineNum].x := Trim(parts[2])
                    this._positions[lineNum].y := Trim(parts[3])
                    this._positions[lineNum].remark := (parts.Length >= 4) ? Trim(parts[4]) : ""
                }
            }
        } catch {
            MsgBox("读取位置文件 '" . this._posFile . "' 时发生错误。")
        }
    }

    _savePositions() {
        local fileContent := ""
        Loop 10 {
            local index := A_Index
            local key := this._getIndexAsKey(index)
            local pos := this._positions[index]
            fileContent .= key . "," . pos.x . "," . pos.y . "," . pos.remark . "`n"
        }
        try {
            local fileObj := FileOpen(this._posFile, "w", "UTF-8")
            fileObj.Write(Trim(fileContent, "`n"))
            fileObj.Close()
        } catch {
            MsgBox("写入位置文件 '" . this._posFile . "' 时发生错误。")
        }
    }

    _recordPosition(key) {
        MouseGetPos(&x, &y)
        local index := this._getKeyAsIndex(key)
        local pos := this._positions[index]

        if (pos.x != "") {
            local remarkText := (Trim(pos.remark) != "") ? " (" . pos.remark . ")" : ""
            local message := "位置 '" . key . "'" . remarkText . " 已存在。是否要覆盖？"
            if (MsgBox(message,, "YesNo") = "No") {
                return
            }
        }
        
        this._positions[index] := {x: x, y: y, remark: pos.remark}
        this._savePositions()
        
        ToolTip("位置 " . key . " 已保存: (" . x . ", " . y . ")")
        SetTimer(ObjBindMethod(this, "_hideToolTip"), -1500)
    }

    _moveToPosition(key) {
        local index := this._getKeyAsIndex(key)
        local pos := this._positions[index]
        if (pos.x != "") {
            MouseMove(pos.x, pos.y, 0)
        } else {
            ToolTip("位置 " . key . " 尚未记录。")
            SetTimer(ObjBindMethod(this, "_hideToolTip"), -1500)
        }
    }
}