# 🎮 Codex MCP

> Transform boring development tasks into engaging quests with AI-powered task breakdown and XP progression

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ruby](https://img.shields.io/badge/Ruby-3.2+-red.svg)](https://www.ruby-lang.org/)
[![Docker](https://img.shields.io/badge/Docker-ready-blue.svg)](https://www.docker.com/)

---

## What is Codex?

**Codex** is an MCP server that makes your work feel like a game. Tell Claude what you need to do, and Codex:
- 🤖 Asks clarifying questions to understand the problem
- 🎯 Breaks it down into concrete, actionable steps
- 🎮 Awards XP as you complete objectives
- 🏆 Tracks your progress and levels
- 🎭 Lets you customize the narrator voice (GLaDOS, cyberpunk fixer, or create your own)

**No more staring at vague tasks wondering "where do I even start?"**

---

## Quick Example

**You:** "I need to optimize our database queries. Dashboard is taking 8 seconds."

**Claude (using Codex):**
> "Let me break that down. A few questions:
> - Which specific queries are slow?
> - What's the data volume?
> - Current database structure?"

**You:** "User dashboard endpoint. 50k orders per user. No pagination or indexes."

**Claude:**
> "Got it! Here's your quest:
>
> 🎯 Objectives:
> 1. ☐ Profile queries with EXPLAIN ANALYZE
> 2. ☐ Add database indexes on user_id and created_at
> 3. ☐ Implement pagination (20 per page)
> 4. ☐ Optimize N+1 queries with eager loading
> 5. ☐ Add Redis caching layer
> 6. ☐ Test with 50k+ order users
>
> Start with profiling!"

[You work through objectives, earning +25 XP each]

**You:** "All done! Dashboard now loads in 0.5 seconds."

**Claude:**
> "🎉 Quest Complete!
>
> Performance: 8s → 0.5s (16x faster!)
> XP Earned: +270 (150 from objectives + 120 bonus)
> **Level Up!** You're now Level 3!
>
> Ready for the next challenge?"

---

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Claude Desktop
- 5 minutes

### Installation

```bash
# 1. Clone repository
git clone https://github.com/yourusername/codex-mcp.git
cd codex-mcp

# 2. Start Codex server (runs in background)
./setup.sh

# 3. Configure Claude Desktop or Claude Code
# See "🔌 MCP Configuration" section below for your client
```

For a quick start with Claude Desktop, edit the config file:

**macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows:** `%APPDATA%\Claude\claude_desktop_config.json`
**Linux:** `~/.config/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "codex": {
      "command": "ruby",
      "args": [
        "/ABSOLUTE/PATH/TO/codex-mcp/mcp-proxy.rb"
      ],
      "env": {
        "CODEX_URL": "http://localhost:3001/rpc"
      }
    }
  }
}
```

**Important:** Use absolute paths, not `~` or relative paths.

**For Claude Code users:** See the detailed configuration section below.

```bash
# 5. Restart Claude Desktop completely

# 6. Test it!
```

Open Claude and say:
> "I need to fix a bug where users get timeout errors"

Claude should start asking clarifying questions using Codex! 🎉

---

## 🔌 MCP Configuration

Choose your client and follow the appropriate configuration steps.

### For Claude Desktop

Claude Desktop connects to Codex via the MCP proxy which translates stdio ↔ HTTP.

#### macOS

Edit: `~/Library/Application Support/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "codex": {
      "command": "ruby",
      "args": [
        "/Users/yourname/path/to/codex-mcp/mcp-proxy.rb"
      ],
      "env": {
        "CODEX_URL": "http://localhost:3001/rpc"
      }
    }
  }
}
```

#### Windows

Edit: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "codex": {
      "command": "ruby",
      "args": [
        "C:\\Users\\YourName\\Projects\\codex-mcp\\mcp-proxy.rb"
      ],
      "env": {
        "CODEX_URL": "http://localhost:3001/rpc"
      }
    }
  }
}
```

#### Linux

Edit: `~/.config/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "codex": {
      "command": "ruby",
      "args": [
        "/home/yourname/codex-mcp/mcp-proxy.rb"
      ],
      "env": {
        "CODEX_URL": "http://localhost:3001/rpc"
      }
    }
  }
}
```

**After configuration:** Restart Claude Desktop completely (Quit and reopen).

---

### For Claude Code (CLI)

Claude Code can connect to Codex via the MCP proxy or direct HTTP.

#### Option 1: Via MCP Proxy (Recommended)

Create or edit: `~/.config/claude-code/config.json`

```json
{
  "mcpServers": {
    "codex": {
      "command": "ruby",
      "args": [
        "/ABSOLUTE/PATH/TO/codex-mcp/mcp-proxy.rb"
      ],
      "env": {
        "CODEX_URL": "http://localhost:3001/rpc"
      }
    }
  }
}
```

Replace `/ABSOLUTE/PATH/TO/` with your actual path (use `pwd` in the codex-mcp directory).

#### Option 2: Direct HTTP (Alternative)

If MCP proxy doesn't work, you can configure Claude Code to make direct HTTP calls.

Create: `~/.config/claude-code/codex-tools.json`

```json
{
  "tools": [
    {
      "name": "codex_start_quest",
      "description": "Start a new development quest with context gathering",
      "endpoint": "http://localhost:3001/rpc",
      "method": "POST",
      "body": {
        "jsonrpc": "2.0",
        "method": "start_quest_conversation",
        "params": {
          "title": "{{title}}"
        },
        "id": 1
      }
    }
  ]
}
```

**Note:** Check Claude Code's documentation for the exact configuration format as it may vary by version.

#### Testing Claude Code Connection

```bash
# Start Codex server
docker-compose up -d

