# PowerShell build script for AIGVDet Docker images

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "AIGVDet Docker Build Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

function Build-Image {
    param(
        [string]$Dockerfile,
        [string]$Tag
    )
    
    Write-Host "Building $Tag image..." -ForegroundColor Yellow
    docker build -f $Dockerfile -t aigvdet:$Tag .
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Successfully built aigvdet:$Tag" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to build aigvdet:$Tag" -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

# Parse arguments
$BuildType = if ($args.Count -gt 0) { $args[0] } else { "all" }

switch ($BuildType) {
    "gpu" {
        Write-Host "Building GPU image only..." -ForegroundColor Yellow
        Build-Image -Dockerfile "Dockerfile.gpu" -Tag "gpu"
    }
    "cpu" {
        Write-Host "Building CPU image only..." -ForegroundColor Yellow
        Build-Image -Dockerfile "Dockerfile.cpu" -Tag "cpu"
    }
    "all" {
        Write-Host "Building both CPU and GPU images..." -ForegroundColor Yellow
        Build-Image -Dockerfile "Dockerfile.cpu" -Tag "cpu"
        Build-Image -Dockerfile "Dockerfile.gpu" -Tag "gpu"
    }
    default {
        Write-Host "Usage: .\build-docker.ps1 {gpu|cpu|all}" -ForegroundColor Red
        Write-Host "  gpu  - Build GPU image only"
        Write-Host "  cpu  - Build CPU image only"
        Write-Host "  all  - Build both images (default)"
        exit 1
    }
}

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Build completed!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Available images:" -ForegroundColor Yellow
docker images | Select-String aigvdet
Write-Host ""
Write-Host "To run:" -ForegroundColor Yellow
Write-Host "  GPU: docker run --gpus all -it --rm aigvdet:gpu"
Write-Host "  CPU: docker run -it --rm aigvdet:cpu"
Write-Host ""
Write-Host "Or use docker-compose:" -ForegroundColor Yellow
Write-Host "  docker-compose up aigvdet-gpu"
Write-Host "  docker-compose up aigvdet-cpu"
