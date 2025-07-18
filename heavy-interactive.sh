#!/bin/bash
# heavy-interactive.sh - Interactive Claude Code Heavy orchestrator
# Uses Head Researcher and Research Assistants terminology

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
DEFAULT_ASSISTANTS=4
QUERY="$1"
ASSISTANT_COUNT="${2:-$DEFAULT_ASSISTANTS}"
OUTPUT_DIR="./outputs/$(date +%Y%m%d_%H%M%S)"

# Validate input
if [ -z "$QUERY" ]; then
    echo -e "${RED}Error: No query provided${NC}"
    echo "Usage: $0 \"Your research question\" [number_of_assistants]"
    echo "Example: $0 \"Who is Pietro Schirano?\" 4"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/assistants"

# Banner
echo -e "${CYAN}"
echo "╔═══════════════════════════════════════╗"
echo "║   Claude Code Heavy Research System   ║"
echo "║      Head Researcher & Assistants     ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${YELLOW}Query:${NC} $QUERY"
echo -e "${YELLOW}Research Assistants:${NC} $ASSISTANT_COUNT"
echo -e "${YELLOW}Output:${NC} $OUTPUT_DIR"
echo

# Create research plan
echo -e "${BLUE}══ Creating Research Plan ══${NC}"
echo

cat > "$OUTPUT_DIR/research-plan.md" << EOF
# Research Plan: $QUERY

## Objective
Conduct comprehensive multi-perspective research on: "$QUERY"

## Research Team
- **Head Researcher**: Generates questions and synthesizes findings
- **Research Assistants**: $ASSISTANT_COUNT parallel researchers

## Research Questions

### Assistant 1 - Factual Research
Focus on gathering direct, factual information about the subject. Who, what, when, where.

### Assistant 2 - Analysis & Impact
Analyze significance, contributions, metrics, and measurable impact.

### Assistant 3 - Critical Perspective
Look for alternative viewpoints, criticisms, limitations, and controversies.

### Assistant 4 - Verification & Context
Verify claims, check sources, provide historical context and current status.

## Instructions for Research Assistants

1. Use web_search extensively
2. Verify information from multiple sources
3. Document all sources
4. Be thorough but focused
5. Save findings to: $OUTPUT_DIR/assistants/assistant-N-findings.md

## Expected Output Format

Each assistant should produce:
- Summary of findings
- Detailed evidence
- List of sources
- Key insights
EOF

echo -e "${GREEN}✓ Research plan created${NC}"
echo
# Create Head Researcher prompt
cat > "$OUTPUT_DIR/head-researcher-prompt.md" << EOF
# Head Researcher Instructions

You are the Head Researcher coordinating a team investigating: "$QUERY"

## Phase 1: Question Generation

Based on the query, generate $ASSISTANT_COUNT specialized research questions that together provide comprehensive coverage. Each question should approach from a different angle.

Example format:
- Assistant 1: [Specific factual research question]
- Assistant 2: [Specific analytical question]
- Assistant 3: [Specific critical perspective question]
- Assistant 4: [Specific verification question]

## Phase 2: Synthesis

After assistants complete their research, you will:
1. Read all findings from $OUTPUT_DIR/assistants/
2. Synthesize into comprehensive analysis
3. Highlight agreements and contradictions
4. Provide nuanced, multi-faceted understanding

Save your initial questions to: $OUTPUT_DIR/research-questions.md
Save your final synthesis to: $OUTPUT_DIR/final-analysis.md
EOF

# Create assistant instruction template
create_assistant_prompt() {
    local ASSISTANT_NUM=$1
    local FOCUS=$2
    
    cat > "$OUTPUT_DIR/assistant-$ASSISTANT_NUM-prompt.md" << EOF
# Research Assistant $ASSISTANT_NUM Instructions

You are Research Assistant $ASSISTANT_NUM investigating: "$QUERY"

## Your Focus: $FOCUS

## Your Tasks:
1. Use web_search to gather comprehensive information
2. Verify claims with multiple sources
3. Look for specific examples and evidence
4. Document all sources used
5. Be thorough but stay focused on your angle

## Output Format:
Save your findings to: $OUTPUT_DIR/assistants/assistant-$ASSISTANT_NUM-findings.md

Structure your report as:
# Research Assistant $ASSISTANT_NUM Findings

## Focus Area
$FOCUS

## Key Findings
[Detailed findings with evidence]

## Sources Used
[List all sources with URLs]

## Summary
[Concise summary of your discoveries]
EOF
}

# Create prompts for each assistant type
create_assistant_prompt 1 "Factual Information - Who, what, when, where, direct facts"
create_assistant_prompt 2 "Analysis & Impact - Significance, contributions, metrics"
create_assistant_prompt 3 "Critical Perspective - Alternative views, limitations, controversies"
create_assistant_prompt 4 "Verification & Context - Fact-checking, sources, current status"

echo -e "${GREEN}✓ Prompts created for Head Researcher and Assistants${NC}"
echo

# Create launch instructions
cat > "$OUTPUT_DIR/launch-instructions.md" << EOF
# Launch Instructions

## Step 1: Head Researcher (You in Claude Desktop)
1. Read the research plan: $OUTPUT_DIR/research-plan.md
2. Generate specialized questions for each assistant
3. Save to: $OUTPUT_DIR/research-questions.md

## Step 2: Research Assistants (Open $ASSISTANT_COUNT terminals)

For each assistant, run:

### Assistant 1
\`\`\`bash
cd $(pwd)
claude --no-conversation-file
# Then paste the contents of: $OUTPUT_DIR/assistant-1-prompt.md
\`\`\`

### Assistant 2
\`\`\`bash
cd $(pwd)
claude --no-conversation-file
# Then paste the contents of: $OUTPUT_DIR/assistant-2-prompt.md
\`\`\`

### Assistant 3
\`\`\`bash
cd $(pwd)
claude --no-conversation-file
# Then paste the contents of: $OUTPUT_DIR/assistant-3-prompt.md
\`\`\`

### Assistant 4
\`\`\`bash
cd $(pwd)
claude --no-conversation-file
# Then paste the contents: $OUTPUT_DIR/assistant-4-prompt.md
\`\`\`

## Step 3: Synthesis (Back to Head Researcher)
Once all assistants complete:
1. Read all findings from $OUTPUT_DIR/assistants/
2. Create comprehensive synthesis
3. Save to: $OUTPUT_DIR/final-analysis.md
EOF

# Display next steps
echo -e "${CYAN}══ Research System Ready ══${NC}"
echo
echo -e "${YELLOW}Next Steps:${NC}"
echo
echo "1. ${BLUE}As Head Researcher:${NC}"
echo "   - Review: $OUTPUT_DIR/research-plan.md"
echo "   - Generate specific questions for each assistant"
echo "   - Save to: $OUTPUT_DIR/research-questions.md"
echo
echo "2. ${BLUE}Launch Research Assistants:${NC}"
echo "   - Open $ASSISTANT_COUNT terminal windows"
echo "   - In each, run: claude --no-conversation-file"
echo "   - Paste the respective assistant prompt"
echo
echo "3. ${BLUE}Final Synthesis:${NC}"
echo "   - Once assistants complete, synthesize all findings"
echo "   - Create final analysis"
echo
echo -e "${GREEN}All prompts and instructions saved to:${NC}"
echo "$OUTPUT_DIR/"
echo
echo -e "${CYAN}Tip: For detailed launch commands, see:${NC}"
echo "$OUTPUT_DIR/launch-instructions.md"
