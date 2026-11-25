param([string]$Recording = 'D:\Workspace\BaronyVR-deps\recording.txt', [double]$Speed = 1.0)
# Replays a teleop recording into the simulated VR controllers.
$inputFile = 'D:\Workspace\BaronyVR-deps\vrinput.txt'
$state = [ordered]@{}
$clock = [Diagnostics.Stopwatch]::StartNew()
foreach ($line in Get-Content $Recording) {
    $parts = $line.Split("`t", 2)
    if ($parts.Count -lt 2) { continue }
    $at = [double]$parts[0] / $Speed
    while ($clock.ElapsedMilliseconds -lt $at) { Start-Sleep -Milliseconds 5 }
    if ($parts[1] -eq 'END') { break }
    $p = $parts[1].Split(' ', 3)
    $state["$($p[0]) $($p[1])"] = $p[2]
    [IO.File]::WriteAllLines($inputFile, [string[]]($state.GetEnumerator() | % { "$($_.Key) $($_.Value)" }))
}
'replay done'
