#!/usr/bin/env ruby

require_relative '../config/database'
require_relative '../models/user'

puts "🎮 Codex MCP - User Creation"
puts "================================"
puts ""

print "Enter username: "
username = gets.chomp

if username.empty?
  puts "❌ Username cannot be empty"
  exit 1
end

begin
  user = User.create!(username: username)
  puts ""
  puts "✅ User created successfully!"
  puts ""
  puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  puts "📋 Your User Details:"
  puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  puts "  User ID: #{user.id}"
  puts "  Username: #{user.username}"
  puts "  Level: #{user.level}"
  puts "  XP: #{user.xp}"
  puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  puts ""
  puts "⚠️  IMPORTANT: Remember your User ID: #{user.id}"
  puts "You'll need it when using Codex with Claude."
  puts ""
rescue ActiveRecord::RecordInvalid => e
  puts "❌ Error: #{e.message}"
  exit 1
end
