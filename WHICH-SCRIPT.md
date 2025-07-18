# ⚠️ WHICH SCRIPT TO USE?

## TL;DR
**Use `heavy-interactive.sh`** - It works with standard Claude Code!

## The Two Scripts Explained

### 1. heavy-interactive.sh ✅ (RECOMMENDED)
- **Works with**: Standard Claude Code installation
- **How it works**: Creates prompts for you to manually paste into Claude terminals
- **Human role**: Active orchestrator (Head Researcher)
- **API needed**: NO
- **Command**: `./heavy-interactive.sh "Your question"`

### 2. heavy.sh ❌ (REQUIRES API)
- **Works with**: ONLY if you have Anthropic API key configured
- **How it works**: Tries to automate everything using `claude -p`
- **Human role**: Just watch
- **API needed**: YES - Must set `ANTHROPIC_API_KEY`
- **Command**: `./heavy.sh "Your question"` (will fail without API)

## Why Two Scripts?

We kept both to show two approaches:
1. **Interactive** - How Claude Code is designed to be used
2. **Automated** - How you could use it with API access

But Claude Code is fundamentally an interactive tool, not an automation API.

## Setting Up API Mode (If You Really Want To)

1. Get an Anthropic API key from https://console.anthropic.com
2. Set environment variable:
   ```bash
   export ANTHROPIC_API_KEY="sk-ant-..."
   ```
3. Configure Claude Code for API access (complex - see Anthropic docs)
4. Then `heavy.sh` might work

## Our Recommendation

Just use `heavy-interactive.sh` - it's actually better because:
- You see research as it happens
- You can guide the assistants
- No API costs
- Works immediately
- More educational

The interactive approach turns out to be a feature, not a limitation!
