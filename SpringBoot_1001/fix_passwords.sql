-- =============================================
-- Script Name: Fix Password Hashes
-- Description: Cập nhật password hash đúng cho các user và thêm user test
-- Author: SpringBoot_1001 Team
-- Created: 2025-10-01
-- =============================================

USE SpringBoot1001;
GO

-- Cập nhật password hash đúng cho user 'test' (password: test123)
UPDATE users 
SET password = '$2a$10$eImiTXuWiQKVv7o3G1Lrmu4VNrchDJVGjVz9ToBgbrmxFgeJsMHxu'
WHERE username = 'test';
PRINT 'Updated password for user: test (password: test123)';

-- Cập nhật password hash đúng cho user 'admin' (password: admin123)
UPDATE users 
SET password = '$2a$10$VEjAiGztXXmkcmJ.fG9gTO5k.0L8CSvhgNz3auJi4T2GK9QzUWP9.'
WHERE username = 'admin';
PRINT 'Updated password for user: admin (password: admin123)';

-- Thêm user newuser123 với password: password123
IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'newuser123')
BEGIN
    INSERT INTO users (username, password, email, role, enabled, created_at, updated_at)
    VALUES (
        'newuser123', 
        '$2a$10$YTqw1GX8TLWORdFxyNqEkOgcbcZazpRKWomUIwiJ7MF9/jUYI.hwy', -- password123
        'newuser123@example.com', 
        'USER', 
        1, 
        GETDATE(), 
        GETDATE()
    );
    PRINT 'Created user: newuser123 (password: password123)';
END
ELSE
BEGIN
    -- Nếu user đã tồn tại, cập nhật password
    UPDATE users 
    SET password = '$2a$10$YTqw1GX8TLWORdFxyNqEkOgcbcZazpRKWomUIwiJ7MF9/jUYI.hwy'
    WHERE username = 'newuser123';
    PRINT 'Updated password for existing user: newuser123 (password: password123)';
END

-- Thêm các user test khác với password: password123
DECLARE @users TABLE (username NVARCHAR(50), email NVARCHAR(100));
INSERT INTO @users VALUES 
    ('testuser4', 'testuser4@example.com'),
    ('testuser5', 'testuser5@example.com'),
    ('testuser6', 'testuser6@example.com'),
    ('testuser999', 'testuser999@example.com'),
    ('testuser2025', 'testuser2025@example.com');

DECLARE @username NVARCHAR(50), @email NVARCHAR(100);
DECLARE user_cursor CURSOR FOR SELECT username, email FROM @users;

OPEN user_cursor;
FETCH NEXT FROM user_cursor INTO @username, @email;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF NOT EXISTS (SELECT 1 FROM users WHERE username = @username)
    BEGIN
        INSERT INTO users (username, password, email, role, enabled, created_at, updated_at)
        VALUES (
            @username, 
            '$2a$10$YTqw1GX8TLWORdFxyNqEkOgcbcZazpRKWomUIwiJ7MF9/jUYI.hwy', -- password123
            @email, 
            'USER', 
            1, 
            GETDATE(), 
            GETDATE()
        );
        PRINT 'Created user: ' + @username + ' (password: password123)';
    END
    ELSE
    BEGIN
        UPDATE users 
        SET password = '$2a$10$YTqw1GX8TLWORdFxyNqEkOgcbcZazpRKWomUIwiJ7MF9/jUYI.hwy'
        WHERE username = @username;
        PRINT 'Updated password for existing user: ' + @username + ' (password: password123)';
    END
    
    FETCH NEXT FROM user_cursor INTO @username, @email;
END

CLOSE user_cursor;
DEALLOCATE user_cursor;

-- Hiển thị tất cả users và thông tin của họ
SELECT 
    id,
    username,
    email,
    role,
    enabled,
    created_at
FROM users
ORDER BY id;

PRINT '=============================================';
PRINT 'Password hashes updated successfully!';
PRINT 'All users now have correct BCrypt password hashes';
PRINT 'Test accounts available:';
PRINT '  - admin / admin123';
PRINT '  - test / test123'; 
PRINT '  - newuser123 / password123';
PRINT '  - testuser4 / password123';
PRINT '  - testuser5 / password123';
PRINT '  - testuser6 / password123';
PRINT '  - testuser999 / password123';
PRINT '  - testuser2025 / password123';
PRINT '=============================================';