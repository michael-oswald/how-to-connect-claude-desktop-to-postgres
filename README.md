# Chat with PostgreSQL using Claude Desktop

Query your PostgreSQL database using natural language with Claude Desktop (Incognito Mode). Powered by the Model Context Protocol (MCP).

![Demo](demo.gif)

**Privacy Note:** Incognito mode in Claude Desktop does not keep your chats in local/visible history or memory and does not use them for model training, but it does store your prompts and responses on Anthropic's servers for approximately 30 days under the standard retention policy (and potentially longer only if flagged for trust-and-safety reasons). Your prompts and Claude's responses are processed on Anthropic's servers (the model runs in the cloud, not locally). Handle sensitive data with appropriate caution. 

## Quick Start

**Prerequisites:** Node.js 18+, Docker, Claude Desktop

**1. Start PostgreSQL:**
```bash
git clone https://github.com/michael-oswald/ollama-talks-to-postgres-private-mode.git
cd ollama-talks-to-postgres-private-mode
./start-postgres.sh
```

**2. Configure Local MCP servers in Claude Desktop:**
`Settings -> Developer -> Local MCP Servers -> Edit Config`

Edit `~/Library/Application\ Support/Claude/claude_desktop_config.json` (if on a mac)

Paste the following json into your `claude_desktop_config.json`:
```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://postgres:postgres@localhost:5432/mydb"
      ]
    }
  }
}
```

**3. Restart Claude Desktop** Completely quit and restart Claud Desktop for changes to take effect.

## Example Prompts to use to test it out

- "What tables are in my database?"
- "Show me the top 5 customers by total spending"
- "List all pending orders from the last week"
- "Which products have never been ordered?"

## Using Your Own Database

Update the connection string in your Claude Desktop config:
```json
"postgresql://your_user:your_password@your_host:5432/your_database"
```

## Available Tools

- `list_tables` - List all database tables
- `describe_table` - Get table schema
- `execute_query` - Run SELECT queries (read-only)
- `get_table_sample` - Preview table data

## Troubleshooting

- Completely quit and restart Claude Desktop after config changes
- Verify PostgreSQL is running: `docker ps | grep postgres-mcp`
- Check logs: `~/Library/Logs/Claude/`

## License

MIT License - See [LICENSE](LICENSE)
