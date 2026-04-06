[CmdletBinding()]
param(
    [ValidateSet('load', 'spike', 'both')]
    [string]$Mode = 'both',

    [string]$ImageName = 'blazedemo-performance:jmeter-5.6.3',

    [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$reportsRoot = Join-Path $root 'reports'
$generatedRoot = Join-Path $root '.generated'
$log4jConfig = '/workspace/config/log4j2-console.xml'

function Assert-DockerAvailable {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        throw 'Docker nao encontrado. Instale o Docker Desktop ou o Docker Engine e tente novamente.'
    }
}

function Invoke-DockerBuild {
    param([string]$ContextPath)

    & docker build -t $ImageName $ContextPath
}

function Invoke-JMeterProfile {
    param(
        [string]$RunName,
        [string]$Threads,
        [string]$RampUp,
        [string]$Duration,
        [string]$Throughput
    )

    $runDir = Join-Path $reportsRoot $RunName
    $planFile = Join-Path $generatedRoot "$RunName.jmx"
    $planFileContainer = "/workspace/.generated/$RunName.jmx"
    $jtlPath = "/workspace/reports/$RunName/results.jtl"
    $reportDir = "/workspace/reports/$RunName/html-report"
    $logPath = Join-Path $runDir 'run.log'

    if (Test-Path $runDir) {
        Remove-Item $runDir -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path $runDir | Out-Null

    $template = Get-Content (Join-Path $root 'jmeter\blazedemo-template.jmx') -Raw
    $rendered = $template.
        Replace('__THREADS__', $Threads).
        Replace('__RAMPUP__', $RampUp).
        Replace('__DURATION__', $Duration).
        Replace('__THROUGHPUT__', $Throughput)

    New-Item -ItemType Directory -Force -Path $generatedRoot | Out-Null
    [System.IO.File]::WriteAllText($planFile, $rendered, [System.Text.Encoding]::ASCII)

    & docker run --rm `
        -v "${root}:/workspace" `
        -w /workspace `
        -e "JVM_ARGS=-Dlog4j2.configurationFile=$log4jConfig" `
        $ImageName `
        -n `
        -t $planFileContainer `
        -l $jtlPath `
        -e `
        -o $reportDir 2>&1 | Tee-Object -FilePath $logPath

    $exitCode = $LASTEXITCODE
    $reportIndex = Join-Path $runDir 'html-report\index.html'

    if ($exitCode -ne 0) {
        Write-Warning "$RunName falhou com exit code $exitCode"
        return $false
    }

    if (-not (Test-Path $reportIndex)) {
        Write-Warning "$RunName nao gerou html-report/index.html"
        return $false
    }

    return $true
}

Assert-DockerAvailable

New-Item -ItemType Directory -Force -Path $reportsRoot | Out-Null

if (-not $SkipBuild) {
    Invoke-DockerBuild -ContextPath $root
}

switch ($Mode) {
    'load' {
        $null = Invoke-JMeterProfile -RunName 'load' -Threads '500' -RampUp '300' -Duration '900' -Throughput '250'
    }
    'spike' {
        $null = Invoke-JMeterProfile -RunName 'spike' -Threads '1000' -RampUp '60' -Duration '180' -Throughput '250'
    }
    'both' {
        $loadOk = Invoke-JMeterProfile -RunName 'load' -Threads '500' -RampUp '300' -Duration '900' -Throughput '250'
        $spikeOk = Invoke-JMeterProfile -RunName 'spike' -Threads '1000' -RampUp '60' -Duration '180' -Throughput '250'
        if (-not $loadOk -or -not $spikeOk) {
            throw 'Um ou mais perfis falharam. Consulte os logs em reports/<perfil>/run.log.'
        }
    }
}
