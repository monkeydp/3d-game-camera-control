#Requires AutoHotkey v2.0
#SingleInstance Force

; 加载库
#include <AutoHotInterception>

; --- 全局变量和 AHI 初始化 ---
global AHI := AutoHotInterception()
global keyboardId := 1

; --- 【核心配置区】---
; 在这里定义所有你想要的重映射规则

; 1. 定义按键扫描码常量，让代码更易读
global SC_UP    := 328
global SC_RIGHT := 333
global SC_LEFT  := 331
global SC_DOWN  := 336

; 2. 定义小键盘数字键的扫描码
global NUMPAD_1 := 79
global NUMPAD_2 := 80
global NUMPAD_3 := 81
global NUMPAD_4 := 75
global NUMPAD_6 := 77
global NUMPAD_7 := 71
global NUMPAD_8 := 72
global NUMPAD_9 := 73


; 3. 创建映射表 (Map)
;    键 (Key) 是你要按下的原始按键
;    值 (Value) 是一个包含所有目标按键扫描码的数组 (Array)
global KeyMappings := Map(
    ; --- 对角线映射 (原有的) ---
    NUMPAD_1, [SC_LEFT, SC_DOWN],
    NUMPAD_3, [SC_RIGHT, SC_DOWN],
    NUMPAD_7, [SC_LEFT, SC_UP],
    NUMPAD_9, [SC_RIGHT, SC_UP],

    ; --- 上下左右映射 (新增的) ---
    NUMPAD_8, [SC_UP],
    NUMPAD_2, [SC_DOWN],
    NUMPAD_4, [SC_LEFT],
    NUMPAD_6, [SC_RIGHT]
)

; --- 【核心逻辑函数】(无需任何修改) ---
HandleRemap(triggerCode, state) {
    global keyboardId, AHI, KeyMappings
    targetKeys := KeyMappings[triggerCode]
    for keyCode in targetKeys {
        AHI.SendKeyEvent(keyboardId, keyCode, state)
    }
}


; --- 【主事件处理函数】(无需任何修改) ---
KeyEvent(code, state) {
    global KeyMappings
    if (KeyMappings.Has(code)) {
        HandleRemap(code, state)
        return 0
    }
    AHI.SendKeyEvent(keyboardId, code, state)
    return 0
}

; -----------------------------------------------------------------
; 设置键盘拦截
AHI.SubscribeKeyboard(keyboardId, true, KeyEvent)

; 使用热键来强制脚本持久化 (修正为您之前使用的有效代码)
NumpadSub::
{
    Suspend
}
; -----------------------------------------------------------------