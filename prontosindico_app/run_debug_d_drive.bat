@echo off
REM ========================================
REM Script para limpar cache e configurar D:\ como temp
REM ========================================

echo.
echo ================================================
echo  LIMPANDO CACHE DO FLUTTER E CONFIGURANDO D:\
echo ================================================
echo.

REM Criar diretório D:\temp se não existir
if not exist D:\temp (
    mkdir D:\temp
    echo ✓ Diretório D:\temp criado
)

REM Limpar cache do Flutter
echo.
echo Limpando cache do Flutter...
flutter clean
flutter pub get

REM Configurar variáveis de ambiente para esta sessão
setlocal enabledelayedexpansion
set TEMP=D:\temp
set TMP=D:\temp
set USERPROFILE=D:\temp

echo.
echo ================================================
echo  ✓ VARIÁVEIS CONFIGURADAS:
echo    TEMP: %TEMP%
echo    TMP: %TMP%
echo ================================================
echo.

REM Agora rodar flutter run em debug
echo Iniciando Flutter em DEBUG mode com D:\ como temp...
echo.
flutter run

pause
