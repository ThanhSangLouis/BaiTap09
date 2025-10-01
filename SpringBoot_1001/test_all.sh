#!/bin/bash

echo "🚀 STARTING SPRING BOOT APPLICATION TESTING PROCESS..."
echo "======================================================"

# Bước 1: Khởi động ứng dụng
echo "📱 Step 1: Starting Spring Boot Application..."
./mvnw spring-boot:run &
APP_PID=$!
echo "App started with PID: $APP_PID"

# Đợi app khởi động
echo "⏳ Waiting for application to start..."
sleep 30

# Bước 2: Kiểm tra health
echo "🔍 Step 2: Testing Health Endpoint..."
HEALTH_RESPONSE=$(curl -s http://localhost:8080/api/auth/public/health)
echo "Health Response: $HEALTH_RESPONSE"

if [[ "$HEALTH_RESPONSE" == *"Auth service is running"* ]]; then
    echo "✅ Application is running successfully!"
else
    echo "❌ Application failed to start properly"
    kill $APP_PID 2>/dev/null
    exit 1
fi

# Bước 3: Tạo hash password
echo "🔑 Step 3: Generating Password Hash..."
HASH_RESPONSE=$(curl -s "http://localhost:8080/api/auth/public/generate-password?password=password123")
echo "Password Hash Response: $HASH_RESPONSE"

# Bước 4: Đăng ký user mới
echo "👤 Step 4: Registering New User..."
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser2025",
    "email": "testuser2025@example.com",
    "password": "password123"
  }')
echo "Register Response: $REGISTER_RESPONSE"

# Bước 5: Login với user vừa đăng ký
echo "🔐 Step 5: Testing Login..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "usernameOrEmail": "testuser2025", 
    "password": "password123"
  }')
echo "Login Response: $LOGIN_RESPONSE"

# Kiểm tra kết quả login
if [[ "$LOGIN_RESPONSE" == *"accessToken"* ]]; then
    echo "🎉 SUCCESS! Login worked perfectly!"
    echo "✅ User registration and authentication flow is working!"
else
    echo "❌ Login failed. Response: $LOGIN_RESPONSE"
fi

# Bước 6: Test với user có sẵn trong database
echo "🔄 Step 6: Testing Login with Existing Users..."

# Test với admin
ADMIN_LOGIN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "usernameOrEmail": "admin",
    "password": "admin123"
  }')
echo "Admin Login: $ADMIN_LOGIN"

# Test với test user  
TEST_LOGIN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "usernameOrEmail": "test",
    "password": "test123"
  }')
echo "Test User Login: $TEST_LOGIN"

# Test với newuser123
NEWUSER_LOGIN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "usernameOrEmail": "newuser123", 
    "password": "password123"
  }')
echo "NewUser123 Login: $NEWUSER_LOGIN"

echo "======================================================"
echo "🏁 TESTING COMPLETED!"
echo "The application will continue running for further manual testing..."
echo "To stop the application, run: kill $APP_PID"
echo "======================================================"