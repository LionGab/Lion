# Advanced Usage

## Custom Research Patterns

### Creating Your Own Pattern

1. Create a YAML file in `patterns/`:
```yaml
name: "Security Audit"
agents: 5
questions:
  - "Known vulnerabilities and CVEs?"
  - "Attack surface analysis?"
  - "Best practices compliance?"
  - "Incident history and responses?"
  - "Mitigation strategies?"
```

2. Use it:
```bash
./ccheavy.sh --pattern security "Analyze security of Kubernetes"
```

## Integration with CCCEO Workflow

### As a Research Phase

Before creating issues, use heavy analysis:
```bash
# Research phase
./ccheavy.sh "Research best practices for authentication in Next.js 14"

# Use findings to create issues
claude-desktop: "Create 10 issues based on heavy analysis findings"
```

### For Architecture Decisions

```bash
# Deep dive before choosing
./ccheavy.sh "Compare PostgreSQL vs DynamoDB for our use case" 6

# Informed decision making
outputs/*/final-analysis.md → architectural-decisions.md
```

## Automation Patterns

### Scheduled Research

```bash
# Daily AI news digest
0 9 * * * cd ~/claude-code-heavy && ./ccheavy.sh "Latest AI developments in last 24 hours" 3

# Weekly competitor analysis
0 10 * * 1 cd ~/claude-code-heavy && ./ccheavy.sh "What shipped at major AI companies this week" 4
```

### CI/CD Integration

```yaml
# .github/workflows/research.yml
name: Architecture Research
on:
  issues:
    types: [labeled]

jobs:
  research:
    if: contains(github.event.label.name, 'needs-research')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: |
          ./ccheavy.sh "${{ github.event.issue.title }}" 4
          # Upload findings as artifact
```

## Performance Optimization

### Caching Agent Responses

```bash
# Enable caching (reduces duplicate searches)
export CLAUDE_CACHE_DIR="./cache"
./ccheavy.sh "Cached query" 4
```

### Parallel Efficiency

```bash
# Optimal agent counts by query type
Simple facts: 2-3 agents
Standard research: 4 agents (default)
Complex analysis: 6-8 agents
Academic depth: 8-10 agents

# Diminishing returns after 10 agents
```

## Advanced Synthesis Options

### Custom Synthesis Prompts

Create `templates/synthesis-academic.txt`:
```
Synthesize as academic paper with:
- Abstract
- Literature Review  
- Methodology
- Findings
- Discussion
- References
```

Use with:
```bash
./ccheavy.sh --synthesis academic "Research topic"
```

### Multi-Stage Analysis

```bash
# Stage 1: Broad research
./ccheavy.sh "AI in healthcare" 6

# Stage 2: Deep dive on findings
./ccheavy.sh "AI in radiology specifically" 4

# Stage 3: Implementation focus
./ccheavy.sh "Implementing AI radiology in hospitals" 4
```

## Debugging & Troubleshooting

### Verbose Mode

```bash
# See what each agent is doing
./ccheavy.sh --verbose "Query" 4

# Includes:
# - Generated questions
# - Agent commands
# - Search queries
# - Timing information
```

### Agent Logs

```bash
# Check individual agent work
tail -f outputs/latest/agent-1.log

# Common issues:
# - "No results" → Query too specific
# - "Timeout" → Complex query, increase timeout
# - "Git error" → Clean worktrees
```

### Recovery from Failures

```bash
# If synthesis fails but agents completed
claude -p "Synthesize: $(ls outputs/latest/vp-*.md)"

# If specific agent fails
claude -p "Research question 3 from outputs/latest/questions.txt"
```

## MCP Tool Integration

### Available During Research

Each agent can use:
- Web search
- GitHub operations
- Google Drive access
- Custom MCP servers

### Adding Custom Tools

1. Install MCP server:
```bash
npm install -g @your/mcp-server
```

2. Configure in Claude:
```json
{
  "mcpServers": {
    "custom": {
      "command": "npx",
      "args": ["@your/mcp-server"]
    }
  }
}
```

3. Agents automatically use available tools

## Extending the System

### Add Progress Notifications

```bash
# In ccheavy.sh, add:
notify_complete() {
  osascript -e 'display notification "Research complete!" with title "Claude Heavy"'
}
```

### Export Formats

```bash
# Add converters
./ccheavy.sh "Query" 4 --export pdf
./ccheavy.sh "Query" 4 --export markdown
./ccheavy.sh "Query" 4 --export notion
```

### API Wrapper

```python
# heavy_api.py
import subprocess
import json

def heavy_research(query, agents=4):
    result = subprocess.run(
        ["./ccheavy.sh", query, str(agents)],
        capture_output=True,
        text=True
    )
    return parse_output(result.stdout)
```

## Best Practices

1. **Start Broad, Then Narrow**
   - First run: General topic
   - Second run: Specific aspects
   - Third run: Implementation details

2. **Save Important Research**
   ```bash
   cp -r outputs/20240118_142532/ saved-research/ai-strategy/
   ```

3. **Reuse Good Questions**
   - Save effective questions
   - Create pattern templates
   - Share with team

4. **Monitor Token Usage**
   ```bash
   # Add to ccheavy.sh
   echo "Estimated tokens: $((AGENT_COUNT * 50000))"
   ```

5. **Version Control Research**
   ```bash
   git add saved-research/
   git commit -m "Research: AI strategy findings"
   ```

Remember: The power is in parallel perspectives combining into unified insight.
