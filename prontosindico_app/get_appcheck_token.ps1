# Script para capturar o App Check Debug Token
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "🔍 CAPTURANDO DEBUG TOKEN DO APP CHECK" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Aguarde... O token aparecerá quando o app inicializar." -ForegroundColor Green
Write-Host "Pressione Ctrl+C para parar." -ForegroundColor Yellow
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Executa adb logcat e filtra as linhas com o token
adb logcat -s DebugAppCheckProvider:I | Select-String "token"
