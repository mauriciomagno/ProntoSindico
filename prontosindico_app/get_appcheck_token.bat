@echo off
echo ================================================
echo 🔍 CAPTURANDO DEBUG TOKEN DO APP CHECK
echo ================================================
echo.
echo Aguarde... O token aparecerá quando o app inicializar.
echo Pressione Ctrl+C para parar.
echo.
echo ================================================
echo.

adb logcat -s DebugAppCheckProvider:I | findstr "token"
