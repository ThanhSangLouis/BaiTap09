@echo off
echo =============================================
echo    Database Setup for SpringBoot_1001
echo =============================================
echo.

REM Kiểm tra SQL Server có đang chạy không
echo Checking SQL Server connection...
sqlcmd -S localhost -U sa -P 1 -Q "SELECT @@VERSION" >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Cannot connect to SQL Server!
    echo Please make sure SQL Server is running and accessible.
    echo.
    echo Troubleshooting:
    echo 1. Check if SQL Server service is running
    echo 2. Check if port 1433 is open
    echo 3. Check if username/password is correct
    echo 4. Check if SQL Server Authentication is enabled
    echo.
    pause
    exit /b 1
)

echo SQL Server connection successful!
echo.

REM Chạy script tạo database
echo Running database setup script...
sqlcmd -S localhost -U sa -P 1 -i database_setup.sql

if %errorlevel% neq 0 (
    echo ERROR: Database setup failed!
    echo Please check the error messages above.
    pause
    exit /b 1
)

echo.
echo =============================================
echo    Database setup completed successfully!
echo =============================================
echo.
echo Database: SpringBoot1001
echo Tables: users
echo Stored Procedures: sp_CreateUser, sp_FindUserByUsername, sp_FindUserByEmail
echo Triggers: tr_users_updated_at
echo.
echo Sample users created:
echo - admin / admin123
echo - test / test123
echo.
echo You can now run the Spring Boot application:
echo mvn spring-boot:run
echo.
pause
