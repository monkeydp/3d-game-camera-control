#Requires AutoHotkey v2.0
#SingleInstance Force

; =============================================
;          全局设定
; =============================================
SendMode "Input"
CoordMode "Mouse", "Screen"
#HotIf WinActive("ahk_exe ck3.exe")

; =============================================
;          全局变量和初始化
; =============================================
global g_positions := []
global g_posFile := A_ScriptDir . "\pos.txt"
InitializeAndLoadPositions()

; =============================================
;          核心功能函数
; =============================================

HideToolTip() {
    ToolTip()
}

GetKeyAsIndex(key) {
    return Integer(key) + 1
}

GetIndexAsKey(index) {
    return index - 1
}

/**
 * 【已修正】初始化并从文件加载数据
 */
InitializeAndLoadPositions() {
    global g_positions, g_posFile
    g_positions := []
    Loop 10 {
        g_positions.Push({x: "", y: "", remark: ""})
    }
    if !FileExist(g_posFile) {
        return
    }
    try {
        local lineNum := 0
        Loop Read g_posFile
        {
            lineNum += 1
            if (lineNum > 10)
                break
            if (A_LoopReadLine = "")
                continue
            local parts := StrSplit(A_LoopReadLine, ",",, 4)
            if (parts.Length >= 3) {
                g_positions[lineNum].x := Trim(parts[2])
                g_positions[lineNum].y := Trim(parts[3])
                
                ; --- 【核心修正点】---
                ; 使用 parts.Length >= 4 来判断备注是否存在，而不是 IsSet()
                g_positions[lineNum].remark := (parts.Length >= 4) ? Trim(parts[4]) : ""
            }
        }
    } catch {
        MsgBox("读取位置文件 '" . g_posFile . "' 时发生错误。")
    }
}

SavePositions() {
    global g_positions, g_posFile
    local fileContent := ""
    Loop 10 {
        local index := A_Index
        local key := GetIndexAsKey(index)
        local pos := g_positions[index]
        fileContent .= key . "," . pos.x . "," . pos.y . "," . pos.remark . "`n"
    }
    try {
        local fileObj := FileOpen(g_posFile, "w", "UTF-8")
        fileObj.Write(Trim(fileContent, "`n"))
        fileObj.Close()
    } catch {
        MsgBox("写入位置文件 '" . g_posFile . "' 时发生错误。")
    }
}

RecordPosition(key) {
    global g_positions
    MouseGetPos(&x, &y)
    local index := GetKeyAsIndex(key)
    local pos := g_positions[index]

    if (pos.x != "") {
        local remarkText := ""
        if (Trim(pos.remark) != "") {
            remarkText := " (" . pos.remark . ")"
        }
        local message := "位置 '" . key . "'" . remarkText . " 已存在。是否要覆盖？"
        local response := MsgBox(message,, "YesNo")
        if (response = "No") {
            return
        }
    }
    
    g_positions[index] := {x: x, y: y, remark: pos.remark}
    SavePositions()
    
    ToolTip("位置 " . key . " 已保存: (" . x . ", " . y . ")")
    SetTimer(HideToolTip, -1500)
}

MoveToPosition(key) {
    global g_positions
    local index := GetKeyAsIndex(key)
    local pos := g_positions[index]
    if (pos.x != "") {
        MouseMove(pos.x, pos.y, 0)
    } else {
        ToolTip("位置 " . key . " 尚未记录。")
        SetTimer(HideToolTip, -1500)
    }
}

; =============================================
;          创建热键
; =============================================
; --- 移动鼠标 ---
0::MoveToPosition("0")
1::MoveToPosition("1")
2::MoveToPosition("2")
3::MoveToPosition("3")
4::MoveToPosition("4")
5::MoveToPosition("5")
6::MoveToPosition("6")
7::MoveToPosition("7")
8::MoveToPosition("8")
9::MoveToPosition("9")

; --- 记录坐标 ---
^0::RecordPosition("0")
^1::RecordPosition("1")
^2::RecordPosition("2")
^3::RecordPosition("3")
^4::RecordPosition("4")
^5::RecordPosition("5")
^6::RecordPosition("6")
^7::RecordPosition("7")
^8::RecordPosition("8")
^9::RecordPosition("9")