# 3D Game Camera Control 3D游戏相机控制增强工具

A comprehensive camera control toolkit for 3D games that enhances the gaming experience with smooth movements, precise positioning, and intelligent camera controls.

这是一个为3D游戏开发的相机控制增强工具集，使用 AutoHotkey v2 编写。它提供了多个功能模块来增强游戏中的相机操控体验，适用于各类3D游戏，特别是战略、模拟、建造类游戏（如十字军之王3、Cities: Skylines、模拟人生等）。

[English | [中文](doc/README_zh.md)]

## Features

### 1. Numpad Camera Movement (AHIRemapper)
- Eight-direction camera control using numpad
- 1/3/7/9: Diagonal movement
- 2/4/6/8: Cardinal directions

### 2. Smooth Zoom (Zoom)
- `Numpad *`: Smooth zoom in
- `Numpad /`: Smooth zoom out
- `Ctrl + Numpad *`: Uniform speed zoom in
- `Ctrl + Numpad /`: Uniform speed zoom out

### 3. Position Memory System (MousePos)
- `0-9`: Jump to saved positions
- `Ctrl + 0-9`: Save current cursor position
- Positions stored in `pos.txt`

### 4. Smooth View Centering (SmoothPan)
- `Numpad 5`: Smoothly center the view
- Features overshoot and rebound effects for natural movement

### 5. Auto Orbit (AutoOrbit)
- `Numpad +`: Toggle auto orbit
- Right-click: Stop orbiting
- `Ctrl + Numpad +`: Reload script

## Requirements

1. AutoHotkey v2.0 or higher
2. AutoHotInterception library (only needed for multi-key combinations)
3. Supported OS: Windows 10/11
4. Compatible with most 3D games using standard camera controls

## Installation

1. Install [AutoHotkey v2](https://www.autohotkey.com/)
2. Install [AutoHotInterception](https://github.com/evilC/AutoHotInterception) library
3. Download all project files to the same directory
4. Run `main.ahk` to start all features

## Configuration

### Main Configuration (main.ahk)
- `wintitle`: Target window title (Example: "ahk_exe gamename.exe")
  - Modify to match your game window
  - Can use window class or process name
  - Examples: "ahk_exe CitiesSkylines.exe", "ahk_exe Sims4.exe"
- Module initialization parameters can be adjusted in this file

### Auto Orbit Configuration (AutoOrbit.ahk)
- `step_x`: Horizontal movement step
- `step_y`: Vertical movement step
- `step_delay`: Movement interval
- `duration`: Orbit duration
- `edge_margin`: Screen edge safety margin

### Smooth Pan Configuration (SmoothPan.ahk)
- `speed`: Movement speed
- `baseOvershootDuration`: Overshoot phase duration
- `baseSettleDuration`: Settle phase duration
- `overshootFactor`: Overshoot amplitude

### Zoom Configuration (Zoom.ahk)
- `uniformDuration`: Uniform zoom duration
- `smoothDuration`: Smooth zoom duration
- `minSmoothInterval`/`maxSmoothInterval`: Smooth zoom speed range

## Usage Tips

1. Position Memory:
   - Quick switch between important locations using number keys
   - Save new positions with Ctrl+number combinations

2. View Control:
   - Precise movement with numpad
   - Quick center view with Numpad 5
   - Combine with auto orbit for building/unit inspection

3. Zoom Control:
   - Short press for precise zooming
   - Long press for continuous zoom
   - Use Ctrl combinations for uniform speed

## Game Compatibility

The toolkit is especially suitable for:
1. Strategy games (e.g., Crusader Kings, Civilization series)
2. City builders (e.g., Cities: Skylines, Anno series)
3. Simulation games (e.g., The Sims, Planet Coaster)
4. Any 3D game requiring frequent camera manipulation

### Game-Specific Adjustments

Different games may require specific configurations:

1. Camera Movement Speed
   - Adjust based on game's native camera speed
   - Modify speed parameters in main.ahk

2. Orbit View
   - Some games might not support right-click drag
   - Adjust key bindings in AutoOrbit.ahk

3. Zoom Sensitivity
   - Fine-tune zoom parameters for different games
   - Modify settings in Zoom.ahk

4. Key Bindings
   - Modify key bindings if they conflict with game defaults
   - Change hotkey settings in main.ahk

## Troubleshooting

1. Numpad Not Responding:
   - Verify NumLock status
   - Check AutoHotInterception installation
   - Validate keyboard ID settings

2. Position Save Issues:
   - Check pos.txt write permissions
   - Verify file path configuration

3. Auto Orbit Problems:
   - Ensure game window is active
   - Check for conflicting mouse scripts

## Important Notes

- Script requires administrator privileges
- Launch after game starts
- Use Ctrl + Numpad + to reload if features stop working
- Backup settings before configuration changes

## Changelog

### 2025.9.19
- Integrated all feature modules
- Improved smooth movement algorithms
- Enhanced auto orbit functionality
- Added comprehensive documentation

## License

MIT License