# In Claude Code terminal
claude-code
```

Then try:
```
You: I need to optimize database queries
```

Claude Code should recognize Codex tools and start the quest conversation.

---

### ⚠️ Important for All Clients

**Use absolute paths, not relative paths or `~`:**

✅ **Good:**
- `/Users/jane/projects/codex-mcp/mcp-proxy.rb`
- `C:\Users\John\codex-mcp\mcp-proxy.rb`
- `/home/developer/codex-mcp/mcp-proxy.rb`

❌ **Bad:**
- `~/projects/codex-mcp/mcp-proxy.rb`
- `./mcp-proxy.rb`
- `../codex-mcp/mcp-proxy.rb`

**To get the absolute path:**
```bash
cd codex-mcp
pwd
# Copy this path and append /mcp-proxy.rb
```

---

## 🎮 Features

### AI-Powered Task Breakdown
- Conversational context gathering
- Automatic decomposition into 5-10 concrete steps
- Smart ordering of objectives

### Gamification
- **+25 XP** per objective completed
- **+100-150 XP** bonus when quest is done
- Level up system with exponential thresholds
- Real-time progress tracking

### Custom Narrator Voices
Choose how your tasks are presented:

**GLaDOS (Sarcastic AI):**
> "Oh wonderful. Unit tests. Because clearly the only thing better than writing code is writing MORE code to verify it works. Here's your test chamber..."

**Cyberpunk Fixer:**
> "Alright runner, got a contract. Database optimization. Classic N+1 problem. Six objectives identified. Let's crack this ice..."

**Drill Sergeant:**
> "Listen up! That dashboard is slower than my grandmother! I want you to profile, optimize, and cache like your career depends on it! MOVE!"

**Golden Retriever:**
> "OH WOW A NEW TASK THIS IS SO EXCITING!!! We're going to optimize queries and it's going to be THE BEST THING EVER!!!"

**Or create your own:** `"You are Morgan Freeman narrating my coding life"`

### Persistent State
- All progress saved in SQLite
- Survives restarts
- Quest history preserved
- XP and levels maintained

---

## 🎭 Usage

### Starting a Quest

Just talk to Claude naturally:
- "I need to refactor the authentication system"
- "Help me optimize this slow API endpoint"
- "I have to write tests for the payment flow"

Claude will use Codex to guide you through it.

### Tracking Progress

- "Show me my quest progress"
- "What's my current level and XP?"
- "List my active quests"

### Customizing Narrator

- "Set my narrator to be GLaDOS from Portal"
- "Change narrator to a cyberpunk fixer who calls me 'runner'"
- "Make the narrator an enthusiastic golden retriever"

### Completing Work

Just tell Claude when you finish:
- "I finished profiling the queries"
- "Done adding the indexes"
- "All objectives complete!"

Claude will mark them done and award XP automatically.

---

## 🏗️ How It Works

### Architecture

```
┌─────────────────────────────────────┐
│  Docker Container (Always Running)  │
│  • Codex MCP Server (port 3001)    │
│  • SQLite Database                  │
│  • Auto-restart on crash            │
└──────────────┬──────────────────────┘
               │ HTTP
               │ localhost:3001/rpc
