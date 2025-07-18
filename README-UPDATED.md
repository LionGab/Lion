# Claude Code Heavy (Updated)

Multi-agent research orchestration using Claude Code - the **interactive** way.

## 🚨 Important: How Claude Code Actually Works

Claude Code is designed for **interactive** use, not automated scripting. The original approach using `claude -p` requires API configuration that isn't standard. Instead, we use an **orchestrated interactive workflow** that's actually more powerful.

## 🚀 Quick Start (Interactive Mode)

```bash
# Clone the repo
git clone https://github.com/gtrusler/claude-code-heavy
cd claude-code-heavy

# Run the interactive orchestrator
./heavy-interactive.sh "What would a city designed entirely by AI optimize for?"
```

This creates:
- Research plan with Head Researcher & Research Assistants roles
- Individual prompts for each assistant
- Clear launch instructions

## 🎯 The Workflow

### 1. Head Researcher Phase (You)
- Review the generated research plan
- Optionally refine research questions
- Prepare for synthesis

### 2. Research Assistant Phase
Open multiple terminals (one per assistant):

```bash
# Terminal 1
claude --no-conversation-file
# Paste assistant-1-prompt.md content

# Terminal 2  
claude --no-conversation-file
# Paste assistant-2-prompt.md content

# Repeat for all assistants...
```

### 3. Synthesis Phase
- Head Researcher reads all findings
- Creates comprehensive analysis
- Integrates multiple perspectives

## 📋 Example Session

```bash
# 1. Generate research structure
./heavy-interactive.sh "Analyze the impact of AI on software development" 4

# 2. Review the created files
ls outputs/20240118_*/
# Shows: research-plan.md, assistant prompts, etc.

# 3. Launch assistants (4 terminals)
# Each researches their specific angle

# 4. Synthesize findings
# Combine all research into final analysis
```

## 🤔 Why Interactive is Better

1. **Quality Control** - See research as it happens
2. **Flexibility** - Adjust on the fly
3. **No API Limits** - Uses your Claude subscription
4. **Full Features** - All Claude Code tools available
5. **Learning** - Understand what each agent discovers

## 🔧 Customization

### Research Patterns
Edit patterns in `patterns/` directory:
- `academic.yaml` - 6-agent academic research
- `business.yaml` - 5-agent business analysis  
- `technical.yaml` - 4-agent technical deep dive

### Adjust Assistant Count
```bash
# More assistants for complex topics
./heavy-interactive.sh "Complex quantum computing question" 6

# Fewer for simple queries
./heavy-interactive.sh "What is Python?" 2
```

## 📊 Comparison with make-it-heavy

| Aspect | make-it-heavy | claude-code-heavy |
|--------|---------------|-------------------|
| Automation | ✅ Fully automated | 🔄 Interactive orchestration |
| API Needs | OpenRouter API | Claude subscription |
| Control | Limited | Full human oversight |
| Quality | Good | Excellent (human guided) |
| Speed | Faster | More thorough |

## 🎯 When to Use This

Perfect for:
- Deep research projects
- Complex multi-faceted questions
- When quality matters more than speed
- Learning while researching
- Collaborative research sessions

## 🚀 Future Enhancements

We're exploring:
- Webhook-based coordination
- Browser automation for launching
- Research session recording
- Template library expansion

## 🤝 Contributing

The interactive approach opens new possibilities:
- Share effective prompts
- Create research patterns
- Develop coordination tools
- Build synthesis templates

## 📄 License

MIT - Inspired by make-it-heavy but adapted for Claude Code's interactive nature.

---

**Note**: The original `heavy.sh` attempting full automation doesn't work without API configuration. Use `heavy-interactive.sh` for the intended experience.
