[CmdletBinding()]
param(
    [ValidateSet('load', 'spike', 'both')]
    [string]$Mode = 'both',

    [string]$JmeterHome = $env:JMETER_HOME
)

$ErrorActionPreference = 'Stop'

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$planPath = Join-Path $root 'jmeter\blazedemo-template.jmx'
$reportsRoot = Join-Path $root 'reports'
$dataFile = Join-Path $root 'data\passengers.csv'

function Get-JMeterBat {
    param([string]$Home)

    if ($Home) {
        $candidate = Join-Path $Home 'bin\jmeter.bat'
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    $command = Get-Command jmeter.bat -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    throw 'JMeter nao encontrado. Defina JMETER_HOME ou coloque jmeter.bat no PATH.'
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
    $jtlPath = Join-Path $runDir 'results.jtl'
    $reportDir = Join-Path $runDir 'html-report'

    if (Test-Path $runDir) {
        Remove-Item $runDir -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path $runDir | Out-Null

    $args = @(
        '-n'
        '-t', $script:PlanPath
        '-l', $jtlPath
        '-e'
        '-o', $reportDir
        "-JdataFile=$script:DataFile"
        "-Jthreads=$Threads"
        "-JrampUp=$RampUp"
        "-Jduration=$Duration"
        "-Jthroughput=$Throughput"
    )

    & $script:JMeterBat @args
}

if (-not (Test-Path $dataFile)) {
    throw "Arquivo de dados nao encontrado: $dataFile"
}

$script:JMeterBat = Get-JMeterBat -Home $JmeterHome
$script:PlanPath = $planPath
$script:DataFile = $dataFile

New-Item -ItemType Directory -Force -Path $reportsRoot | Out-Null

switch ($Mode) {
    'load' {
        Invoke-JMeterProfile -RunName 'load' -Threads '500' -RampUp '300' -Duration '900' -Throughput '250'
    }
    'spike' {
        Invoke-JMeterProfile -RunName 'spike' -Threads '1000' -RampUp '60' -Duration '180' -Throughput '250'
    }
    'both' {
        Invoke-JMeterProfile -RunName 'load' -Threads '500' -RampUp '300' -Duration '900' -Throughput '250'
        Invoke-JMeterProfile -RunName 'spike' -Threads '1000' -RampUp '60' -Duration '180' -Throughput '250'
    }
}