┌──────────────┴──────────────────────┐
│  MCP Proxy (mcp-proxy.rb)           │
│  Translates: stdio ↔ HTTP           │
└──────────────┬──────────────────────┘
               │ stdio/stdout
┌──────────────┴──────────────────────┐
│  Claude Desktop                      │
│  Sends requests via MCP protocol    │
└─────────────────────────────────────┘
```

**Key Design:**
- **Docker Container** runs 24/7 as a background service
- **Claude** does ALL the thinking (task breakdown, narration)
- **Codex** provides state management and orchestration
- **MCP Proxy** bridges the two protocols

This "smart state" architecture means:
- ✅ No redundant AI calls (faster, cheaper)
- ✅ Instant connection (no startup delay)
- ✅ Always-available state
- ✅ Simple, maintainable code

### Data Flow

```
1. User: "Fix the auth bug"
   ↓
2. Claude: Calls start_quest_conversation
   ↓
3. Codex: Creates task, returns questions
   ↓
4. Claude: Asks questions to user
   ↓
5. User: Provides context
   ↓
6. Claude: Breaks down into subtasks
   ↓
7. Codex: Stores subtasks, activates quest
   ↓
8. User works, reports progress
   ↓
9. Codex: Awards XP, checks level-up
   ↓
10. Quest complete: Bonus XP, celebration!
```

---

## 🐳 Docker Commands

### Check Status
```bash
docker-compose ps
```

### View Logs
```bash
docker-compose logs -f
```

### Restart Server
```bash
docker-compose restart
```

### Stop Server
```bash
docker-compose down
```

### Rebuild After Code Changes
```bash
docker-compose down
docker-compose build
docker-compose up -d
```

### Access Database
```bash
docker-compose exec codex sqlite3 /data/state.sqlite3
# Inside SQLite:
.tables
SELECT * FROM users;
.quit
```

### Backup Database
```bash
docker cp codex-mcp:/data/state.sqlite3 ./backup.sqlite3
```

---

## 🧪 Testing

```bash
# Test Docker setup
./test_docker.sh

# Test from command line
curl http://localhost:3001/health
curl -X POST http://localhost:3001/rpc \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools.list","id":1}'
```

---

## 🎯 XP & Leveling

### XP Awards
- Objective completed: **+25 XP**
- Quest completed: **+100 XP base**
- Complexity bonus: **+10 XP per subtask over 5**

Example: 6-objective quest = 150 XP (subtasks) + 110 XP (bonus) = **260 XP total**

### Level Thresholds
- Level 2: 100 XP
- Level 3: 250 XP
- Level 4: 450 XP
- Level 5: 700 XP
- Level 6: 1000 XP

Formula: `(level-1) × 100 + (level-1) × (level-2) × 25`

---

## 📖 Available Tools

Codex provides 8 MCP tools that Claude can use:

| Tool | Purpose |
|------|---------|
| `start_quest_conversation` | Begin new quest, get clarifying questions |
| `finalize_quest` | Store objectives after context gathering |
| `mark_objective_complete` | Complete subtask, award XP |
| `complete_quest` | Finish quest, award bonus XP |
| `set_narrator_voice` | Customize narrator personality |
| `check_progress` | Get user stats (level, XP, quests) |
| `list_active_quests` | Show in-progress quests |
| `get_quest_details` | View specific quest with objectives |

All tools include contextual instructions to guide Claude on what to do next.

---

## 🎬 Demo Walkthrough

### Setting the Scene

**You:** "Before we start, set my narrator to a cyberpunk fixer. Call me 'runner'."

**Claude:** [Updates narrator]
> "Narrator voice locked in, runner."

### The Problem

**You:** "I've got a performance problem. Our user dashboard is loading super slow - like 8 seconds."

**Claude:** [Starts quest conversation]
> "Alright runner, got a contract for dashboard optimization. Before I scan the ice, I need intel:
> - What specific operations are slow?
> - What's the data volume?
> - Current query architecture?"

### Context Gathering

**You:** "User dashboard endpoint. 50k orders per user, no pagination. N+1 queries on order items."

**Claude:** [Finalizes quest with 6 objectives]
> "Contract parameters locked, runner. Classic N+1 with massive dataset. Six objectives identified:
>
> 1. ☐ Profile query performance
> 2. ☐ Add database indexes
> 3. ☐ Implement pagination
> 4. ☐ Optimize N+1 queries
> 5. ☐ Add caching layer
> 6. ☐ Test with 50k+ users
>
> First node: profiling. Get me those results, runner."

### The Work

**You:** "Profiled the queries. Found the issue - no indexes. First objective done."

**Claude:** [Marks complete, awards XP]
> "Nice work, runner. First node secured. +25 XP. Progress: 1/6."

[Continue through objectives...]

### Completion

**You:** "All done! Dashboard loads in 0.5 seconds now."

**Claude:** [Completes quest]
> "CONTRACT FULFILLED, runner!
>
> Dashboard performance: OPTIMIZED
> Load time: 8s → 0.5s
> Redis cache: DEPLOYED
>
> Payment: +120 XP bonus
> **You just hit Level 3!**
>
> Total: 270 XP
>
> Solid work. Ready for the next contract?"

---

## 🛠️ Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose logs

# Common issues:
# - Port 3001 already in use: Change port in docker-compose.yml
# - Docker not running: Start Docker Desktop
```

