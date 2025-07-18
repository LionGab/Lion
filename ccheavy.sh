#!/bin/bash
# ccheavy.sh - Claude Code Heavy Research System
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

# Function to detect pattern type based on query
detect_pattern_type() {
    local query="$1"
    
    if echo "$query" | grep -iE "(scientific|research|study|experiment|hypothesis|theory)" > /dev/null; then
        echo "scientific"
    elif echo "$query" | grep -iE "(policy|regulation|law|government|legislation)" > /dev/null; then
        echo "policy"
    elif echo "$query" | grep -iE "(history|historical|past|evolution|timeline)" > /dev/null; then
        echo "historical"
    elif echo "$query" | grep -iE "(product|market|business|startup|competition|user)" > /dev/null; then
        echo "product"
    else
        echo "default"
    fi
}

# Function to load pattern
load_pattern() {
    local pattern_type="$1"
    local assistant_count="$2"
    
    # Try to load specific pattern
    if [ -f "patterns/${pattern_type}.yaml" ]; then
        # Extract questions and roles from YAML (simplified parsing)
        QUESTIONS=()
        ROLES=()
        
        case "$pattern_type" in
            "scientific")
                if [ "$assistant_count" -eq 5 ]; then
                    QUESTIONS=(
                        "What is the current scientific understanding and recent breakthroughs in this area?"
                        "What are the experimental methods, data, and evidence supporting current theories?"
                        "What are the competing hypotheses, controversies, and gaps in knowledge?"
                        "What are the practical applications and future research directions?"
                        "What are the limitations, assumptions, and potential biases in current research?"
                    )
                    ROLES=(
                        "Current Science & Breakthroughs"
                        "Methods & Evidence"
                        "Controversies & Gaps"
                        "Applications & Future"
                        "Critical Analysis"
                    )
                fi
                ;;
            "policy")
                if [ "$assistant_count" -eq 5 ]; then
                    QUESTIONS=(
                        "What is the current policy landscape and who are the key stakeholders?"
                        "What are the costs, benefits, and trade-offs of different policy options?"
                        "What do case studies and international comparisons reveal about effectiveness?"
                        "What are the implementation challenges and unintended consequences?"
                        "What evidence supports or contradicts the proposed policies?"
                    )
                    ROLES=(
                        "Policy Landscape"
                        "Cost-Benefit Analysis"
                        "Case Studies"
                        "Implementation"
                        "Evidence Review"
                    )
                fi
                ;;
            "historical")
                if [ "$assistant_count" -eq 4 ]; then
                    QUESTIONS=(
                        "What are the primary sources, timeline, and key events related to this topic?"
                        "What were the social, economic, and political contexts that shaped these events?"
                        "How have interpretations and narratives about this topic evolved over time?"
                        "What parallels, patterns, and lessons can we draw for contemporary issues?"
                    )
                    ROLES=(
                        "Sources & Timeline"
                        "Historical Context"
                        "Evolving Narratives"
                        "Modern Relevance"
                    )
                fi
                ;;
            "product")
                if [ "$assistant_count" -eq 5 ]; then
                    QUESTIONS=(
                        "What is the market size, growth rate, and competitive landscape?"
                        "Who are the target users, what are their needs, and how well are they being served?"
                        "What are the technical capabilities, limitations, and differentiation factors?"
                        "What are the business model, pricing strategies, and path to profitability?"
                        "What are the risks, challenges, and potential disruption scenarios?"
                    )
                    ROLES=(
                        "Market Analysis"
                        "User Research"
                        "Technical Assessment"
                        "Business Strategy"
                        "Risk Analysis"
                    )
                fi
                ;;
        esac
    fi
    
    # Fall back to default if no pattern matched
    if [ ${#QUESTIONS[@]} -eq 0 ]; then
        case "$assistant_count" in
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
                for i in $(seq 1 "$assistant_count"); do
                    QUESTIONS+=("Research aspect $i of: $QUERY")
                    ROLES+=("Research Focus $i")
                done
                ;;
        esac
    fi
}

# Function to edit questions
edit_questions() {
    echo -e "\n${YELLOW}Would you like to edit the research questions? (y/N)${NC}"
    read -r -p "> " edit_choice
    
    if [[ "$edit_choice" =~ ^[Yy]$ ]]; then
        for i in $(seq 0 $((ASSISTANT_COUNT - 1))); do
            echo -e "\n${CYAN}RA$((i+1)) - ${ROLES[$i]}${NC}"
            echo "Current question: ${QUESTIONS[$i]}"
            echo -e "${GREEN}Enter new question (or press Enter to keep current):${NC}"
            read -r -p "> " new_question
            if [ -n "$new_question" ]; then
                QUESTIONS[$i]="$new_question"
            fi
        done
        
        # Option to add more questions
        echo -e "\n${YELLOW}Would you like to add additional research assistants? (y/N)${NC}"
        read -r -p "> " add_more
        
        if [[ "$add_more" =~ ^[Yy]$ ]]; then
            echo -e "${GREEN}How many additional assistants? (max 2 more for total of 8)${NC}"
            read -r -p "> " additional
            
            if [[ "$additional" =~ ^[1-2]$ ]]; then
                local new_total=$((ASSISTANT_COUNT + additional))
                if [ $new_total -le 8 ]; then
                    for i in $(seq $ASSISTANT_COUNT $((new_total - 1))); do
                        echo -e "\n${GREEN}Enter question for RA$((i+1)):${NC}"
                        read -r -p "> " new_question
                        echo -e "${GREEN}Enter role name for RA$((i+1)):${NC}"
                        read -r -p "> " new_role
                        QUESTIONS+=("$new_question")
                        ROLES+=("$new_role")
                    done
                    ASSISTANT_COUNT=$new_total
                fi
            fi
        fi
    fi
}

# Interactive mode function
interactive_mode() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════╗"
    echo "║   Claude Code Heavy - Interactive Mode ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Get research question
    echo -e "${GREEN}What would you like to research?${NC}"
    read -r -p "> " query
    
    # Detect pattern type
    local pattern_type=$(detect_pattern_type "$query")
    
    # Suggest number of assistants
    suggested=$(suggest_assistant_count "$query")
    
    # Adjust suggestion based on pattern
    case "$pattern_type" in
        "scientific"|"policy"|"product")
            if [ $suggested -lt 5 ]; then
                suggested=5
            fi
            ;;
        "historical")
            suggested=4
            ;;
    esac
    
    echo -e "\n${YELLOW}Detected pattern: ${pattern_type}${NC}"
    echo -e "${YELLOW}Based on your query, I suggest using $suggested research assistants.${NC}"
    echo -e "How many would you like to use? (2-8, or press Enter for $suggested)"
    read -r -p "> " num_assistants
    
    # Use suggestion if empty
    if [ -z "$num_assistants" ]; then
        num_assistants=$suggested
    fi
    
    # Validate input
    if ! [[ "$num_assistants" =~ ^[2-8]$ ]]; then
        echo -e "${RED}Invalid number. Using $suggested assistants.${NC}"
        num_assistants=$suggested
    fi
    
    # Get output format
    echo -e "\n${GREEN}Output format?${NC} (markdown/text, or press Enter for markdown)"
    read -r -p "> " format
    
    if [ -z "$format" ]; then
        format="markdown"
    fi
    
    # Ask about dangerous permissions
    echo -e "\n${YELLOW}Use --dangerously-skip-permissions flag?${NC}"
    echo -e "${RED}Warning: This bypasses security checks. Only use if you trust the research.${NC}"
    echo -e "Enable dangerous mode? (y/N)"
    read -r -p "> " dangerous_mode
    
    DANGEROUS_MODE="false"
    if [[ "$dangerous_mode" =~ ^[Yy]$ ]]; then
        DANGEROUS_MODE="true"
    fi
    
    # Confirm settings (default Y)
    echo -e "\n${BLUE}Ready to start research with:${NC}"
    echo -e "  📝 Query: $query"
    echo -e "  👥 Assistants: $num_assistants"
    echo -e "  📄 Format: $format"
    echo -e "  ⚠️  Dangerous mode: $DANGEROUS_MODE"
    echo -e "\n${GREEN}Proceed? (Y/n)${NC}"
    read -r -p "> " confirm
    
    # Default to yes if empty or starts with y/Y
    if [[ -z "$confirm" || "$confirm" =~ ^[Yy] ]]; then
        # Continue
        :
    else
        echo -e "${YELLOW}Cancelled.${NC}"
        exit 0
    fi
    
    # Set globals for main execution
    QUERY="$query"
    NUM_ASSISTANTS="$num_assistants"
    OUTPUT_FORMAT="$format"
    PATTERN_TYPE="$pattern_type"
}

