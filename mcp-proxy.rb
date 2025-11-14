#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

# MCP stdio-to-HTTP proxy
# Reads JSON-RPC from stdin, forwards to Codex HTTP server, returns response

CODEX_URL = ENV['CODEX_URL'] || 'http://localhost:3001/rpc'

STDERR.puts "🔧 MCP Proxy starting..."
STDERR.puts "📡 Forwarding to: #{CODEX_URL}"

# Process each line from stdin
STDIN.each_line do |line|
  line = line.strip
  next if line.empty?

  begin
    # Parse incoming JSON-RPC request
    request = JSON.parse(line)

    STDERR.puts "📨 Request: #{request['method']}"

    # Forward to HTTP server
    uri = URI(CODEX_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 30

    http_request = Net::HTTP::Post.new(uri.path, {
      'Content-Type' => 'application/json'
    })
    http_request.body = request.to_json

    # Get response
    response = http.request(http_request)

    # Return response to stdout
    puts response.body
    STDOUT.flush

    STDERR.puts "✅ Response: #{response.code}"

  rescue JSON::ParserError => e
    # Invalid JSON from Claude
    STDERR.puts "❌ Parse error: #{e.message}"
    error_response = {
      jsonrpc: '2.0',
      error: {
        code: -32700,
        message: 'Parse error',
        data: e.message
      },
      id: nil
    }
    puts error_response.to_json
    STDOUT.flush

  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
    # Can't connect to Docker container
    STDERR.puts "❌ Connection error: Docker container not running?"
    STDERR.puts "   Run: docker-compose up -d"
    error_response = {
      jsonrpc: '2.0',
      error: {
        code: -32603,
        message: 'Codex server not running',
        data: 'Run "docker-compose up -d" to start the server'
      },
      id: request&.dig('id')
    }
    puts error_response.to_json
    STDOUT.flush

  rescue => e
    # Other errors
    STDERR.puts "❌ Error: #{e.class} - #{e.message}"
    error_response = {
      jsonrpc: '2.0',
      error: {
        code: -32603,
        message: 'Internal error',
        data: e.message
      },
      id: request&.dig('id')
    }
    puts error_response.to_json
    STDOUT.flush
  end
end