### Claude can't connect to Codex
```bash
# 1. Check container is running
docker-compose ps

# 2. Test health endpoint
curl http://localhost:3001/health

# 3. Verify MCP proxy path in Claude config
# Must be absolute path, not relative

# 4. Check proxy is executable
ls -la mcp-proxy.rb
# Should show: -rwxr-xr-x

# 5. Restart Claude Desktop completely
```

### MCP proxy errors
```bash
# View proxy logs (stderr goes to Claude's logs)
# Check: ~/Library/Logs/Claude/ (macOS)

# Test proxy manually
echo '{"jsonrpc":"2.0","method":"tools.list","id":1}' | ruby mcp-proxy.rb
```

### Database issues
```bash
# Reset database (WARNING: deletes all data)
docker-compose down -v
docker-compose up -d
```

---

## 📊 Tech Stack

- **Backend:** Ruby 3.2 + Sinatra
- **Database:** SQLite 3
- **ORM:** ActiveRecord
- **Protocol:** JSON-RPC via MCP
- **Deployment:** Docker + Docker Compose
- **Integration:** Model Context Protocol (MCP)

---

## 🗂️ Project Structure

```
codex-mcp/
├── server.rb              # Main Sinatra application
├── Dockerfile             # Container definition
├── docker-compose.yml     # Service orchestration
├── mcp-proxy.rb          # MCP stdio ↔ HTTP bridge
├── setup.sh              # One-command installation
├── test_docker.sh        # Verify setup
├── config/
│   └── database.rb       # ActiveRecord setup
├── models/
│   ├── user.rb          # User model (username, xp, level)
│   ├── task.rb          # Task model (quests)
│   └── subtask.rb       # Subtask model (objectives)
└── lib/
    ├── xp_calculator.rb           # XP/leveling logic
    ├── response_helper.rb         # Contextual instructions
    ├── validators.rb              # Input validation
    └── tools/
        ├── quest_tools.rb         # Quest management
        ├── progress_tools.rb      # Progress tracking
        └── user_tools.rb          # User management
```

---

## 🤝 Contributing

Contributions welcome! To contribute:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

---

## 📄 License

MIT License - see LICENSE file for details

---

## 🙏 Acknowledgments

- Built with [Model Context Protocol (MCP)](https://modelcontextprotocol.io) by Anthropic
- Inspired by gamification in Habitica, Duolingo, and GitHub
- Uses Claude AI for intelligent task management

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/yourusername/codex-mcp/issues)
- **Discussions:** [GitHub Discussions](https://github.com/yourusername/codex-mcp/discussions)

---

**Made with ❤️ and ☕**

*"Turn your todos into quests. Your work into adventures. Your coffee breaks into well-deserved XP bonuses."*