# Main script starts here
DANGEROUS_MODE="false"
PATTERN_TYPE="default"

if [ $# -eq 0 ]; then
    # No arguments - run interactive mode
    interactive_mode
else
    # Command line mode
    QUERY="$1"
    NUM_ASSISTANTS="${2:-4}"
    OUTPUT_FORMAT="${3:-markdown}"
    
    # Detect pattern type
    PATTERN_TYPE=$(detect_pattern_type "$QUERY")
    
    # Validate assistants
    if ! [[ "$NUM_ASSISTANTS" =~ ^[2-8]$ ]]; then
        echo -e "${RED}Error: Number of assistants must be between 2 and 8${NC}"
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
echo "╔════════════════════════════════════════╗"
echo "║   Claude Code Heavy Research System    ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${YELLOW}Query:${NC} $QUERY"
echo -e "${YELLOW}Pattern:${NC} $PATTERN_TYPE"
echo -e "${YELLOW}Research Assistants:${NC} $ASSISTANT_COUNT"
echo -e "${YELLOW}Output:${NC} $OUTPUT_DIR"
echo

# Generate research questions
echo -e "${BLUE}══ Generating Research Questions ══${NC}"
echo

# Load pattern-based questions
load_pattern "$PATTERN_TYPE" "$ASSISTANT_COUNT"

# Display the research plan
echo -e "${GREEN}Research Plan Created!${NC}"
echo
for i in $(seq 0 $((ASSISTANT_COUNT - 1))); do
    echo -e "${CYAN}RA$((i+1)) - ${ROLES[$i]}${NC}"
    echo "Question: ${QUESTIONS[$i]}"
    echo
done

# Edit questions if interactive
if [ $# -eq 0 ]; then
    edit_questions
fi

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

You are coordinating a parallel research team using the **$PATTERN_TYPE** pattern.

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
2. Have them research their question using \`web_search\` and other tools
3. **Use parallel tool calls when possible** to speed up research
4. Save findings to their output file
5. After all complete, synthesize into \`$OUTPUT_DIR/final-analysis.md\`

## Research Guidelines
- Use web_search extensively for current information
- **Execute multiple searches in parallel** when researching different aspects
- Focus on recent, credible sources
- Document all sources with proper citations
- Stay focused on assigned angle
- Work in parallel (switch between RAs frequently)
- Each RA should produce 500-1000 words of findings

## Synthesis Requirements
The final analysis should:
- Integrate findings from all assistants
- Highlight key insights and patterns
- Address the original query comprehensively
- Include a executive summary at the beginning
- Cite which RA provided each piece of information

Start the research!
EOF
else
    # Text format
    PROMPT_FILE="$OUTPUT_DIR/coordination-prompt.txt"
    EXT="txt"
    cat > "$PROMPT_FILE" << EOF
Research Coordination: $QUERY
Pattern: $PATTERN_TYPE

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
3. USE PARALLEL TOOL CALLS when possible
4. Save findings to output files
5. Synthesize into $OUTPUT_DIR/final-analysis.md

Start the research!
EOF
fi

# Display completion and offer to launch (default Y)
echo
echo -e "${GREEN}✅ Setup complete!${NC}"
echo
echo -e "${BLUE}Would you like to launch Claude Code with the prompt? (Y/n)${NC}"
read -r -p "> " launch

# Default to yes if empty or starts with y/Y
if [[ -z "$launch" || "$launch" =~ ^[Yy] ]]; then
    echo -e "${YELLOW}Launching Claude Code...${NC}"
    echo -e "${GREEN}Research will begin automatically!${NC}"
    
    # Build launch command
    LAUNCH_CMD="claude"
    if [ "$DANGEROUS_MODE" = "true" ]; then
        LAUNCH_CMD="$LAUNCH_CMD --dangerously-skip-permissions"
    fi
    LAUNCH_CMD="$LAUNCH_CMD --chat"
    
    # Launch Claude with the prompt pre-filled
    # Try different Claude command variations
    if command -v claude &> /dev/null; then
        # Try with our built command
        $LAUNCH_CMD "$(cat "$PROMPT_FILE")" 2>/dev/null || \
        claude "$(cat "$PROMPT_FILE")" 2>/dev/null || \
        {
            echo -e "${YELLOW}Note: Could not auto-launch Claude Code. Please run manually:${NC}"
            if [ "$DANGEROUS_MODE" = "true" ]; then
                echo -e "${GREEN}claude --dangerously-skip-permissions${NC}"
            else
                echo -e "${GREEN}claude${NC}"
            fi
            echo -e "Then paste the prompt from: ${BLUE}$PROMPT_FILE${NC}"
        }
    else
        echo -e "${RED}Claude command not found. Please ensure Claude Code is installed.${NC}"
        echo -e "${YELLOW}Manual instructions:${NC}"
        echo -e "1. Open Claude Code"
        if [ "$DANGEROUS_MODE" = "true" ]; then
            echo -e "   with: claude --dangerously-skip-permissions"
        fi
        echo -e "2. Paste the prompt from: ${BLUE}$PROMPT_FILE${NC}"
    fi
else
    echo
    echo -e "${CYAN}══ Manual Launch Instructions ══${NC}"
    echo
    echo -e "${YELLOW}To start:${NC}"
    echo
    if [ "$DANGEROUS_MODE" = "true" ]; then
        echo "1. Run: ${GREEN}claude --dangerously-skip-permissions${NC}"
    else
        echo "1. Run: ${GREEN}claude${NC}"
    fi
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
