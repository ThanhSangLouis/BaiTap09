# =============================================
#    Database Setup for SpringBoot_1001
# =============================================

Write-Host "=============================================" -ForegroundColor Green
Write-Host "    Database Setup for SpringBoot_1001" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""

# Kiểm tra SQL Server có đang chạy không
Write-Host "Checking SQL Server connection..." -ForegroundColor Yellow
try {
    $result = sqlcmd -S localhost -U sa -P 123456 -Q "SELECT @@VERSION" 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Connection failed"
    }
    Write-Host "SQL Server connection successful!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Cannot connect to SQL Server!" -ForegroundColor Red
    Write-Host "Please make sure SQL Server is running and accessible." -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Check if SQL Server service is running" -ForegroundColor White
    Write-Host "2. Check if port 1433 is open" -ForegroundColor White
    Write-Host "3. Check if username/password is correct" -ForegroundColor White
    Write-Host "4. Check if SQL Server Authentication is enabled" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Chạy script tạo database
Write-Host "Running database setup script..." -ForegroundColor Yellow
try {
    sqlcmd -S localhost -U sa -P 123456 -i database_setup.sql
    if ($LASTEXITCODE -ne 0) {
        throw "Script execution failed"
    }
} catch {
    Write-Host "ERROR: Database setup failed!" -ForegroundColor Red
    Write-Host "Please check the error messages above." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host "    Database setup completed successfully!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Database: SpringBoot1001" -ForegroundColor Cyan
Write-Host "Tables: users" -ForegroundColor Cyan
Write-Host "Stored Procedures: sp_CreateUser, sp_FindUserByUsername, sp_FindUserByEmail" -ForegroundColor Cyan
Write-Host "Triggers: tr_users_updated_at" -ForegroundColor Cyan
Write-Host ""
Write-Host "Sample users created:" -ForegroundColor Yellow
Write-Host "- admin / admin123" -ForegroundColor White
Write-Host "- test / test123" -ForegroundColor White
Write-Host ""
Write-Host "You can now run the Spring Boot application:" -ForegroundColor Green
Write-Host "mvn spring-boot:run" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to exit"
