# Lichii OoT - AMD Shader Pack

**AMD GPUs only.** Ocarina of Time (Switch 2) with a save, settings and 32,000+ shaders. Nothing to install.

## Gameplay

[Video 1](https://github.com/fuckzortos/Lichii/releases/download/oot-amd-shaders-1/gameplay_1.mp4) | [Video 2](https://github.com/fuckzortos/Lichii/releases/download/oot-amd-shaders-1/gameplay_2.mp4) | [Video 3](https://github.com/fuckzortos/Lichii/releases/download/oot-amd-shaders-1/gameplay_3.mp4)

## How to play

1. **[Download the zip from Proton Drive](https://drive.proton.me/urls/25QBBAMTN0#SP1WG7MEHfXy)** and unzip it.
2. **Double-click `PLAY.bat`**, add your game folder and start the game. You need your own copy.
3. **Wait until you can walk around, then close the emulator.** The shaders convert automatically. Wait for `DONE!`.
4. **Double-click `PLAY.bat` again and play.**

> [!CAUTION]
> **Use `PLAY.bat`, not `lichii.exe`, and don't skip step 3.** Without it the shaders won't work and the game will stutter.

**Updated your AMD driver? Delete `user\.shaders_converted` and repeat steps 2 to 4.**

## Why convert?

Shaders only work with the driver they were made for. The converter adapts them to yours. It's a plain text file, so you can open and read it. It doesn't use the internet.

## Help

| Problem | Fix |
|---|---|
| `Play first!` or `Play a bit longer!` | Do steps 2 and 3 again |
| `AMD GPUs only` | Your GPU is not supported |
| Only 3-4k shaders load at boot | Normal. The rest load when needed |
| Small stutter in new areas | Normal the first time |
| Game closes by itself | Probably out of RAM (16 GB recommended). Close other apps |

Keep **Limit speed** on.

## Credits

The emulator is the work of [conongnang/Lichii](https://github.com/conongnang/Lichii), based on [zortos293/Lichii](https://github.com/zortos293/Lichii), and its contributors. **We only made the shader cache and the converter.**

The included `lichii.exe` is the original build with only its version name changed to `holycow-clohan-amd-shader`. License: GPLv3
