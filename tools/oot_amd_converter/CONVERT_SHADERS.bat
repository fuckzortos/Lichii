@echo off
rem Adapts the Ocarina of Time AMD shader pack to this PC's driver. Plain text: open it and read it.
rem It only reads and writes files in this folder and does not use the internet.
title Convert Shaders
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=Get-Content -LiteralPath '%~f0' -Raw; $c=$s.Substring($s.LastIndexOf('//CSHARP')); Add-Type -TypeDefinition $c; exit [Converter]::Run('%~dp0.')"
set rc=%errorlevel%
if not "%~1"=="--no-pause" pause
exit /b %rc%
//CSHARP
using System; using System.IO; using System.Text; using System.Collections.Generic;
public static class Converter {
    const int KeyGfx = 1056, KeyCompute = 24, OffRaw1 = 48, OffDriverId = 64, OffDriverVer = 68;
    const uint FeatureBits = 0x10003f, DriverAmd = 1;
    struct Entry { public long Begin, End; public int Key; }

    static List<Entry> Walk(byte[] d, string name) {
        if (d.Length < 12 || Encoding.ASCII.GetString(d, 0, 8) != "yuzucach") throw new Exception(name + " is invalid.");
        if (BitConverter.ToUInt32(d, 8) != 53) throw new Exception(name + " is not version 53.");
        var o = new List<Entry>(); long p = 12;
        while (p < d.Length) {
            long b = p; Need(d, p, 4, name);
            uint n = BitConverter.ToUInt32(d, (int)p); p += 4;
            if (n < 1 || n > 5) throw new Exception(name + " is corrupted.");
            uint first = 0;
            for (uint i = 0; i < n; i++) {
                Need(d, p, 76, name);
                var c = new ulong[6];
                for (int j = 0; j < 6; j++) { c[j] = BitConverter.ToUInt64(d, (int)p + j * 8); if (c[j] > (1UL << 24)) throw new Exception(name + " is corrupted."); }
                uint stage = BitConverter.ToUInt32(d, (int)p + 72); p += 76;
                if (stage > 8) throw new Exception(name + " is corrupted.");
                if (i == 0) first = stage;
                long tail = stage == 5 ? 16 : 0x50;
                if (stage == 3) tail += 32;
                if (stage == 7 || stage == 8) tail += 92;
                long size = (long)c[0] + (long)c[1] * 8 + (long)c[2] * 8 + (long)c[3] * 12 + (long)c[4] * 9 + (long)c[5] * 12 + tail;
                Need(d, p, size, name); p += size;
            }
            int key = first == 5 ? KeyCompute : KeyGfx;
            Need(d, p, key, name); p += key;
            o.Add(new Entry { Begin = b, End = p, Key = key });
        }
        return o;
    }
    static void Need(byte[] d, long p, long n, string name) { if (n > d.Length - p) throw new Exception(name + " is truncated."); }
    static string K(byte[] d, int off, int len) { return Encoding.GetEncoding(28591).GetString(d, off, len); }

    public static int Run(string root) {
        try {
            string title = Path.Combine(root, @"user\cache\shader\0400486024dec000");
            string live = Path.Combine(title, "vulkan.fork-v53.bin");
            string pack = Path.Combine(root, @"shaders_amd\oot_amd_pack.bin");
            if (!File.Exists(pack)) throw new Exception("Missing shaders_amd\\oot_amd_pack.bin. Extract the whole zip first.");
            if (!File.Exists(live)) throw new Exception("Play first! Start the game, wait until you can walk around, close the emulator, then run this again.");

            Console.WriteLine("Reading this PC's shaders...");
            byte[] local = File.ReadAllBytes(live);
            var le = Walk(local, "Your shader cache");
            int sample = -1;
            foreach (var e in le) if (e.Key == KeyGfx) sample = (int)e.End - KeyGfx;
            if (sample < 0) throw new Exception("Play a bit longer! Wait until you can walk around, close the emulator, then run this again.");
            uint id = BitConverter.ToUInt32(local, sample + OffDriverId);
            uint ver = BitConverter.ToUInt32(local, sample + OffDriverVer);
            uint feat = BitConverter.ToUInt32(local, sample + OffRaw1) & FeatureBits;
            if (id != DriverAmd) throw new Exception("AMD GPUs only (official driver). Your GPU is not supported.");

            Console.WriteLine("Converting the shader pack. This can take a minute...");
            byte[] bas = File.ReadAllBytes(pack);
            var be = Walk(bas, "The shader pack");
            string tmp = live + ".tmp";
            var seen = new HashSet<string>(); long fromPc = 0, fromPack = 0;
            using (var w = new FileStream(tmp, FileMode.Create, FileAccess.Write, FileShare.None, 1 << 20)) {
                w.Write(bas, 0, 12);
                foreach (var e in le)
                    if (seen.Add(K(local, (int)e.End - e.Key, e.Key))) { w.Write(local, (int)e.Begin, (int)(e.End - e.Begin)); fromPc++; }
                foreach (var e in be) {
                    int k = (int)e.End - e.Key;
                    if (e.Key == KeyGfx) {
                        uint raw = (BitConverter.ToUInt32(bas, k + OffRaw1) & ~FeatureBits) | feat;
                        Array.Copy(BitConverter.GetBytes(raw), 0, bas, k + OffRaw1, 4);
                        Array.Copy(BitConverter.GetBytes(id), 0, bas, k + OffDriverId, 4);
                        Array.Copy(BitConverter.GetBytes(ver), 0, bas, k + OffDriverVer, 4);
                    }
                    if (seen.Add(K(bas, k, e.Key))) { w.Write(bas, (int)e.Begin, (int)(e.End - e.Begin)); fromPack++; }
                }
            }
            bas = null;
            if (Walk(File.ReadAllBytes(tmp), "The converted cache").Count != fromPc + fromPack) throw new Exception("Check failed. Nothing was changed.");
            File.Copy(live, Path.Combine(title, "vulkan.fork-v53.backup"), true);
            File.Delete(live); File.Move(tmp, live);
            Console.WriteLine();
            Console.WriteLine("DONE! " + (fromPc + fromPack) + " shaders ready. You can play now.");
            return 0;
        } catch (Exception ex) {
            Console.WriteLine();
            Console.WriteLine("ERROR: " + ex.Message);
            return 1;
        }
    }
}
