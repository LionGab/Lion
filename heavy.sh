#!/bin/bash
# heavy.sh - Claude Code Heavy orchestrator
# Replicates make-it-heavy functionality using Claude Code

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
DEFAULT_AGENTS=4
QUERY="$1"
AGENT_COUNT="${2:-$DEFAULT_AGENTS}"
OUTPUT_DIR="./outputs/$(date +%Y%m%d_%H%M%S)"
TEMPLATES_DIR="./templates"

# Validate input
if [ -z "$QUERY" ]; then
    echo -e "${RED}Error: No query provided${NC}"
    echo "Usage: $0 \"Your research question\" [number_of_agents]"
    echo "Example: $0 \"Who is Pietro Schirano?\" 4"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"
mkdir -p "$TEMPLATES_DIR"

# Banner
echo -e "${CYAN}"
echo "╔═══════════════════════════════════════╗"
echo "║      Claude Code Heavy Analysis       ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${YELLOW}Query:${NC} $QUERY"
echo -e "${YELLOW}Agents:${NC} $AGENT_COUNT"
echo -e "${YELLOW}Output:${NC} $OUTPUT_DIR"
echo

# Phase 1: Question Generation
echo -e "${BLUE}══ Phase 1: Question Generation ══${NC}"
echo "CEO generating specialized research questions..."

cat > "$OUTPUT_DIR/generate-questions.txt" << EOF
For the query: "$QUERY"

Generate exactly $AGENT_COUNT specialized research questions that together provide comprehensive coverage.
Each question should approach from a different angle:

1. Factual/Research - Direct information gathering
2. Analytical/Metrics - Data, measurements, impact analysis  
3. Critical/Alternative - Contrarian views, limitations, criticisms
4. Verification/Cross-check - Fact-checking, source validation
5. Historical/Context - Background, evolution, timeline
6. Future/Implications - Predictions, potential developments

Output in this exact format:
QUESTION_1: [question]
QUESTION_2: [question]
...
EOF

# Use Claude to generate questions
claude -p "$(cat $OUTPUT_DIR/generate-questions.txt)" > "$OUTPUT_DIR/questions.txt" 2>&1

echo -e "${GREEN}✓ Questions generated${NC}"
echo
cat "$OUTPUT_DIR/questions.txt"
echo
# Phase 2: Setup Agent Worktrees
echo -e "${BLUE}══ Phase 2: Setting Up Agent Workspaces ══${NC}"

# Create worktrees for agents
for i in $(seq 1 "$AGENT_COUNT"); do
    BRANCH="heavy-agent-$i"
    WORKTREE="worktrees/agent-$i"
    
    # Clean up if exists
    if git worktree list | grep -q "$WORKTREE"; then
        git worktree remove "$WORKTREE" --force 2>/dev/null || true
    fi
    
    # Create new worktree
    git worktree add -b "$BRANCH" "$WORKTREE" 2>/dev/null || git worktree add "$WORKTREE" "$BRANCH"
    echo -e "${GREEN}✓ Created workspace for Agent $i${NC}"
done

# Phase 3: Create Agent Instructions
echo -e "${BLUE}══ Phase 3: Creating Agent Instructions ══${NC}"

# Extract questions
QUESTIONS=()
while IFS= read -r line; do
    if [[ $line =~ QUESTION_[0-9]+:\ (.+) ]]; then
        QUESTIONS+=("${BASH_REMATCH[1]}")
    fi
done < "$OUTPUT_DIR/questions.txt"

# Create instruction for each agent
for i in $(seq 1 "$AGENT_COUNT"); do
    QUESTION="${QUESTIONS[$((i-1))]:-Research question $i}"
    
    cat > "$OUTPUT_DIR/agent-$i-prompt.txt" << EOF
You are Research Agent VP-$i conducting specialized research.

Your research question: $QUESTION

Instructions:
1. Use web_search extensively to gather information
2. Verify sources and cross-reference claims
3. Look for specific examples and evidence
4. Consider multiple perspectives
5. Document your findings in detail

Output your complete findings to: $OUTPUT_DIR/vp-$i-findings.md

Format your output as:
# VP-$i Research Findings

## Research Question
$QUESTION

## Key Findings
[Your detailed findings]

