@echo off
title SMK Alhidayahh - Chatbot Server
echo ===================================================
echo   Menjalankan Layanan Chatbot SMK Alhidayahh
echo   Node.js Server Port 3001
echo ===================================================
cd /d "%~dp0node-chatbot"
if not exist node_modules (
    echo [INFO] Menginstal dependensi node_modules...
    call npm install
)
echo [INFO] Server Chatbot aktif di http://localhost:3001
echo [INFO] Jangan tutup jendela ini selama menggunakan fitur asisten virtual AI.
echo.
call npm start
pause
