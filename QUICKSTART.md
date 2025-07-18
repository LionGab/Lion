# Quick Start Guide

## Installation (30 seconds)

```bash
# Prerequisites (if not installed)
npm install -g @anthropic-ai/claude-code

# Clone and setup
git clone https://github.com/yourusername/claude-code-heavy
cd claude-code-heavy
./setup.sh
```

## Your First Heavy Analysis

```bash
./heavy.sh "What is the future of AI?"
```

This will:
1. Generate 4 research questions
2. Launch 4 parallel Claude agents
3. Each researches their specific angle
4. Synthesize into comprehensive analysis
5. Save results to `outputs/[timestamp]/`

## Example Queries

### Technology Analysis
```bash
./heavy.sh "Compare React, Vue, and Angular for enterprise applications"
```

### Person Research  
```bash
./heavy.sh "Who is Sam Altman and what is his impact on AI?"
```

### Complex Topics
```bash
./heavy.sh "Analyze the implications of quantum computing on cryptography" 6
# Uses 6 agents for deeper analysis
```

### Business Analysis
```bash
./heavy.sh "What are the key success factors for AI startups in 2024?"
```

## Understanding the Output

Your analysis will include:
- **Executive Summary**: High-level integration of all findings
- **Detailed Findings**: Organized by theme, not by agent
- **Key Insights**: Most important discoveries
- **Areas of Agreement**: What all agents confirmed
- **Contradictions**: Where perspectives differed
- **Conclusion**: Unified final perspective

## Tips for Best Results

1. **Be Specific**: "Impact of AI on healthcare diagnostics" > "AI in healthcare"
2. **Add Context**: Include timeframes, locations, or specific aspects
3. **Adjust Agent Count**: Simple = 2-3, Standard = 4, Complex = 6-8
4. **Save Important Results**: Copy final analysis for future reference

## Monitoring Progress

Watch the real-time progress indicators:
- ⠋ ⠙ ⠹ ⠸ = Agent working
- ✓ = Agent complete

## Troubleshooting

**Agents seem slow?**
- Normal: Each agent does thorough research
- Complex queries take 3-5 minutes
- Check logs in `outputs/[timestamp]/agent-N.log`

**Git worktree errors?**
```bash
# Clean up and retry
rm -rf worktrees/
./heavy.sh "Your query"
```

**Need to stop?**
- Press Ctrl+C to cancel
- Partial results saved in outputs folder
