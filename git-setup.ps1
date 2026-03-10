# Git Auto-Push Setup Script for TopOptFrame
# Run this script to initialize git and configure auto-push

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  TopOptFrame Git Auto-Push Setup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Get the project directory
$projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectDir

Write-Host "📁 Project Directory: $projectDir" -ForegroundColor Gray
Write-Host ""

# Check if git is installed
try {
    $gitVersion = git --version
    Write-Host "✅ Git detected: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git is not installed or not in PATH" -ForegroundColor Red
    Write-Host "   Please install Git from: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

# Initialize git if not already initialized
if (-not (Test-Path ".git")) {
    Write-Host "🔧 Initializing git repository..." -ForegroundColor Yellow
    git init
    Write-Host "✅ Git repository initialized" -ForegroundColor Green
} else {
    Write-Host "✅ Git repository already initialized" -ForegroundColor Green
}

# Configure user if not set
$userName = git config user.name
$userEmail = git config user.email

if (-not $userName) {
    Write-Host ""
    $defaultName = $env:USERNAME
    $inputName = Read-Host "Enter your Git user name [$defaultName]"
    if (-not $inputName) { $inputName = $defaultName }
    git config user.name "$inputName"
    Write-Host "✅ User name set to: $inputName" -ForegroundColor Green
}

if (-not $userEmail) {
    Write-Host ""
    $inputEmail = Read-Host "Enter your Git email"
    git config user.email "$inputEmail"
    Write-Host "✅ User email set to: $inputEmail" -ForegroundColor Green
}

Write-Host ""
Write-Host "👤 Git User: $(git config user.name) <$(git config user.email)>" -ForegroundColor Gray

# Check for .gitignore
if (-not (Test-Path ".gitignore")) {
    Write-Host "⚠️  .gitignore not found. Creating default..." -ForegroundColor Yellow
    @"
# Build directory
/build/
/build-*/
/out/
/cmake-build-*/

# Visual Studio
*.sln
*.vcxproj
*.vcxproj.filters
*.vcxproj.user
.vs/

# Binaries
*.exe
*.dll
*.lib
*.pdb

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# User-specific
imgui_layout.ini
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8
    Write-Host "✅ Default .gitignore created" -ForegroundColor Green
}

# Set up post-commit hook
$hookDir = ".git\hooks"
$postCommitHook = "$hookDir\post-commit"

Write-Host ""
Write-Host "🔧 Setting up auto-push hook..." -ForegroundColor Yellow

$hookContent = @'#!/bin/sh
# Auto-push hook - triggers after each commit
echo "🚀 Auto-pushing to remote..."
remote_count=$(git remote | wc -l)
if [ "$remote_count" -eq 0 ]; then
    echo "⚠️  No remote configured. Skipping push."
    exit 0
fi
branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "HEAD")
git push origin "$branch"
if [ $? -eq 0 ]; then
    echo "✅ Pushed to origin/$branch"
else
    echo "❌ Push failed"
fi
'@

Set-Content -Path $postCommitHook -Value $hookContent -Encoding UTF8 -NoNewline

# Make hook executable (for Git Bash compatibility)
if (Get-Command chmod -ErrorAction SilentlyContinue) {
    chmod +x $postCommitHook 2>$null
}

Write-Host "✅ Post-commit hook installed" -ForegroundColor Green

# Check remotes
Write-Host ""
$remotes = git remote -v
if ($remotes) {
    Write-Host "📡 Configured remotes:" -ForegroundColor Green
    $remotes | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
} else {
    Write-Host "⚠️  No remote repository configured" -ForegroundColor Yellow
    Write-Host "   To add a remote, run:" -ForegroundColor Yellow
    Write-Host "   git remote add origin <your-repo-url>" -ForegroundColor Cyan
}

# Show current status
Write-Host ""
Write-Host "📊 Current Status:" -ForegroundColor Cyan
$status = git status --short
if ($status) {
    Write-Host "   Uncommitted changes:" -ForegroundColor Yellow
    $status | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
} else {
    Write-Host "   ✅ Working directory clean" -ForegroundColor Green
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📝 Quick Reference:" -ForegroundColor White
Write-Host "   git add <file>     - Stage file for commit" -ForegroundColor Gray
Write-Host "   git commit -m msg  - Commit and auto-push" -ForegroundColor Gray
Write-Host "   git status         - Check status" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Note: build/ directory is excluded from git" -ForegroundColor Gray
Write-Host ""
