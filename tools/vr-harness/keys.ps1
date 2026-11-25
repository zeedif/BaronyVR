param([string[]]$Keys = @(), [int]$Wait = 4)
# Keys: names like space,enter,esc,up,down,left,right,tab,w,a,s,d,e,i or "mouse:x,y" (window client coords) or "sleep:ms"
Add-Type @'
using System; using System.Runtime.InteropServices;
public static class K2 {
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c);
 [DllImport("user32.dll")] public static extern void keybd_event(byte vk, byte scan, uint flags, UIntPtr extra);
 [DllImport("user32.dll")] public static extern void mouse_event(uint f, int dx, int dy, uint d, UIntPtr e);
 [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
 [StructLayout(LayoutKind.Sequential)] public struct P { public int X; public int Y; }
 [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr h, ref P p);
}
'@ -ErrorAction SilentlyContinue
$map = @{ space=@(0x20,0x39,0); enter=@(0x0D,0x1C,0); esc=@(0x1B,0x01,0); up=@(0x26,0x48,1); down=@(0x28,0x50,1); left=@(0x25,0x4B,1); right=@(0x27,0x4D,1); tab=@(0x09,0x0F,0); w=@(0x57,0x11,0); a=@(0x41,0x1E,0); s=@(0x53,0x1F,0); d=@(0x44,0x20,0); e=@(0x45,0x12,0); i=@(0x49,0x17,0) }
$p = Get-Process barony -ErrorAction Stop | Select-Object -First 1; $h = $p.MainWindowHandle
[K2]::keybd_event(0x12,0,0,[UIntPtr]::Zero); [K2]::keybd_event(0x12,0,2,[UIntPtr]::Zero)
[K2]::ShowWindow($h, 9) | Out-Null; [K2]::SetForegroundWindow($h) | Out-Null; Start-Sleep -Milliseconds 300
foreach ($k in $Keys) {
  if ($k -like 'sleep:*') { Start-Sleep -Milliseconds ([int]$k.Substring(6)); continue }
  if ($k -like 'hold:*') { $n,$ms = $k.Substring(5).Split(','); $v=$map[$n]; $f=8; if($v[2]){$f=$f -bor 1}; [K2]::keybd_event([byte]$v[0],[byte]$v[1],$f,[UIntPtr]::Zero); Start-Sleep -Milliseconds ([int]$ms); [K2]::keybd_event([byte]$v[0],[byte]$v[1],$f -bor 2,[UIntPtr]::Zero); continue }
  if ($k -like 'mouse:*') { $xy = $k.Substring(6).Split(','); $pt = New-Object K2+P; $pt.X=[int]$xy[0]; $pt.Y=[int]$xy[1]; [K2]::ClientToScreen($h,[ref]$pt)|Out-Null; [K2]::SetCursorPos($pt.X,$pt.Y)|Out-Null; Start-Sleep -Milliseconds 150; [K2]::mouse_event(2,0,0,0,[UIntPtr]::Zero); Start-Sleep -Milliseconds 80; [K2]::mouse_event(4,0,0,0,[UIntPtr]::Zero); Start-Sleep -Milliseconds 300; continue }
  $v = $map[$k]; $f = 8; if ($v[2]) { $f = $f -bor 1 }
  [K2]::keybd_event([byte]$v[0],[byte]$v[1],$f,[UIntPtr]::Zero); Start-Sleep -Milliseconds 90; [K2]::keybd_event([byte]$v[0],[byte]$v[1],$f -bor 2,[UIntPtr]::Zero); Start-Sleep -Milliseconds 350
}
Start-Sleep $Wait
$d='D:\Juegos\SteamLibrary\steamapps\common\Barony\vr_debug'
$last=(Get-Content "$d\state.txt" -Tail 1).Substring(1,3)
Add-Type -AssemblyName System.Drawing
foreach($n in "gui_$last","eye_$last"){ if(Test-Path "$d\$n.bmp"){ $b=[Drawing.Bitmap]::FromFile("$d\$n.bmp"); $b.Save("$d\$n.png",[Drawing.Imaging.ImageFormat]::Png); $b.Dispose() } }
Get-Content "$d\state.txt" -Tail 1
"$d\gui_$last.png"; "$d\eye_$last.png"
