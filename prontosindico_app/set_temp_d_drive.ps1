# Script para configurar diretório temporário em D:\ em vez de C:\
# Isso resolve o erro: "Espaço insuficiente no disco"

# Criar diretório temporário em D:\ se não existir
$tempDir = "D:\temp"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    Write-Host "✅ Diretório criado: $tempDir" -ForegroundColor Green
}

# Configurar variáveis de ambiente para a sessão atual
$env:TEMP = $tempDir
$env:TMP = $tempDir

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "✅ VARIÁVEIS DE AMBIENTE CONFIGURADAS" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "TEMP: $env:TEMP" -ForegroundColor Yellow
Write-Host "TMP:  $env:TMP" -ForegroundColor Yellow
Write-Host ""
Write-Host "Agora você pode executar:" -ForegroundColor Cyan
Write-Host "  flutter run --release" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  IMPORTANTE: Se fechar o terminal, execute este script novamente!" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
