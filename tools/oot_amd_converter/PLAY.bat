@echo off
rem Starts the game. First time: shows the instructions. After the first play: converts the shaders once.
title holycow-clohan-amd-shader
cd /d "%~dp0"
set "welcomed=user\.welcome_done"
set "converted=user\.shaders_converted"
set "cache=user\cache\shader\0400486024dec000\vulkan.fork-v53.bin"

if not exist "%welcomed%" (
  powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $t='WELCOME! Please follow these steps:' + [char]10 + [char]10 + '1. Add your game folder and start the game.' + [char]10 + '2. Wait until you can walk around.' + [char]10 + '3. Close the emulator. The shaders will convert automatically.' + [char]10 + '4. Open PLAY.bat again and enjoy.' + [char]10 + [char]10 + 'Always start the game with PLAY.bat until the shaders are converted.' + [char]10 + [char]10 + 'Would you like to star the project on GitHub?'; if([Windows.Forms.MessageBox]::Show($t,'holycow-clohan-amd-shader','YesNo','Information') -eq 'Yes'){Start-Process 'https://github.com/fuckzortos/Lichii'}"
  type nul > "%welcomed%"
)

start "" /wait "%~dp0lichii.exe" %*

if exist "%converted%" exit /b 0
if not exist "%cache%" (
  echo The shaders were not converted because the game was not played yet.
  echo Open PLAY.bat, start the game and wait until you can walk around.
  pause
  exit /b 1
)
call "%~dp0CONVERT_SHADERS.bat" --no-pause
if errorlevel 1 (
  pause
  exit /b 1
)
type nul > "%converted%"
echo.
echo Open PLAY.bat again to play with all the shaders.
pause
