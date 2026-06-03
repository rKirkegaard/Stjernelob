<#
.SYNOPSIS
    Venter på den nyeste GitHub Actions-kørsel og rapporterer resultatet.
    Ved fejl hentes de fejlende jobs' logs (sidste linjer) automatisk.

    Repoet er offentligt, så status kan læses uden auth; logs kræver auth, som
    hentes fra Git Credential Manager (token printes aldrig).
#>
param(
    [string] $Repo = "rKirkegaard/Stjernelob",
    [int] $MaxPolls = 90,
    [int] $IntervalSeconds = 20,
    [int] $TailLines = 45
)

$ErrorActionPreference = 'Stop'
$headers = @{ "User-Agent" = "claude"; "Accept" = "application/vnd.github+json" }

function Get-Token {
    $cred = ("protocol=https`nhost=github.com`n`n" | git credential fill 2>$null)
    (($cred | Select-String "^password=") -replace "password=", "").Trim()
}

Start-Sleep -Seconds 15
$runId = $null
for ($i = 0; $i -lt $MaxPolls; $i++) {
    try {
        $r = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/actions/runs?per_page=1" -Headers $headers -TimeoutSec 20
        $run = $r.workflow_runs[0]
        $runId = $run.id
        if ($run.status -eq "completed") {
            Write-Host ("DONE conclusion={0} sha={1} runid={2}" -f $run.conclusion, $run.head_sha.Substring(0, 7), $run.id)
            if ($run.conclusion -ne "success") {
                $tok = Get-Token
                $authHeaders = $headers.Clone()
                if ($tok) { $authHeaders["Authorization"] = "Bearer $tok" }
                $jobs = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/actions/runs/$($run.id)/jobs" -Headers $authHeaders -TimeoutSec 25
                foreach ($j in $jobs.jobs) {
                    if ($j.conclusion -eq "success") { continue }
                    Write-Host ("########## FAILED JOB: {0} => {1} ##########" -f $j.name, $j.conclusion)
                    try {
                        $resp = Invoke-WebRequest -Uri "https://api.github.com/repos/$Repo/actions/jobs/$($j.id)/logs" -Headers $authHeaders -TimeoutSec 40
                        $lines = $resp.Content -split "`n"
                        $start = [Math]::Max(0, $lines.Count - $TailLines)
                        $lines[$start..($lines.Count - 1)] | ForEach-Object { Write-Host $_ }
                    } catch { Write-Host ("LOG_FAIL: " + $_.Exception.Message) }
                }
            }
            exit 0
        }
        Write-Host ("...{0} status={1} sha={2}" -f $i, $run.status, $run.head_sha.Substring(0, 7))
    } catch { Write-Host ("poll_fail: " + $_.Exception.Message) }
    Start-Sleep -Seconds $IntervalSeconds
}
Write-Host "TIMEOUT_WAITING (sidste runid=$runId)"
