$scriptName = $MyInvocation.MyCommand.Name
$infoContents=(Get-Content info.json | ConvertFrom-Json)
$modName=$infoContents.name
$version=$infoContents.version
$zipName=$modName + '_' + $version + '.zip'
$tempDir="temp_package"

Write-Host "Building mod $($infoContents.title), v.$version"
Write-Host "Removing previous artefacts"

if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
if (Test-Path $modName) {
    Remove-Item $modName -Recurse -Force
}
if (Test-Path -Path $zipName) {
    Remove-Item -Path $zipName -Force
}

Write-Host "Copying contents to a temp folder"
New-Item -ItemType Directory -Path $tempDir | Out-Null

Get-ChildItem -LiteralPath . -Force | Where-Object {
    $_.Name -ne $tempDir -and
    $_.Name -ne $scriptName -and
    $_.Name -notlike ".git*"
} | Copy-Item -Destination $tempDir -Recurse

Rename-Item -Path $tempDir -NewName $modName

Write-Host "Packaging a new build: $zipName"

Compress-Archive -DestinationPath $zipName -Path $modName

Write-Host "Mod has been created!"

