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

# Helper function to generate folder-friendly names
generate_folder_name() {
    local query="$1"
    local max_length=50
    
    # Convert to lowercase and replace special chars with spaces
    local clean=$(echo "$query" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]/ /g')
    
    # Remove common words
    local stopwords="the is are was were been being have has had do does did will would could should may might must shall can a an and or but for of to in on at by with from up about into through during before after above below between under over"
    
    for word in $stopwords; do
        clean=$(echo "$clean" | sed "s/\b$word\b//g")
    done
    
    # Remove extra spaces and replace with hyphens
    clean=$(echo "$clean" | sed 's/  */ /g' | sed 's/^ *//;s/ *$//' | tr ' ' '-')
    
    # Truncate if still too long
    if [ ${#clean} -gt $max_length ]; then
        clean="${clean:0:$max_length}"
    fi
    
    echo "$clean"
}

# Helper function to suggest number of assistants
suggest_assistant_count() {
    local query="$1"
    local word_count=$(echo "$query" | wc -w)
    
    if echo "$query" | grep -iE "(comprehensive|detailed|thorough|complete|all)" > /dev/null; then
        echo 4
    elif [ $word_count -gt 10 ] || echo "$query" | grep -iE "(compare|analyze|evaluate)" > /dev/null; then
        echo 3
    else
        echo 2
    fi
}

# Interactive mode function
interactive_mode() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════╗"
    echo "║   Claude Code Heavy - Interactive Mode ║"
    echo "╚═══════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Get research question
    echo -e "${GREEN}What would you like to research?${NC}"
    read -r -p "> " query
    
    # Suggest number of assistants
    suggested=$(suggest_assistant_count "$query")
    echo -e "\n${YELLOW}Based on your query, I suggest using $suggested research assistants.${NC}"
    echo -e "How many would you like to use? (2-6, or press Enter for $suggested)"
    read -r -p "> " num_assistants
    
    # Use suggestion if empty
    if [ -z "$num_assistants" ]; then
        num_assistants=$suggested
    fi
    
    # Validate input
    if ! [[ "$num_assistants" =~ ^[2-6]$ ]]; then
        echo -e "${RED}Invalid number. Using $suggested assistants.${NC}"
        num_assistants=$suggested
    fi
    
    # Get output format
    echo -e "\n${GREEN}Output format?${NC} (markdown/text, or press Enter for markdown)"
    read -r -p "> " format
    
    if [ -z "$format" ]; then
        format="markdown"
    fi
    
    # Confirm settings
    echo -e "\n${BLUE}Ready to start research with:${NC}"
    echo -e "  📝 Query: $query"
    echo -e "  👥 Assistants: $num_assistants"
    echo -e "  📄 Format: $format"
    echo -e "\n${GREEN}Proceed? (y/n)${NC}"
    read -r -p "> " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Cancelled.${NC}"
        exit 0
    fi
    
    # Set globals for main execution
    QUERY="$query"
    NUM_ASSISTANTS="$num_assistants"
    OUTPUT_FORMAT="$format"
}

# Main script starts here
if [ $# -eq 0 ]; then
    # No arguments - run interactive mode
    interactive_mode
else
    # Command line mode
    QUERY="$1"
    NUM_ASSISTANTS="${2:-4}"
    OUTPUT_FORMAT="${3:-markdown}"
    
    # Validate assistants
    if ! [[ "$NUM_ASSISTANTS" =~ ^[2-6]$ ]]; then
        echo -e "${RED}Error: Number of assistants must be between 2 and 6${NC}"
        exit 1
    fi
fi

# Configuration
DEFAULT_ASSISTANTS=4
ASSISTANT_COUNT="$NUM_ASSISTANTS"

# Create output directory with date and smart naming
FOLDER_NAME=$(generate_folder_name "$QUERY")
DATE=$(date +%Y-%m-%d)
OUTPUT_DIR="./outputs/${DATE}-${FOLDER_NAME}"
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
    EXT="md"
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
    EXT="txt"
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

# Display completion and offer to launch
echo
echo -e "${GREEN}✅ Setup complete!${NC}"
echo
echo -e "${BLUE}Would you like to launch Claude Code with the prompt? (y/n)${NC}"
read -r -p "> " launch

if [[ "$launch" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Launching Claude Code...${NC}"
    echo -e "${GREEN}Just press Enter in Claude to start the research!${NC}"
    
    # Launch Claude with the prompt pre-filled
    claude --no-conversation-file --chat "$(cat "$PROMPT_FILE")"
else
    echo
    echo -e "${CYAN}══ Manual Launch Instructions ══${NC}"
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
    fi
fi

echo
echo -e "${GREEN}Research will complete in ~15-20 minutes${NC}"
echo -e "${YELLOW}All outputs saved to: $OUTPUT_DIR/${NC}"
