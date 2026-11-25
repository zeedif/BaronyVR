param([string]$Name='desk')
Add-Type -AssemblyName System.Drawing
Add-Type @'
using System; using System.Runtime.InteropServices;
public static class Gw2 { [StructLayout(LayoutKind.Sequential)] public struct R { public int L,T,Ri,B; } [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out R r); }
'@ -ErrorAction SilentlyContinue
$h=(Get-Process barony).MainWindowHandle; $r=New-Object Gw2+R; [Gw2]::GetWindowRect($h,[ref]$r)|Out-Null
$w=$r.Ri-$r.L; $hh=$r.B-$r.T; $bmp=New-Object Drawing.Bitmap $w,$hh; $g=[Drawing.Graphics]::FromImage($bmp); $g.CopyFromScreen($r.L,$r.T,0,0,$bmp.Size); $g.Dispose()
$s=New-Object Drawing.Bitmap $bmp,([int]($w/3)),([int]($hh/3)); $o="C:\Users\Zeedif\AppData\Local\Temp\claude\cd169be80d5e8cc5\814dbfd4-a014-41a5-a8a3-90a6c791cee1\scratchpad\$Name.png"; $s.Save($o,[Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose(); $s.Dispose(); $o
