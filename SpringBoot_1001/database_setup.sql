-- =============================================
-- Script Name: Database Setup for SpringBoot_1001
-- Description: Tạo database và bảng cho ứng dụng Spring Boot với Spring Security và JWT
-- Author: SpringBoot_1001 Team
-- Created: 2025-10-01
-- =============================================

-- 1. Tạo database (nếu chưa tồn tại)
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'SpringBoot1001')
BEGIN
    CREATE DATABASE SpringBoot1001;
    PRINT 'Database SpringBoot1001 created successfully.';
END
ELSE
BEGIN
    PRINT 'Database SpringBoot1001 already exists.';
END
GO

-- 2. Sử dụng database SpringBoot1001
USE SpringBoot1001;
GO

-- 3. Tạo bảng users
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='users' AND xtype='U')
BEGIN
    CREATE TABLE users (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        username NVARCHAR(50) NOT NULL UNIQUE,
        password NVARCHAR(255) NOT NULL,
        email NVARCHAR(100) NOT NULL UNIQUE,
        role NVARCHAR(20) NOT NULL DEFAULT 'USER',
        enabled BIT NOT NULL DEFAULT 1,
        account_non_expired BIT NOT NULL DEFAULT 1,
        account_non_locked BIT NOT NULL DEFAULT 1,
        credentials_non_expired BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME2 NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Table users created successfully.';
END
ELSE
BEGIN
    PRINT 'Table users already exists.';
END
GO

-- 4. Tạo index cho username và email để tăng hiệu suất
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_users_username')
BEGIN
    CREATE INDEX IX_users_username ON users(username);
    PRINT 'Index IX_users_username created successfully.';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_users_email')
BEGIN
    CREATE INDEX IX_users_email ON users(email);
    PRINT 'Index IX_users_email created successfully.';
END
GO

-- 5. Tạo stored procedure để tạo user mới
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateUser')
    DROP PROCEDURE sp_CreateUser;
GO

CREATE PROCEDURE sp_CreateUser
    @username NVARCHAR(50),
    @password NVARCHAR(255),
    @email NVARCHAR(100),
    @role NVARCHAR(20) = 'USER'
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Kiểm tra username đã tồn tại chưa
    IF EXISTS (SELECT 1 FROM users WHERE username = @username)
    BEGIN
        RAISERROR('Username already exists', 16, 1);
        RETURN;
    END
    
    -- Kiểm tra email đã tồn tại chưa
    IF EXISTS (SELECT 1 FROM users WHERE email = @email)
    BEGIN
        RAISERROR('Email already exists', 16, 1);
        RETURN;
    END
    
    -- Tạo user mới
    INSERT INTO users (username, password, email, role, created_at, updated_at)
    VALUES (@username, @password, @email, @role, GETDATE(), GETDATE());
    
    SELECT 'User created successfully' AS Result;
END
GO

-- 6. Tạo stored procedure để tìm user theo username
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_FindUserByUsername')
    DROP PROCEDURE sp_FindUserByUsername;
GO

CREATE PROCEDURE sp_FindUserByUsername
    @username NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        id,
        username,
        password,
        email,
        role,
        enabled,
        account_non_expired,
        account_non_locked,
        credentials_non_expired,
        created_at,
        updated_at
    FROM users 
    WHERE username = @username;
END
GO

-- 7. Tạo stored procedure để tìm user theo email
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_FindUserByEmail')
    DROP PROCEDURE sp_FindUserByEmail;
GO

CREATE PROCEDURE sp_FindUserByEmail
    @email NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        id,
        username,
        password,
        email,
        role,
        enabled,
        account_non_expired,
        account_non_locked,
        credentials_non_expired,
        created_at,
        updated_at
    FROM users 
    WHERE email = @email;
END
GO

-- 8. Tạo trigger để tự động cập nhật updated_at
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'tr_users_updated_at')
    DROP TRIGGER tr_users_updated_at;
GO

CREATE TRIGGER tr_users_updated_at
ON users
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE users 
    SET updated_at = GETDATE()
    FROM users u
    INNER JOIN inserted i ON u.id = i.id;
END
GO

-- 9. Thêm dữ liệu mẫu (optional)
-- Tạo user admin mặc định
IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'admin')
BEGIN
    -- Password: admin123 (đã được hash bằng BCrypt)
    INSERT INTO users (username, password, email, role, enabled, created_at, updated_at)
    VALUES (
        'admin', 
        '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', -- admin123
        'admin@example.com', 
        'ADMIN', 
        1, 
        GETDATE(), 
        GETDATE()
    );
    PRINT 'Admin user created successfully.';
END

-- Tạo user test mặc định
IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'test')
BEGIN
    -- Password: test123 (đã được hash bằng BCrypt)
    INSERT INTO users (username, password, email, role, enabled, created_at, updated_at)
    VALUES (
        'test', 
        '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', -- test123
        'test@example.com', 
        'USER', 
        1, 
        GETDATE(), 
        GETDATE()
    );
    PRINT 'Test user created successfully.';
END
GO

-- 10. Hiển thị thông tin database
SELECT 
    'Database Setup Completed Successfully!' AS Status,
    DB_NAME() AS DatabaseName,
    COUNT(*) AS UserCount
FROM users;

PRINT '=============================================';
PRINT 'Database setup completed successfully!';
PRINT 'Database: SpringBoot1001';
PRINT 'Tables: users';
PRINT 'Stored Procedures: sp_CreateUser, sp_FindUserByUsername, sp_FindUserByEmail';
PRINT 'Triggers: tr_users_updated_at';
PRINT '=============================================';
