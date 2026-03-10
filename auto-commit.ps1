# Auto-commit script for TopOptFrame
# Usage: .\auto-commit.ps1 "Your commit message"
# Or just run without arguments to use a default message

param(
    [string]$Message = "Update code"
)

$projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectDir

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  TopOptFrame Auto-Commit" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check git status
$status = git status --porcelain
if (-not $status) {
    Write-Host "✅ No changes to commit" -ForegroundColor Green
    exit 0
}

Write-Host "📁 Changes detected:" -ForegroundColor Yellow
$status | ForEach-Object { 
    $file = $_.Substring(3)
    Write-Host "   $_" -ForegroundColor Gray
}

Write-Host ""
Write-Host "📝 Commit message: $Message" -ForegroundColor White

# Stage all changes (except build/ due to .gitignore)
Write-Host ""
Write-Host "➕ Staging changes..." -ForegroundColor Yellow
git add -A

# Commit
Write-Host ""
Write-Host "💾 Committing..." -ForegroundColor Yellow
git commit -m "$Message"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Commit successful!" -ForegroundColor Green
    
    # Push is handled by post-commit hook, but let's verify
    $remotes = git remote
    if ($remotes) {
        Write-Host "📤 Auto-push triggered by post-commit hook..." -ForegroundColor Yellow
    } else {
        Write-Host "⚠️  No remote configured. Commit is local only." -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "❌ Commit failed" -ForegroundColor Red
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
