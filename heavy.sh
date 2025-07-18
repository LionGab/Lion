#!/bin/bash
# heavy.sh - Claude Code Heavy Research System
# Parallel research orchestration using git worktrees

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
DEFAULT_ASSISTANTS=4
QUERY="$1"
ASSISTANT_COUNT="${2:-$DEFAULT_ASSISTANTS}"
OUTPUT_FORMAT="${3:-markdown}"  # markdown or text

# Validate input
if [ -z "$QUERY" ]; then
    echo -e "${RED}Error: No query provided${NC}"
    echo "Usage: $0 \"Your research question\" [assistants] [format]"
    echo "Example: $0 \"How do we solve the global water supply issue?\" 4 markdown"
    exit 1
fi

# Create output directory with date and shortened query
SAFE_QUERY=$(echo "$QUERY" | cut -c1-30 | sed 's/[^a-zA-Z0-9 ]//g' | sed 's/ /-/g')
OUTPUT_DIR="./outputs/$(date +%Y-%m-%d)-${SAFE_QUERY}"
mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/assistants"

# Banner
echo -e "${CYAN}"
echo "╔═══════════════════════════════════════╗"
echo "║   Claude Code Heavy Research System   ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${YELLOW}Query:${NC} $QUERY"
echo -e "${YELLOW}Research Assistants:${NC} $ASSISTANT_COUNT"
echo -e "${YELLOW}Output:${NC} $OUTPUT_DIR"
echo

# Generate research questions
echo -e "${BLUE}══ Generating Research Questions ══${NC}"
echo

# Pre-defined questions for 4-assistant pattern
case "$ASSISTANT_COUNT" in
    4)
        QUESTIONS=(
            "What are the current technologies, methods, and real-world implementations addressing this issue?"
            "What is the scale, impact, and cost-benefit analysis of different solutions?"
            "What are the failures, barriers, and unintended consequences of proposed solutions?"
            "Which claims need fact-checking, and what historical precedents can guide us?"
        )
        ROLES=(
            "Technology & Implementation"
            "Impact & Economics"
            "Critical Analysis"
            "Verification & History"
        )
        ;;
    *)
        # Generic pattern for any number
        QUESTIONS=()
        ROLES=()
        for i in $(seq 1 "$ASSISTANT_COUNT"); do
            QUESTIONS+=("Research aspect $i of: $QUERY")
            ROLES+=("Research Focus $i")
        done
        ;;
esac

# Display the research plan
echo -e "${GREEN}Research Plan Created!${NC}"
echo
for i in $(seq 0 $((ASSISTANT_COUNT - 1))); do
    echo -e "${CYAN}RA$((i+1)) - ${ROLES[$i]}${NC}"
    echo "Question: ${QUESTIONS[$i]}"
    echo
done

# Create worktrees
echo -e "${BLUE}══ Setting Up Workspaces ══${NC}"
for i in $(seq 1 "$ASSISTANT_COUNT"); do
    BRANCH="ra-$i-$(date +%s)"
    WORKTREE="worktrees/ra-$i"
    
    # Clean up if exists
    if git worktree list | grep -q "$WORKTREE"; then
        git worktree remove "$WORKTREE" --force 2>/dev/null || true
    fi
    
    # Create new worktree
    git worktree add -b "$BRANCH" "$WORKTREE" >/dev/null 2>&1
    echo -e "${GREEN}✓ Created workspace for RA$i${NC}"
done

# Create the coordination prompt
if [ "$OUTPUT_FORMAT" = "markdown" ]; then
    PROMPT_FILE="$OUTPUT_DIR/coordination-prompt.md"
    cat > "$PROMPT_FILE" << EOF
# Research Coordination: $QUERY

You are coordinating a parallel research team.

## Research Assistants (RA1-$ASSISTANT_COUNT)
Each has their own workspace in \`worktrees/ra-N\`

## Research Questions
EOF

    # Add specific questions
    for i in $(seq 0 $((ASSISTANT_COUNT - 1))); do
        cat >> "$PROMPT_FILE" << EOF

### RA$((i+1)) - ${ROLES[$i]}
- **Question**: ${QUESTIONS[$i]}
- **Workspace**: \`worktrees/ra-$((i+1))\`
- **Output**: \`$OUTPUT_DIR/assistants/ra-$((i+1))-findings.md\`
EOF
    done

    # Add instructions
    cat >> "$PROMPT_FILE" << EOF

## Coordination Instructions
1. Visit each RA workspace using \`cd worktrees/ra-N\`
2. Have them research their question using \`web_search\`
3. Save findings to their output file
4. After all complete, synthesize into \`$OUTPUT_DIR/final-analysis.md\`

## Research Guidelines
- Use web_search extensively
- Focus on recent, credible sources
- Document all sources
- Stay focused on assigned angle
- Work in parallel (switch between RAs frequently)

Start the research!
EOF
else
    # Text format
    PROMPT_FILE="$OUTPUT_DIR/coordination-prompt.txt"
    cat > "$PROMPT_FILE" << EOF
Research Coordination: $QUERY

You are coordinating a parallel research team.

RESEARCH ASSISTANTS (RA1-$ASSISTANT_COUNT):
Each has their own workspace in worktrees/ra-N

RESEARCH QUESTIONS:
EOF

    for i in $(seq 0 $((ASSISTANT_COUNT - 1))); do
        cat >> "$PROMPT_FILE" << EOF

RA$((i+1)) - ${ROLES[$i]}:
Question: ${QUESTIONS[$i]}
Workspace: worktrees/ra-$((i+1))
Output: $OUTPUT_DIR/assistants/ra-$((i+1))-findings.md
EOF
    done

    cat >> "$PROMPT_FILE" << EOF

COORDINATION INSTRUCTIONS:
1. Visit each RA workspace
2. Have them research using web_search
3. Save findings to output files
4. Synthesize into $OUTPUT_DIR/final-analysis.md

Start the research!
EOF
fi

# Display launch instructions
echo
echo -e "${CYAN}══ Ready to Launch ══${NC}"
echo
echo -e "${YELLOW}To start:${NC}"
echo
echo "1. Run: ${GREEN}claude --no-conversation-file${NC}"
echo
echo "2. Paste the coordination prompt from:"
echo "   ${BLUE}$PROMPT_FILE${NC}"
echo
if [ "$OUTPUT_FORMAT" = "markdown" ]; then
    echo "Preview:"
    echo "────────────────────────────────"
    head -20 "$PROMPT_FILE"
    echo "..."
    echo "────────────────────────────────"
else
    cat "$PROMPT_FILE"
fi
echo
echo -e "${GREEN}Research will complete in ~15-20 minutes${NC}"
echo -e "${YELLOW}All outputs saved to: $OUTPUT_DIR/${NC}"
