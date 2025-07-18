# Claude Code Heavy

A powerful multi-agent research system using Claude Code to deliver comprehensive, multi-perspective analysis through intelligent orchestration. Inspired by Grok's heavy mode and make-it-heavy.

**⚠️ IMPORTANT: Read [WHICH-SCRIPT.md](WHICH-SCRIPT.md) to understand which script to use!**

## 🚀 What is Claude Code Heavy?

Claude Code Heavy orchestrates multiple Claude instances in parallel to:
- 🧠 **Deep Analysis**: Generate specialized research questions automatically
- 🔀 **Parallel Research**: Deploy 4+ agents simultaneously for comprehensive coverage  
- 🎯 **Multi-Perspective**: Each agent approaches from a unique angle
- 🔄 **Intelligent Synthesis**: Combine all findings into unified insights
- 📊 **Real-Time Progress**: Visual feedback during execution

## 🎯 Quick Start

**⚠️ IMPORTANT: Use `heavy-interactive.sh` for standard Claude Code!**

```bash
# Clone the repo
git clone https://github.com/yourusername/claude-code-heavy
cd claude-code-heavy

# Make scripts executable
chmod +x heavy-interactive.sh

# Run the INTERACTIVE version (works with standard Claude Code)
./heavy-interactive.sh "What would a city designed entirely by AI optimize for?"
```

**Note on Scripts:**
- ✅ `heavy-interactive.sh` - Works with standard Claude Code installation
- ❌ `heavy.sh` - Requires API key setup (see API Mode section below)

## 📖 How It Works

```mermaid
graph TD
    A[User Query] --> B[CEO: Question Generation]
    B --> C[Generate 4 Specialized Questions]
    C --> D[President: Coordinate Agents]
    D --> E[VP1: Research]
    D --> F[VP2: Analysis]
    D --> G[VP3: Alternatives]
    D --> H[VP4: Verification]
    E --> I[CEO: Synthesis]
    F --> I
    G --> I
    H --> I
    I --> J[Comprehensive Answer]
```

### Architecture

- **Chairman**: You (provides the query)
- **CEO**: Claude Desktop (generates questions, synthesizes results)
- **President**: Claude Code (coordinates VPs)
- **VPs**: Sub-agents (parallel research)

## 🛠️ Installation

### Prerequisites
- Claude Desktop installed
- Claude Code (`npm install -g @anthropic-ai/claude-code`)
- Git with worktree support
- Unix-like environment (Mac/Linux/WSL)

### Setup
```bash
# Install Claude Code if you haven't
npm install -g @anthropic-ai/claude-code

# Clone and setup
git clone https://github.com/yourusername/claude-code-heavy
cd claude-code-heavy
./setup.sh
```

## 🎮 Usage Modes

### Interactive Mode (Recommended)
Full parallel multi-agent analysis with human orchestration:
```bash
./heavy-interactive.sh "Analyze the impact of AI on software development"
```

### Custom Assistant Count
Run with more assistants for deeper analysis:
```bash
./heavy-interactive.sh "Complex quantum computing question" 6
```

### Minimal Mode
For simpler queries with fewer assistants:
```bash
./heavy-interactive.sh "What is Python?" 2
```

## 🔑 API Mode (Advanced Users Only)

If you have an Anthropic API key and want fully automated operation:

1. Set up your API key:
```bash
export ANTHROPIC_API_KEY="your-key-here"
```

2. Configure Claude Code for API access (see Anthropic docs)

3. Use the automated script:
```bash
./heavy.sh "Your question" 4  # Requires API setup!
```

**Note**: Most users should use `heavy-interactive.sh` instead.

## 📋 Example Outputs

<details>
<summary>Example: "What would a city designed entirely by AI optimize for?"</summary>

**Generated Questions:**
1. VP1: Current real-world examples of AI in urban planning
2. VP2: What metrics would AI optimize for vs human priorities
3. VP3: Human needs that AI might miss or ignore
4. VP4: Verify claims about smart cities and human satisfaction

**Synthesized Result:**
AI would create a 98% efficient city with zero traffic jams but potentially zero human joy...
</details>

## 🔧 Configuration

Edit `config.sh` to customize:
```bash
# Number of parallel agents
DEFAULT_AGENTS=4

# Output directory
OUTPUT_DIR="./outputs"

# Synthesis style
SYNTHESIS_STYLE="comprehensive"  # or "concise", "academic"
```

## 🤝 Comparison with make-it-heavy

| Feature | make-it-heavy | claude-code-heavy (interactive) | claude-code-heavy (API) |
|---------|---------------|--------------------------------|-------------------------|
| Parallel Agents | ✅ Python threads | ✅ Manual orchestration | ✅ Git worktrees |
| Question Generation | ✅ AI-powered | ✅ AI-powered | ✅ AI-powered |
| Tool Access | ✅ Custom tools | ✅ Native + MCP | ✅ Native + MCP |
| API Required | ✅ OpenRouter | ❌ No API needed | ✅ Anthropic API |
| Setup Time | ~5 minutes | ~30 seconds | ~10 minutes |
| Human Involvement | Minimal | Active orchestrator | Watch it run |
| Works Out of Box | ❌ Need API key | ✅ Yes! | ❌ Need API key |

## 🚀 Advanced Features

### Custom Research Patterns
Create your own research templates in `patterns/`:
```yaml
# patterns/academic.yaml
name: "Academic Research"
agents: 6
questions:
  - "Literature review and citations"
  - "Methodology analysis"
  - "Counter-arguments"
  - "Future research directions"
  - "Practical applications"
  - "Peer review simulation"
```

### MCP Tool Integration
Automatically uses available MCP tools:
- Web search
- GitHub integration
- Google Drive access
- Custom tools

### Persistent Context
Unlike make-it-heavy, maintains context across sessions:
```bash
./heavy.sh --continue "Follow up on previous analysis"
```

## 🏗️ Architecture Details

### File Structure
```
claude-code-heavy/
├── heavy.sh           # Main orchestrator
├── setup.sh          # Setup script
├── config.sh         # Configuration
├── patterns/         # Research patterns
├── outputs/          # Analysis outputs
├── worktrees/        # Agent workspaces
└── templates/        # Prompt templates
```

### How Agents Communicate
1. CEO creates research plan in `research-plan.md`
2. Each VP reads plan and works independently
3. VPs write findings to `vp-N-findings.md`
4. CEO synthesizes all findings

## 🎯 Best Practices

1. **Query Clarity**: More specific queries yield better results
2. **Agent Count**: 4 agents optimal for most queries, 6-8 for complex topics
3. **Time Management**: Expect 2-5 minutes for full analysis
4. **Context Preservation**: Save important outputs for future reference

## 🐛 Troubleshooting

### "Command not found: claude"
```bash
npm install -g @anthropic-ai/claude-code
```

### "Git worktree error"
```bash
# Update git
brew upgrade git  # Mac
sudo apt-get update && sudo apt-get upgrade git  # Linux
```

### Agents seem stuck
```bash
# Check agent status
./heavy.sh --status

# Force cleanup
./heavy.sh --cleanup
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Test with various query types
4. Submit a pull request

## 📄 License

MIT - Inspired by make-it-heavy's approach but implemented entirely with Claude Code.

## 🙏 Acknowledgments

- Inspired by [make-it-heavy](https://github.com/Doriandarko/make-it-heavy) by Pietro Schirano
- Built on [Claude Code](https://docs.anthropic.com/claude-code) by Anthropic
- Uses concepts from [CCCEO](https://github.com/gtrusler/CCCEO) methodology
