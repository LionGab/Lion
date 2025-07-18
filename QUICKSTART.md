# Quick Start Guide

Get up and running with Claude Code Heavy in under 2 minutes!

## 🚀 Installation (30 seconds)

```bash
# Clone the repository
git clone https://github.com/yourusername/claude-code-heavy
cd claude-code-heavy

# Run setup
./setup.sh
```

## 🎯 Your First Research (Interactive Mode)

The easiest way to use Claude Code Heavy:

```bash
./ccheavy.sh
```

You'll see:
```
╔════════════════════════════════════════╗
║   Claude Code Heavy - Interactive Mode ║
╚════════════════════════════════════════╝

What would you like to research?
> How can cities reduce traffic congestion?

Based on your query, I suggest using 3 research assistants.
How many would you like to use? (2-6, or press Enter for 3)
> [Enter]

Output format? (markdown/text, or press Enter for markdown)
> [Enter]

Ready to start research with:
  📝 Query: How can cities reduce traffic congestion?
  👥 Assistants: 3
  📄 Format: markdown

Proceed? (Y/n)
> [Enter]
```

Then choose to auto-launch Claude:
```
✅ Setup complete!

Would you like to launch Claude Code with the prompt? (Y/n)
> [Enter]

Launching Claude Code...
Research will begin automatically!
```

Claude Code opens with the prompt pre-filled and starts executing immediately!

## 📝 Command Line Mode

For automation or specific settings:

```bash
# Basic usage
./ccheavy.sh "What are the latest advances in quantum computing?"

# With 6 assistants for complex topics
./ccheavy.sh "Analyze global economic impacts of climate change" 6

# Text format output
./ccheavy.sh "Explain Docker containers" 2 text
```

## 🎯 Pattern Examples

The system automatically detects and applies specialized patterns:

### Scientific Research (5 assistants)
```bash
./ccheavy.sh "How do mRNA vaccines work?"
# Activates: Current Science, Methods, Controversies, Applications, Critical Analysis
```

### Policy Analysis (5 assistants)
```bash
./ccheavy.sh "Analyze universal basic income policy proposals"
# Activates: Policy Landscape, Cost-Benefit, Case Studies, Implementation, Evidence
```

### Historical Analysis (4 assistants)
```bash
./ccheavy.sh "What led to the fall of the Roman Empire?"
# Activates: Sources & Timeline, Context, Narratives, Modern Relevance
```

### Product/Market Analysis (5 assistants)
```bash
./ccheavy.sh "Analyze the electric vehicle market"
# Activates: Market Analysis, User Research, Technical, Business Strategy, Risks
```

## 📊 Example Research Questions

Try these to see the system in action:

1. **Technology**: "How do neural networks actually work?"
2. **Analysis**: "Compare renewable energy sources for homes"
3. **Complex**: "What would happen if we eliminated all mosquitoes?"
4. **Current Events**: "Analyze the impact of remote work on cities"

## 📁 Understanding Your Output

After ~15-20 minutes, check your results:

```bash
# List all research outputs
ls -la outputs/

# View the final analysis
cat outputs/2025-07-18-reduce-traffic-congestion/final-analysis.md
```

Output structure:
```
outputs/2025-07-18-reduce-traffic-congestion/
├── coordination-prompt.md    # The prompt used
├── assistants/
│   ├── ra-1-findings.md     # Technology research
│   ├── ra-2-findings.md     # Impact analysis
│   └── ra-3-findings.md     # Critical review
└── final-analysis.md        # Synthesized insights
```

## 💡 Pro Tips

1. **Let the system guide you**: Interactive mode suggests optimal settings
2. **Use auto-launch**: Much easier than copy-pasting prompts
3. **Start simple**: Try a basic query first to see how it works
4. **Watch the progress**: Claude shows what each assistant is researching
5. **Save good prompts**: The coordination prompts can be reused

## 🔍 Monitoring Progress

While Claude Code runs, you'll see:
- Which assistant is currently researching
- What sources they're finding
- Progress through the research phases
- Real-time synthesis as it happens

## ❓ Common Questions

**Q: Why not fully automated?**
A: Interactive mode gives you full Claude Code features without API costs, larger context windows, and real-time monitoring.

**Q: How long does research take?**
A: Typically 15-20 minutes for 4 assistants, depending on query complexity.

**Q: Can I stop and resume?**
A: Yes, all work is saved in git worktrees. You can stop and continue later.

**Q: What if Claude Code closes?**
A: Just re-run with the same query - worktrees persist the state.

## 🚨 Troubleshooting

### Claude Code doesn't open
Make sure Claude Desktop is running first.

### "Permission denied"
```bash
chmod +x ccheavy.sh setup.sh
```

### Git errors
Ensure you have git 2.7+ with worktree support:
```bash
git --version
```

## 🎉 Next Steps

1. Try different query types to see various research patterns
2. Experiment with different assistant counts (2-6)
3. Check out `patterns/` for specialized research templates
4. Read `ADVANCED.md` for power user features

Happy researching! 🔬
