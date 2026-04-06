@echo off
REM Script de build seguro para usar apenas D:\

echo Configurando ambiente para D:\
set JAVA_HOME=D:\Android Studio\jbr
set GRADLE_USER_HOME=D:\.gradle
set FLUTTER_ROOT=D:\Projetos\flutter_windows_3.41.4-stable
set ANDROID_SDK_ROOT=D:\AndroidSDK
set ANDROID_HOME=D:\AndroidSDK

echo.
echo JAVA_HOME=%JAVA_HOME%
echo GRADLE_USER_HOME=%GRADLE_USER_HOME%
echo FLUTTER_ROOT=%FLUTTER_ROOT%
echo.

REM Verifica se o PATH do Flutter está configurado
if not "%FLUTTER_ROOT%"=="" (
    set PATH=%FLUTTER_ROOT%\bin;%PATH%
    echo Flutter adicionado ao PATH
)

echo.
echo Iniciando build...
echo.

REM Executa o flutter run
cd /d d:\Projetos\ProntoSindico\prontosindico_app
call flutter run -d SM\ G9600

pause
