# Script para configurar variáveis de ambiente para uso exclusivo em D:\
# Execute este script antes de compilar: .\set_env.ps1

Write-Host "Configurando variáveis de ambiente para D:\..." -ForegroundColor Green

# Variáveis de ambiente permanentes (User level)
[Environment]::SetEnvironmentVariable("JAVA_HOME", "D:\Android Studio\jbr", "User")
[Environment]::SetEnvironmentVariable("GRADLE_USER_HOME", "D:\.gradle", "User")
[Environment]::SetEnvironmentVariable("FLUTTER_ROOT", "D:\Projetos\flutter_windows_3.41.4-stable\flutter", "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", "D:\AndroidSDK", "User")
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "D:\AndroidSDK", "User")

# Variáveis de sessão (para uso imediato nesta janela)
$env:JAVA_HOME = "D:\Android Studio\jbr"
$env:GRADLE_USER_HOME = "D:\.gradle"
$env:FLUTTER_ROOT = "D:\Projetos\flutter_windows_3.41.4-stable\flutter"
$env:ANDROID_SDK_ROOT = "D:\AndroidSDK"
$env:ANDROID_HOME = "D:\AndroidSDK"

Write-Host "✓ JAVA_HOME: $env:JAVA_HOME" -ForegroundColor Cyan
Write-Host "✓ GRADLE_USER_HOME: $env:GRADLE_USER_HOME" -ForegroundColor Cyan
Write-Host "✓ FLUTTER_ROOT: $env:FLUTTER_ROOT" -ForegroundColor Cyan
Write-Host "✓ ANDROID_SDK_ROOT: $env:ANDROID_SDK_ROOT" -ForegroundColor Cyan
Write-Host "✓ ANDROID_HOME: $env:ANDROID_HOME" -ForegroundColor Cyan
Write-Host "" 
Write-Host "Variáveis configuradas com sucesso!" -ForegroundColor Green
