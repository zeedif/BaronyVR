param([string[]]$Set = @(), [int]$HoldMs = 0, [string[]]$After = @(), [int]$Wait = 1)
# Writes controller commands for BARONYVR_TEST_INPUT, optional timed release.
$f = 'D:\Workspace\BaronyVR-deps\vrinput.txt'
if (!(Test-Path $f)) { Set-Content $f '' }
$state = [ordered]@{}
foreach ($line in Get-Content $f) { $p = $line.Trim().Split(' ', 3); if ($p.Count -ge 3) { $state["$($p[0]) $($p[1])"] = $p[2] } }
function Write-State { $lines = $state.GetEnumerator() | % { "$($_.Key) $($_.Value)" }; [IO.File]::WriteAllLines($f, [string[]]$lines) }
foreach ($s in $Set) { $p = $s.Split(' ', 3); $state["$($p[0]) $($p[1])"] = $p[2] }; Write-State
if ($HoldMs -gt 0) { Start-Sleep -Milliseconds $HoldMs; foreach ($s in $After) { $p = $s.Split(' ', 3); $state["$($p[0]) $($p[1])"] = $p[2] }; Write-State }
Start-Sleep $Wait
$d='D:\Juegos\SteamLibrary\steamapps\common\Barony\vr_debug'
$last=((Get-Content "$d\state.txt") | ? { $_ -like '#*' })[-1].Substring(1,3)
Add-Type -AssemblyName System.Drawing
foreach($n in "eye_$last","gui_$last","prompt_$last","hotbar_$last"){ if(Test-Path "$d\$n.bmp"){ $b=[Drawing.Bitmap]::FromFile("$d\$n.bmp"); $b.Save("$d\$n.png",[Drawing.Imaging.ImageFormat]::Png); $b.Dispose(); "$d\$n.png" } }
Get-Content "$d\state.txt" -Tail 5
