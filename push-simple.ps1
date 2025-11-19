# Simple Docker Push - Complete Workflow
# Run this after images are built

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Docker Push to sacdalance/thesis-aigvdet" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

$repo = "sacdalance/thesis-aigvdet"

# Push CPU image
Write-Host "📤 Pushing CPU image..." -ForegroundColor Yellow
docker push "${repo}:cpu"
docker push "${repo}:latest-cpu"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ CPU image pushed successfully!`n" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to push CPU image`n" -ForegroundColor Red
}

# Build and push GPU image
Write-Host "🔨 Building GPU image..." -ForegroundColor Yellow
docker build -f Dockerfile.gpu -t "${repo}:gpu" -t "${repo}:latest-gpu" .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ GPU image built successfully!`n" -ForegroundColor Green
    
    Write-Host "📤 Pushing GPU image..." -ForegroundColor Yellow
    docker push "${repo}:gpu"
    docker push "${repo}:latest-gpu"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ GPU image pushed successfully!`n" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to push GPU image`n" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Failed to build GPU image`n" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "✨ Push Complete!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "📦 Your images are now available at:" -ForegroundColor Yellow
Write-Host "   • docker pull ${repo}:cpu" -ForegroundColor Cyan
Write-Host "   • docker pull ${repo}:gpu" -ForegroundColor Cyan
Write-Host "`n🌐 View on Docker Hub:" -ForegroundColor Yellow
Write-Host "   https://hub.docker.com/r/${repo}`n" -ForegroundColor Cyan
