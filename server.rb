#!/usr/bin/env ruby
require 'sinatra/base'
require 'sinatra/json'
require 'oj'
require_relative 'config/database'

# Load models
require_relative 'models/user'
require_relative 'models/task'
require_relative 'models/subtask'

puts "📦 Models loaded: User, Task, Subtask"

# Load tool handlers
require_relative 'lib/xp_calculator'
require_relative 'lib/tools/quest_tools'
require_relative 'lib/tools/progress_tools'
require_relative 'lib/tools/user_tools'

# Load helpers and validators
require_relative 'lib/response_helper'
require_relative 'lib/validators'
require_relative 'lib/tools/edge_case_handlers'

puts "🔧 Tool handlers loaded"
puts "✨ Helpers and validators loaded"

# Configuration
PORT = ENV['CODEX_PORT'] || 3001

class CodexServer < Sinatra::Base
  set :port, PORT
  set :bind, ENV['CODEX_BIND'] || '0.0.0.0'

  # Always return JSON
  before do
    content_type :json
  end

  # Health check endpoint
  get '/health' do
    json({
      status: 'ok',
      database: File.exist?(DB_PATH) ? 'connected' : 'missing',
      timestamp: Time.now.iso8601
    })
  end

  # Main JSON-RPC endpoint
  post '/rpc' do
    request.body.rewind
    body = request.body.read

    # Parse JSON
    begin
      rpc_request = Oj.load(body, symbol_keys: true)
    rescue Oj::ParseError => e
      return json({
        jsonrpc: '2.0',
        error: {
          code: -32700,
          message: 'Parse error',
          data: e.message
        },
        id: nil
      })
    end

    # Validate request
    unless rpc_request[:method]
      return json({
        jsonrpc: '2.0',
        error: {
          code: -32600,
          message: 'Invalid Request'
        },
        id: rpc_request[:id]
      })
    end

    # Route to handler
    method = rpc_request[:method]
    params = rpc_request[:params] || {}

    puts "🔧 Method: #{method}"

    # Route to handler with error handling
    begin
      result = case method
               when 'initialize'
                 # MCP protocol initialization
                 {
                   protocolVersion: '2024-11-05',
                   capabilities: {
                     tools: {}
                   },
                   serverInfo: {
                     name: 'codex',
                     version: '1.0.0'
                   }
                 }
               when 'tools/list', 'tools.list'
                 handle_tools_list
               when 'tools/call'
                 # MCP tool call format
                 tool_name = params[:name] || params['name']
                 tool_params = params[:arguments] || params['arguments'] || {}
                 tool_result = handle_tool_call(tool_name, tool_params)
                 # Wrap result in MCP content format
                 {
                   content: [
                     {
                       type: 'text',
                       text: Oj.dump(tool_result, mode: :compat)
                     }
                   ]
                 }
               when 'start_quest_conversation'
                 QuestTools.start_quest_conversation(params)
               when 'finalize_quest'
                 QuestTools.finalize_quest(params)
               when 'complete_quest'
                 QuestTools.complete_quest(params)
               when 'mark_objective_complete'
                 ProgressTools.mark_objective_complete(params)
               when 'get_quest_details'
                 ProgressTools.get_quest_details(params)
               when 'list_active_quests'
                 ProgressTools.list_active_quests(params)
               when 'set_narrator_voice'
                 UserTools.set_narrator_voice(params)
               when 'check_progress'
                 UserTools.check_progress(params)
               else
                 return json({
                   jsonrpc: '2.0',
                   error: {
                     code: -32601,
                     message: 'Method not found',
                     data: "Unknown method: #{method}"
                   },
                   id: rpc_request[:id]
                 })
               end

      # Check if result has error
      if result.is_a?(Hash) && result[:error]
        return json({
          jsonrpc: '2.0',
          error: {
            code: -32603,
            message: result[:error]
          },
          id: rpc_request[:id]
        })
      end
    rescue ActiveRecord::RecordNotFound => e
      return json({
        jsonrpc: '2.0',
        error: {
          code: -32603,
          message: 'Record not found',
          data: e.message
        },
        id: rpc_request[:id]
      })
    rescue ActiveRecord::RecordInvalid => e
      return json({
        jsonrpc: '2.0',
        error: {
          code: -32603,
          message: 'Validation error',
          data: e.message
        },
        id: rpc_request[:id]
      })
    rescue StandardError => e
      return json({
        jsonrpc: '2.0',
        error: {
          code: -32603,
          message: 'Internal error',
          data: e.message
        },
        id: rpc_request[:id]
      })
    end

    # Return success
    json({
      jsonrpc: '2.0',
      result: result,
      id: rpc_request[:id]
    })
  end

  private

  def handle_tool_call(tool_name, tool_params)
    # Route to appropriate tool handler
    case tool_name
    when 'start_quest_conversation'
      QuestTools.start_quest_conversation(tool_params)
    when 'finalize_quest'
      QuestTools.finalize_quest(tool_params)
    when 'complete_quest'
      QuestTools.complete_quest(tool_params)
    when 'mark_objective_complete'
      ProgressTools.mark_objective_complete(tool_params)
    when 'get_quest_details'
      ProgressTools.get_quest_details(tool_params)
    when 'list_active_quests'
      ProgressTools.list_active_quests(tool_params)
    when 'set_narrator_voice'
      UserTools.set_narrator_voice(tool_params)
    when 'check_progress'
      UserTools.check_progress(tool_params)
    else
      raise StandardError, "Unknown tool: #{tool_name}"
    end
  end

  def handle_tools_list
    {
      tools: [
        {
          name: 'start_quest_conversation',
          description: 'Begin planning a new development quest. Returns clarifying questions you MUST ask the user before calling finalize_quest. Use when user wants to start working on something.',
          inputSchema: {
            type: 'object',
            properties: {
              title: {
                type: 'string',
                description: 'Brief task description (e.g., "fix login bug", "optimize queries")'
              }
            },
            required: ['title']
          }
        },
        {
          name: 'finalize_quest',
          description: 'Store the quest breakdown after gathering context. You MUST provide 5-10 concrete technical objectives. Call this after asking clarifying questions from start_quest_conversation.',
          inputSchema: {
            type: 'object',
            properties: {
              task_id: {
                type: 'integer',
                description: 'ID from start_quest_conversation'
              },
              context: {
                type: 'string',
                description: 'Summary of the gathered context from user'
              },
              objectives: {
                type: 'array',
                items: {
                  type: 'string'
                },
                minItems: 5,
                maxItems: 10,
                description: '5-10 concrete, actionable technical subtasks'
              }
            },
            required: ['task_id', 'context', 'objectives']
          }
        },
        {
          name: 'mark_objective_complete',
          description: 'Mark a specific objective as completed. Awards XP automatically. Use when user reports finishing a subtask.',
          inputSchema: {
            type: 'object',
            properties: {
              task_id: {
                type: 'integer',
                description: 'ID of the parent quest'
              },
              objective_title: {
                type: 'string',
                description: 'Exact or partial match of the objective to mark complete'
              }
            },
            required: ['task_id', 'objective_title']
          }
        },
        {
          name: 'complete_quest',
          description: 'Mark entire quest as complete. Awards bonus XP and checks for level-up. Use when all objectives are done.',
          inputSchema: {
            type: 'object',
            properties: {
              task_id: {
                type: 'integer',
                description: 'ID of the quest to complete'
              }
            },
            required: ['task_id']
          }
        },
        {
          name: 'set_narrator_voice',
          description: 'Set or update the user\'s preferred narrator personality. This affects how you present quests and progress to the user.',
          inputSchema: {
            type: 'object',
            properties: {
              narrator_prompt: {
                type: 'string',
                description: 'Description of narrator persona (e.g., "You are GLaDOS. Be sarcastic.", "You are a cyberpunk fixer. Call me runner.")'
              }
            },
            required: ['narrator_prompt']
          }
        },
        {
          name: 'check_progress',
          description: 'Get current user stats including XP, level, active quests, and completion history.',
          inputSchema: {
            type: 'object',
            properties: {},
            required: []
          }
        },
        {
          name: 'list_active_quests',
          description: 'Show all in-progress quests with their objectives and progress.',
          inputSchema: {
            type: 'object',
            properties: {},
            required: []
          }
        },
        {
          name: 'get_quest_details',
          description: 'Get detailed information about a specific quest including all objectives and their status.',
          inputSchema: {
            type: 'object',
            properties: {
              task_id: {
                type: 'integer',
                description: 'ID of the quest'
              }
            },
            required: ['task_id']
          }
        }
      ]
    }
  end

  # Start server
  run! if app_file == $0
end
