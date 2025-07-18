# Important: Claude Code Usage in Claude Code Heavy

## Why the Original Script Failed

The original `heavy.sh` script tried to use `claude -p` (headless mode), which requires API key configuration. Claude Code is designed for **interactive** use, not automated scripting.

## The Correct Approach

Instead of trying to automate Claude Code, we use an **orchestrated interactive workflow**:

1. **Head Researcher** (You in Claude Desktop) - Generates questions and synthesizes
2. **Research Assistants** (Claude Code instances) - Parallel research
3. **Manual coordination** - More powerful, allows human oversight

## Quick Start with Interactive Mode

```bash
# Generate the research structure
./heavy-interactive.sh "Who is Pietro Schirano?"

# This creates:
# - Research plan
# - Prompts for each assistant
# - Clear instructions
```

Then you:
1. Open multiple terminals
2. Run `claude --no-conversation-file` in each
3. Paste the appropriate prompt
4. Let them research in parallel
5. Synthesize findings

## Why This is Actually Better

- **Human in the loop** - Better quality control
- **See research in progress** - Can guide if needed  
- **No API limits** - Uses your Claude subscription
- **Full tool access** - All MCP tools available
- **Real-time adjustments** - Can refine as you go

## Alternative: Fully Automated

If you really need automation, consider:
1. Using make-it-heavy with Python
2. Using GPT-4/Gemini APIs instead
3. Building a custom orchestrator with Anthropic API

But for research quality, the interactive approach with Claude Code gives superior results.
