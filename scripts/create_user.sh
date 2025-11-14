#!/bin/bash

echo "🎮 Codex MCP - Create User"
echo "=========================="
echo ""

# Check if container is running
if ! docker ps | grep -q codex-mcp; then
    echo "❌ Codex container not running"
    echo "   Start it with: docker-compose up -d"
    exit 1
fi

# Detect docker compose command
if docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

# Run user creation inside container
$DOCKER_COMPOSE exec codex ruby -e "
require_relative 'config/database'
require_relative 'models/user'

print 'Enter username: '
username = gets.chomp

if username.empty?
  puts '❌ Username cannot be empty'
  exit 1
end

begin
  user = User.create!(username: username)
  puts ''
  puts '✅ User created successfully!'
  puts ''
  puts '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
  puts '📋 Your User Details:'
  puts '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
  puts \"  User ID: #{user.id}\"
  puts \"  Username: #{user.username}\"
  puts \"  Level: #{user.level}\"
  puts \"  XP: #{user.xp}\"
  puts '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
  puts ''
  puts \"⚠️  IMPORTANT: Save your User ID: #{user.id}\"
  puts 'You will need it when configuring Claude Desktop.'
  puts ''
rescue ActiveRecord::RecordInvalid => e
  puts \"❌ Error: #{e.message}\"
  exit 1
end
"
