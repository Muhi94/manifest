# Local Pipeline Script
# Run this to manually build, tag, and push to your local Harbor instance.

param (
    [string]$RegistryUrl = "localhost:30002",
    [string]$ImageName = "studenten/manifest-app"
)

# 1. Build
Write-Host "Building Docker Image..." -ForegroundColor Green
docker build -f StudentApi/Dockerfile -t manifest-app .
if ($LASTEXITCODE -ne 0) { Write-Error "Build failed"; exit 1 }

# 2. Generate Tag (Timestamp based for uniqueness)
$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
$tag = "v1-$timestamp"
$fullImageName = "$RegistryUrl/$ImageName`:$tag"
$latestImageName = "$RegistryUrl/$ImageName`:latest"

# 3. Tag
Write-Host "Tagging image as $tag..." -ForegroundColor Cyan
docker tag manifest-app $fullImageName
docker tag manifest-app $latestImageName

# 4. Push
Write-Host "Pushing to Harbor ($RegistryUrl)..." -ForegroundColor Yellow
# Note: Ensure you are logged in: docker login localhost:30002
docker push $fullImageName
docker push $latestImageName

Write-Host "Done! Pushed $fullImageName" -ForegroundColor Green
