# 🎮 Codex MCP

> Turn your dev tasks into quests with AI-powered breakdowns and XP progression

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ruby](https://img.shields.io/badge/Ruby-3.2+-red.svg)](https://www.ruby-lang.org/)
[![Docker](https://img.shields.io/badge/Docker-ready-blue.svg)](https://www.docker.com/)

---

## Description

**What is this?**

Codex is an MCP server that gamifies your development work. Tell AI Agent what you need to do, and Codex breaks it into concrete steps, tracks your progress, and awards XP as you complete objectives.

**How it works:**

```
You → AI Agent → Codex (state management) → AI Agent → You
         ↓         ↓                          ↓
      Thinking  Stores tasks,              Presents
                tracks XP                   results
```

AI Agent does all the thinking. Codex handles state persistence and orchestration. Simple, fast, and maintainable.

**Key feature:** The narrator can be ANY character your AI knows - GLaDOS, Gandalf, Rick Sanchez, or create your own!

---

## How to Use

### Basic Usage

**You:** "I need to optimize database queries. Dashboard is taking 8 seconds."

**AI Agent (via Codex):**
> "Let me break that down. A few questions:
> - Which specific queries are slow?
> - What's the data volume?
> - Current database structure?"

**You:** "User dashboard endpoint. 50k orders per user. No pagination or indexes."

**AI Agent:**
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

**AI Agent:**
> "🎉 Quest Complete!
>
> Performance: 8s → 0.5s (16x faster!)
> XP Earned: +270 (150 from objectives + 120 bonus)
> **Level Up!** You're now Level 3!
>
> Ready for the next challenge?"

### GLaDOS Narrator Example

**Setting the narrator:**

**You:** "Set my narrator to GLaDOS from Portal. Be sarcastic."

**AI Agent:** [Updates narrator voice]

**You:** "I need to write unit tests for the payment system."

**GLaDOS:**
> "Oh wonderful. Unit tests. Because clearly the only thing better than writing code is writing MORE code to verify it works. Here's your test chamber:
>
> 1. ☐ Test happy path payment processing
> 2. ☐ Test failed payments
> 3. ☐ Test refunds
> 4. ☐ Test edge cases (zero amounts, negatives)
> 5. ☐ Test concurrent payments
>
> Try not to break anything. That would be a shame."

[After completing first objective]

**GLaDOS:**
> "Well. You managed to complete one test without destroying everything. +25 XP. How... adequate. Four more to go."

[After quest completion]

**GLaDOS:**
> "Congratulations. Against all odds, you've written a complete test suite. The payment system is now 'properly tested.' +175 XP total. You've leveled up to Level 4. I'm as surprised as you are."

### Available Commands

Just talk naturally to AI Agent:

**Starting quests:**
- "I need to refactor the authentication system"
- "Help me optimize this slow API endpoint"
- "I have to add a new feature for user profiles"

**Tracking progress:**
- "Show me my quest progress"
- "What's my current level and XP?"
- "List my active quests"

**Customizing narrator:**
- "Set my narrator to Gandalf from Lord of the Rings"
- "Change narrator to a drill sergeant"
- "Make the narrator an enthusiastic golden retriever"
- "Set narrator to Rick Sanchez - be cynical and burp occasionally"

**Completing work:**
- "I finished profiling the queries"
- "Done adding the indexes"
- "All objectives complete!"

**Remember:** The narrator can be ANY character - historical figures, fictional characters, archetypes, or completely original personas. Get creative!

---

## Installation

### Prerequisites
- Docker & Docker Compose
- Claude Desktop or Claude Code or any other AI Agent that have MCP support
- 5 minutes

### Setup

```bash
# 1. Clone repository
git clone https://github.com/yourusername/codex-mcp.git
cd codex-mcp

# 2. Start Codex server (runs in background)
./setup.sh

# 3. Configure your AI Agent client (see below)

# 4. Restart AI Agent client and start questing!
```

### For Claude Desktop
https://docs.anthropic.com/en/docs/build-with-claude/mcp

Edit your Claude Desktop config file:

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

**Important:** Use absolute paths. Get yours with:
```bash
cd codex-mcp && pwd
# Copy the output and append /mcp-proxy.rb
```

**After configuration:** Quit and restart Claude Desktop completely.

### For Claude Code

Create or edit: `~/.config/claude.json`

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

### For Other MCP Clients

Codex exposes a JSON-RPC 2.0 endpoint at `http://localhost:3001/rpc` using the Model Context Protocol specification. Configure your MCP client to use the `mcp-proxy.rb` bridge or connect directly via HTTP.

### Verification

Open AI Agent and say:
> "Start a new quest for fixing authentication bugs"

If AI Agent starts asking clarifying questions, you're all set! 🎉

---

## Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose logs

# Common fixes:
# - Port 3001 in use: Change port in docker-compose.yml
# - Docker not running: Start Docker Desktop
```

### Claude can't connect to Codex
```bash
# 1. Check container is running
docker-compose ps

# 2. Test health endpoint
curl http://localhost:3001/health

# 3. Verify absolute path in config (not ~ or relative)

# 4. Restart Claude Desktop completely (Quit, then reopen)
```

### MCP proxy errors
```bash
# Test proxy manually
echo '{"jsonrpc":"2.0","method":"tools/list","id":1}' | ruby mcp-proxy.rb

# Check Claude logs (macOS)
tail -f ~/Library/Logs/Claude/*.log
```

### Database issues
```bash
# Reset database (WARNING: deletes all data)
docker-compose down -v
docker-compose up -d
```

### Useful commands
```bash
# View logs
docker-compose logs -f

# Restart server
docker-compose restart

# Stop server
docker-compose down

# Rebuild after code changes
docker-compose down && docker-compose build && docker-compose up -d
```

---

## Contributing

Contributions welcome! Please open an issue or pull request.

---

**Made with ❤️ and ☕**

*"Turn your todos into quests. Your work into adventures. Your coffee breaks into well-deserved XP bonuses."*
