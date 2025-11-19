# Docker Push Script for AIGVDet
# Pushes images to Docker Hub: sacdalance/thesis-aigvdet

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("gpu", "cpu", "all")]
    [string]$Version = "all",
    
    [Parameter(Mandatory=$false)]
    [string]$Tag = "latest"
)

$ErrorActionPreference = "Stop"
$Repository = "sacdalance/thesis-aigvdet"

Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Docker Push Script - AIGVDet                          ║" -ForegroundColor Cyan
Write-Host "║     Repository: $Repository                               ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

function Build-And-Push-Image {
    param(
        [string]$Dockerfile,
        [string]$ImageTag,
        [string]$VersionTag
    )
    
    $LocalTag = "aigvdet:$ImageTag"
    $RemoteTag = "${Repository}:${VersionTag}"
    $RemoteLatestTag = "${Repository}:${ImageTag}"
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "🔨 Building $ImageTag image..." -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    docker build -f $Dockerfile -t $LocalTag -t $RemoteTag -t $RemoteLatestTag .
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to build $ImageTag image" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Successfully built $ImageTag image" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "📤 Pushing to Docker Hub..." -ForegroundColor Yellow
    
    # Push with version tag
    Write-Host "  → Pushing ${RemoteTag}..." -ForegroundColor Cyan
    docker push $RemoteTag
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to push ${RemoteTag}" -ForegroundColor Red
        exit 1
    }
    
    # Push with latest tag
    Write-Host "  → Pushing ${RemoteLatestTag}..." -ForegroundColor Cyan
    docker push $RemoteLatestTag
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to push ${RemoteLatestTag}" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Successfully pushed $ImageTag image to Docker Hub" -ForegroundColor Green
    Write-Host ""
}

# Check if logged in to Docker Hub
Write-Host "🔐 Checking Docker Hub authentication..." -ForegroundColor Yellow
docker info | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker is not running or not accessible" -ForegroundColor Red
    exit 1
}

# Try to verify login (will fail if not logged in)
$loginCheck = docker info 2>&1 | Select-String "Username"
if (-not $loginCheck) {
    Write-Host "⚠️  You may not be logged in to Docker Hub" -ForegroundColor Yellow
    Write-Host "Please run: docker login" -ForegroundColor Yellow
    $continue = Read-Host "`nContinue anyway? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 0
    }
}
Write-Host "✅ Docker is ready`n" -ForegroundColor Green

# Build and push based on version
switch ($Version) {
    "gpu" {
        Write-Host "Building and pushing GPU version only...`n" -ForegroundColor Yellow
        Build-And-Push-Image -Dockerfile "Dockerfile.gpu" -ImageTag "gpu" -VersionTag "$Tag-gpu"
    }
    "cpu" {
        Write-Host "Building and pushing CPU version only...`n" -ForegroundColor Yellow
        Build-And-Push-Image -Dockerfile "Dockerfile.cpu" -ImageTag "cpu" -VersionTag "$Tag-cpu"
    }
    "all" {
        Write-Host "Building and pushing both CPU and GPU versions...`n" -ForegroundColor Yellow
        Build-And-Push-Image -Dockerfile "Dockerfile.cpu" -ImageTag "cpu" -VersionTag "$Tag-cpu"
        Build-And-Push-Image -Dockerfile "Dockerfile.gpu" -ImageTag "gpu" -VersionTag "$Tag-gpu"
    }
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "🎉 All images pushed successfully!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
Write-Host "📦 Available images on Docker Hub:" -ForegroundColor Yellow

if ($Version -eq "cpu" -or $Version -eq "all") {
    Write-Host "  • $Repository" -NoNewline -ForegroundColor Cyan
    Write-Host ":cpu" -ForegroundColor Cyan
    Write-Host "  • $Repository" -NoNewline -ForegroundColor Cyan
    Write-Host ":$Tag-cpu" -ForegroundColor Cyan
}

if ($Version -eq "gpu" -or $Version -eq "all") {
    Write-Host "  • $Repository" -NoNewline -ForegroundColor Cyan
    Write-Host ":gpu" -ForegroundColor Cyan
    Write-Host "  • $Repository" -NoNewline -ForegroundColor Cyan
    Write-Host ":$Tag-gpu" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "🚀 Pull commands:" -ForegroundColor Yellow

if ($Version -eq "cpu" -or $Version -eq "all") {
    Write-Host "  CPU: docker pull $Repository" -NoNewline -ForegroundColor White
    Write-Host ":cpu" -ForegroundColor White
}

if ($Version -eq "gpu" -or $Version -eq "all") {
    Write-Host "  GPU: docker pull $Repository" -NoNewline -ForegroundColor White
    Write-Host ":gpu" -ForegroundColor White
}

Write-Host ""
Write-Host "💡 View on Docker Hub:" -ForegroundColor Yellow
$DockerHubUrl = "https://hub.docker.com/r/$Repository"
Write-Host "  $DockerHubUrl" -ForegroundColor Cyan
Write-Host ""
