# Jenkins Build Validation Script for Custom-Fishing (PowerShell)
# This script validates that the project is ready for Jenkins CI/CD

Write-Host "=== Custom-Fishing Jenkins Build Validation ===" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "build.gradle.kts")) {
    Write-Host "❌ Error: build.gradle.kts not found. Are you in the Custom-Fishing root directory?" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Found build.gradle.kts" -ForegroundColor Green

# Check for Jenkinsfile
if (-not (Test-Path "Jenkinsfile")) {
    Write-Host "❌ Error: Jenkinsfile not found" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Found Jenkinsfile" -ForegroundColor Green

# Check for JENKINS.md
if (-not (Test-Path "JENKINS.md")) {
    Write-Host "⚠️  Warning: JENKINS.md not found (documentation)" -ForegroundColor Yellow
} else {
    Write-Host "✅ Found JENKINS.md" -ForegroundColor Green
}

# Check Gradle wrapper
if (-not (Test-Path "gradlew") -and -not (Test-Path "gradlew.bat")) {
    Write-Host "❌ Error: Gradle wrapper not found" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Found Gradle wrapper" -ForegroundColor Green

# Check if Git is initialized
if (-not (Test-Path ".git")) {
    Write-Host "❌ Error: Git repository not initialized" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Git repository initialized" -ForegroundColor Green

# Test Gradle wrapper
Write-Host "🔧 Testing Gradle wrapper..." -ForegroundColor Blue
try {
    if (Test-Path "gradlew.bat") {
        $null = & ".\gradlew.bat" --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Gradle wrapper is working" -ForegroundColor Green
        } else {
            Write-Host "❌ Error: Gradle wrapper test failed" -ForegroundColor Red
            exit 1
        }
    } elseif (Test-Path "gradlew") {
        $null = & ".\gradlew" --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Gradle wrapper is working" -ForegroundColor Green
        } else {
            Write-Host "❌ Error: Gradle wrapper test failed" -ForegroundColor Red
            exit 1
        }
    }
} catch {
    Write-Host "❌ Error: Cannot execute Gradle wrapper" -ForegroundColor Red
    exit 1
}

# Check for required Java (optional check)
try {
    $javaVersion = & java -version 2>&1 | Select-Object -First 1
    Write-Host "✅ Java found: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Warning: Java not found in PATH (Jenkins will need JDK configured)" -ForegroundColor Yellow
}

# Validate project structure
Write-Host "🔧 Validating project structure..." -ForegroundColor Blue
$expectedModules = @("api", "core", "compatibility")
foreach ($module in $expectedModules) {
    if (Test-Path $module) {
        Write-Host "✅ Module found: $module" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Warning: Expected module not found: $module" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Validation Summary ===" -ForegroundColor Cyan
Write-Host "🎉 Custom-Fishing appears to be Jenkins-ready!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Commit and push the Jenkinsfile and JENKINS.md to your repository"
Write-Host "2. Configure Jenkins with the instructions in JENKINS.md"
Write-Host "3. Create a new Pipeline job pointing to your repository"
Write-Host "4. Set up webhooks for automatic builds"
Write-Host ""
Write-Host "For detailed setup instructions, see JENKINS.md"