## Sources
[List all sources used]

## Summary
[Concise summary of discoveries]
EOF
    echo -e "${GREEN}✓ Created instructions for Agent $i${NC}"
done
# Phase 4: Launch Parallel Agents
echo -e "${BLUE}══ Phase 4: Launching Parallel Research ══${NC}"
echo "Starting $AGENT_COUNT agents in parallel..."
echo

# Function to show progress
show_progress() {
    local pid=$1
    local agent=$2
    local spinner=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local spin_i=0
    
    while kill -0 $pid 2>/dev/null; do
        printf "\r${CYAN}Agent $agent: ${spinner[$spin_i]} Working...${NC}"
        spin_i=$(( (spin_i + 1) % 10 ))
        sleep 0.1
    done
    
    printf "\r${GREEN}Agent $agent: ✓ Complete    ${NC}\n"
}

# Launch agents
PIDS=()
for i in $(seq 1 "$AGENT_COUNT"); do
    (
        cd "worktrees/agent-$i"
        claude --no-conversation-file -p "$(cat $OUTPUT_DIR/agent-$i-prompt.txt)" > "$OUTPUT_DIR/agent-$i.log" 2>&1
    ) &
    
    PID=$!
    PIDS+=($PID)
    show_progress $PID $i &
done

# Wait for all agents
echo
echo "Waiting for all agents to complete..."
for pid in "${PIDS[@]}"; do
    wait $pid
done

echo
echo -e "${GREEN}✓ All agents completed${NC}"

# Phase 5: Synthesis
echo
echo -e "${BLUE}══ Phase 5: Synthesis ══${NC}"
echo "CEO synthesizing all findings..."

# Create synthesis prompt
cat > "$OUTPUT_DIR/synthesis-prompt.txt" << EOF
You are the CEO synthesizing research from $AGENT_COUNT specialized agents.

Read all agent findings and create a comprehensive "Grok Heavy" style analysis that:
1. Integrates all perspectives
2. Highlights agreements and contradictions
3. Provides nuanced, multi-faceted understanding
4. Maintains high information density
5. Includes all important details from each agent

Agent findings files:
EOF

# Add all findings files
for i in $(seq 1 "$AGENT_COUNT"); do
    echo "- $OUTPUT_DIR/vp-$i-findings.md" >> "$OUTPUT_DIR/synthesis-prompt.txt"
done

cat >> "$OUTPUT_DIR/synthesis-prompt.txt" << EOF

Create a comprehensive synthesis and save to: $OUTPUT_DIR/final-analysis.md

Format as:
# Comprehensive Analysis: $QUERY

## Executive Summary
[High-level overview integrating all perspectives]

## Detailed Findings
[Synthesized findings organized by theme, not by agent]

## Key Insights
[Most important discoveries across all agents]

## Areas of Agreement
[What all agents confirmed]

## Contradictions & Nuances
[Where agents found different information]

## Conclusion
[Final unified perspective]
EOF

# Run synthesis
claude -p "$(cat $OUTPUT_DIR/synthesis-prompt.txt)" > "$OUTPUT_DIR/synthesis.log" 2>&1

echo -e "${GREEN}✓ Synthesis complete${NC}"

# Phase 6: Display Results
echo
echo -e "${CYAN}══ Analysis Complete ══${NC}"
echo
echo -e "${YELLOW}Final analysis saved to:${NC}"
echo "$OUTPUT_DIR/final-analysis.md"
echo
echo -e "${YELLOW}All outputs available in:${NC}"
echo "$OUTPUT_DIR/"
echo

# Show final analysis
if [ -f "$OUTPUT_DIR/final-analysis.md" ]; then
    echo -e "${BLUE}══ Final Analysis Preview ══${NC}"
    head -20 "$OUTPUT_DIR/final-analysis.md"
    echo
    echo -e "${CYAN}[... see full analysis in output file ...]${NC}"
fi

# Cleanup
echo
echo -e "${YELLOW}Cleaning up worktrees...${NC}"
for i in $(seq 1 "$AGENT_COUNT"); do
    git worktree remove "worktrees/agent-$i" --force 2>/dev/null || true
done

echo -e "${GREEN}✓ Done!${NC}"
