[CmdletBinding()]
param(
	[Parameter(ValueFromRemainingArguments = $true)]
	[string[]]$PiArgs
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location -LiteralPath $repoRoot

function ConvertTo-ProxyUrl {
	param([string]$Value)

	if (-not $Value) {
		return $null
	}
	if ($Value -match "^[a-z][a-z0-9+.-]*://") {
		return $Value
	}
	return "http://$Value"
}

function Get-ProxyUrl {
	if ($env:HTTPS_PROXY) {
		return ConvertTo-ProxyUrl $env:HTTPS_PROXY
	}
	if ($env:HTTP_PROXY) {
		return ConvertTo-ProxyUrl $env:HTTP_PROXY
	}

	$internetSettings = Get-ItemProperty `
		-LiteralPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" `
		-ErrorAction SilentlyContinue
	if (-not $internetSettings -or $internetSettings.ProxyEnable -ne 1 -or -not $internetSettings.ProxyServer) {
		return $null
	}

	$proxyServer = [string]$internetSettings.ProxyServer
	if ($proxyServer -notmatch ";") {
		return ConvertTo-ProxyUrl $proxyServer
	}

	$entries = @{}
	foreach ($part in $proxyServer.Split(";", [System.StringSplitOptions]::RemoveEmptyEntries)) {
		$keyValue = $part.Split("=", 2)
		if ($keyValue.Count -eq 2) {
			$entries[$keyValue[0].Trim().ToLowerInvariant()] = $keyValue[1].Trim()
		}
	}

	if ($entries.ContainsKey("https")) {
		return ConvertTo-ProxyUrl $entries["https"]
	}
	if ($entries.ContainsKey("http")) {
		return ConvertTo-ProxyUrl $entries["http"]
	}
	return $null
}

$proxyUrl = Get-ProxyUrl
if ($proxyUrl) {
	$env:HTTP_PROXY = $proxyUrl
	$env:HTTPS_PROXY = $proxyUrl
	$env:ALL_PROXY = $proxyUrl
	$env:NPM_CONFIG_PROXY = $proxyUrl
	$env:NPM_CONFIG_HTTPS_PROXY = $proxyUrl
}
$env:NODE_USE_ENV_PROXY = "1"

$npm = (Get-Command npm.cmd -ErrorAction Stop).Source
$tsx = Join-Path $repoRoot "node_modules\.bin\tsx.cmd"
if (-not (Test-Path -LiteralPath $tsx)) {
	Write-Host "Pi200: installing workspace dependencies..."
	& $npm install --ignore-scripts
	if ($LASTEXITCODE -ne 0) {
		throw "Dependency installation failed with exit code $LASTEXITCODE."
	}
}

$modelDataCheck = & $npm run check:model-data 2>&1
if ($LASTEXITCODE -ne 0) {
	Write-Host "Pi200: model data is missing or stale; hydrating it now..."
	& $npm run hydrate:model-data
	if ($LASTEXITCODE -ne 0) {
		throw "Model data hydration failed with exit code $LASTEXITCODE."
	}

	& $npm run check:model-data
	if ($LASTEXITCODE -ne 0) {
		throw "Model data validation failed with exit code $LASTEXITCODE."
	}
}

$bashCandidates = @(
	$env:PI_BASH_PATH,
	(Join-Path $env:ProgramFiles "Git\bin\bash.exe"),
	(Join-Path $env:LOCALAPPDATA "Programs\Git\bin\bash.exe")
)
$bash = $bashCandidates | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
if (-not $bash) {
	throw "Git Bash was not found. Install Git for Windows or set PI_BASH_PATH."
}

$piTest = (Join-Path $repoRoot "pi-test.sh").Replace("\", "/")
& $bash $piTest @PiArgs
exit $LASTEXITCODE
