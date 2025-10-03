# n8n Workflow Mermaid Diagram Template

**Purpose**: Visual template for documenting n8n workflows based on analysis of Daily Energizer and News Pipeline workflows.

---

## Analysis Summary

### Daily Energizer Workflow
- **Nodes**: 143 total
- **Pattern**: Multi-stage content generation pipeline
- **Key Stages**:
  1. RSS Collection (10 positive news feeds)
  2. Date Filtering (48-hour freshness check)
  3. Deduplication (remove duplicate titles)
  4. AI Story Selection (GPT-4o-mini scoring, temperature 0)
  5. Article Generation (full 650-750 word article)
  6. Summary Generation (200-word summary)
  7. Image Generation (Google Drive integration)
  8. Google Sheets Storage (final output)

### News Pipeline Workflow
- **Nodes**: 21 total
- **Pattern**: Multi-source aggregation with AI analysis
- **Key Stages**:
  1. Schedule Trigger (daily 8:01 AM)
  2. Airtable Topics Load (dynamic topic keywords)
  3. Parallel RSS Fetching (12 tech/AI sources)
  4. Article Merging (combine all sources)
  5. AI Analysis (GPT-4o-mini categorization)
  6. Airtable Storage (structured output)

---

## Common n8n Workflow Patterns

### Pattern 1: RSS Aggregation Pipeline
```
Trigger → Parallel RSS Fetching → Merge → Filter → Process → Store
```

### Pattern 2: AI Content Generation
```
Source Data → AI Analysis → AI Generation → Post-Processing → Distribution
```

### Pattern 3: Multi-Stage Quality Control
```
Input → Filter 1 (Date) → Filter 2 (Dedup) → AI Scoring → Verification → Output
```

### Pattern 4: Parallel Processing + Merge
```
Trigger
  ├→ Source 1 ┐
  ├→ Source 2 ├→ Merge → Process
  └→ Source 3 ┘
```

---

## Mermaid Diagram Template: Content Distribution Workflow

### Full System Architecture

\`\`\`mermaid
graph TB
    %% Styling
    classDef trigger fill:#e1f5ff,stroke:#01579b,stroke-width:2px
    classDef rss fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef filter fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef ai fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px
    classDef storage fill:#fce4ec,stroke:#880e4f,stroke-width:2px
    classDef distribute fill:#e0f2f1,stroke:#004d40,stroke-width:2px

    %% Trigger
    START[Cron Trigger<br/>Every 30 Minutes]:::trigger

    %% Data Loading
    START --> LOAD_TS[Load Last-Seen<br/>Timestamps<br/>Airtable]:::storage

    %% Parallel RSS Fetching
    LOAD_TS --> RSS1[TechCrunch RSS]:::rss
    LOAD_TS --> RSS2[The Verge RSS]:::rss
    LOAD_TS --> RSS3[OpenAI Blog RSS]:::rss
    LOAD_TS --> RSS4[Anthropic RSS]:::rss
    LOAD_TS --> RSS5[...]:::rss
    LOAD_TS --> RSS33[33 Total Feeds]:::rss

    %% Merge Articles
    RSS1 --> MERGE[Merge All Articles]:::filter
    RSS2 --> MERGE
    RSS3 --> MERGE
    RSS4 --> MERGE
    RSS5 --> MERGE
    RSS33 --> MERGE

    %% Timestamp Filtering
    MERGE --> FILTER_NEW{Filter New Content<br/>pubDate > last_seen}:::filter
    FILTER_NEW -->|No New Content| STOP1[Stop Workflow]:::filter
    FILTER_NEW -->|New Content Found| DEDUP[Remove Duplicates<br/>By URL/Title]:::filter

    %% AI Analysis
    DEDUP --> AI_SCORE[AI Quality Scoring<br/>GPT-4o-mini<br/>Temp: 0.2]:::ai
    AI_SCORE --> STORE_ART[Store Articles<br/>+ Scores<br/>Airtable]:::storage

    %% Update Timestamp
    STORE_ART --> UPDATE_TS[Update Last-Seen<br/>Timestamps]:::storage

    %% Brand Routing
    UPDATE_TS --> ROUTE{Route by<br/>Brand + Quality}:::filter

    %% Intent Solutions Branch
    ROUTE -->|AI/Tech<br/>Score 4+| IS_LINKEDIN[LinkedIn Post<br/>Intent Solutions]:::distribute
    IS_LINKEDIN --> IS_X[X Post<br/>@IntentSolutions]:::distribute
    IS_X --> IS_DISCORD[Discord Notification<br/>#tech-news]:::distribute

    %% StartAITools Branch
    ROUTE -->|AI/Tech<br/>Score 3+| SAT_GITHUB[GitHub Commit<br/>StartAITools.com]:::distribute
    SAT_GITHUB --> SAT_NETLIFY[Netlify Deploy<br/>Auto-Trigger]:::distribute

    %% DixieRoad Branch
    ROUTE -->|Repair/Survival<br/>Score 3+| DR_GITHUB[GitHub Commit<br/>DixieRoad.org]:::distribute
    DR_GITHUB --> DR_X[X Post<br/>@DixieRoad]:::distribute
    DR_X --> DR_DISCORD[Discord Notification<br/>#repair-survival]:::distribute

    %% All Content to Slack
    ROUTE --> SLACK[Slack Notification<br/>#content-pipeline<br/>All Content]:::distribute

    %% Log Distribution
    IS_DISCORD --> LOG[Update Distribution Log<br/>Airtable]:::storage
    SAT_NETLIFY --> LOG
    DR_DISCORD --> LOG
    SLACK --> LOG

    LOG --> END[Workflow Complete]:::trigger
\`\`\`

---

## Mermaid Diagram Template: Daily Energizer Pattern

\`\`\`mermaid
graph TB
    %% Styling
    classDef trigger fill:#e1f5ff,stroke:#01579b,stroke-width:2px
    classDef rss fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef filter fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef ai fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px
    classDef storage fill:#fce4ec,stroke:#880e4f,stroke-width:2px

    START[Manual Trigger]:::trigger

    %% RSS Collection
    START --> RSS1[Good News Network]:::rss
    START --> RSS2[Positive News UK]:::rss
    START --> RSS3[Sunny Skyz]:::rss
    START --> RSS10[10 Positive Feeds]:::rss

    %% Merge
    RSS1 --> MERGE[Merge Articles]:::filter
    RSS2 --> MERGE
    RSS3 --> MERGE
    RSS10 --> MERGE

    %% Date Filter
    MERGE --> DATE_FILTER{Date Filter<br/>< 48 Hours Old}:::filter
    DATE_FILTER -->|Too Old| REJECT1[Discard]:::filter
    DATE_FILTER -->|Fresh| DEDUP[Remove Duplicates<br/>By Title]:::filter

    %% AI Story Selection
    DEDUP --> AI_SELECT[AI Story Selection<br/>Score ALL Stories<br/>GPT-4o-mini Temp: 0]:::ai
    AI_SELECT --> VERIFY{Verification<br/>Story in Source List?}:::filter
    VERIFY -->|Failed| REJECT2[Halt Workflow]:::filter
    VERIFY -->|Passed| AI_ARTICLE[AI Article Generation<br/>650-750 Words<br/>GPT-4o-mini]:::ai

    %% Summary Generation
    AI_ARTICLE --> FORMAT[Format Article<br/>Ensure Final Line]:::filter
    FORMAT --> AI_SUMMARY[AI Summary Generation<br/>200 Words Max<br/>GPT-4o-mini]:::ai

    %% Image Generation
    AI_SUMMARY --> IMG_GEN[Generate Image<br/>Google Drive]:::storage
    IMG_GEN --> IMG_CONVERT[Convert URL<br/>Shareable to Direct]:::filter

    %% Google Sheets Storage
    IMG_CONVERT --> SHEETS_ADD[Add to Google Sheets<br/>Article + Image + Info]:::storage
    SHEETS_ADD --> SHEETS_GET[Get Row Number<br/>For Formula]:::storage

    SHEETS_GET --> END[Complete]:::trigger
\`\`\`

---

## Mermaid Diagram Template: News Pipeline Pattern

\`\`\`mermaid
graph TB
    %% Styling
    classDef trigger fill:#e1f5ff,stroke:#01579b,stroke-width:2px
    classDef rss fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef ai fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px
    classDef storage fill:#fce4ec,stroke:#880e4f,stroke-width:2px

    START[Schedule Trigger<br/>Daily 8:01 AM]:::trigger

    %% Topics Loading
    START --> TOPICS[Load Topics<br/>From Airtable<br/>Topics to Monitor]:::storage

    %% Parallel RSS Fetching
    TOPICS --> TC[TechCrunch]:::rss
    TOPICS --> TV[The Verge]:::rss
    TOPICS --> AT[Ars Technica]:::rss
    TOPICS --> VB[VentureBeat]:::rss
    TOPICS --> OAI[OpenAI Blog]:::rss
    TOPICS --> GAI[Google AI]:::rss
    TOPICS --> ANT[Anthropic]:::rss
    TOPICS --> HF[Hugging Face]:::rss
    TOPICS --> HN[Hacker News]:::rss
    TOPICS --> MIT[MIT Tech Review]:::rss
    TOPICS --> BT[Bloomberg Tech]:::rss
    TOPICS --> WIRED[Wired]:::rss

    %% Merge
    TC --> MERGE[Merge Articles<br/>From All Sources]:::rss
    TV --> MERGE
    AT --> MERGE
    VB --> MERGE
    OAI --> MERGE
    GAI --> MERGE
    ANT --> MERGE
    HF --> MERGE
    HN --> MERGE
    MIT --> MERGE
    BT --> MERGE
    WIRED --> MERGE

    %% AI Analysis
    MERGE --> AI_ANALYZE[AI Analysis<br/>GPT-4o-mini<br/>Temp: 0.2<br/>Topic Tags<br/>Significance Score<br/>Entity Extraction]:::ai

    %% Airtable Storage
    AI_ANALYZE --> AIRTABLE[Store in Airtable<br/>Articles Table<br/>25+ Metadata Fields]:::storage

    AIRTABLE --> END[Complete]:::trigger
\`\`\`

---

## Simplified Template for Quick Workflows

\`\`\`mermaid
graph LR
    A[Trigger] --> B[Input]
    B --> C[Process]
    C --> D[Output]

    style A fill:#e1f5ff,stroke:#01579b
    style B fill:#fff3e0,stroke:#e65100
    style C fill:#e8f5e9,stroke:#1b5e20
    style D fill:#fce4ec,stroke:#880e4f
\`\`\`

---

## Node Type Color Coding

Use these consistent colors for node types:

- **Triggers** (Cron, Manual, Webhook): Light Blue `#e1f5ff`
- **Data Sources** (RSS, HTTP, API): Light Orange `#fff3e0`
- **Filters** (Conditions, Dedup, Date): Light Purple `#f3e5f5`
- **AI Processing** (LLM, Analysis, Generation): Light Green `#e8f5e9`
- **Storage** (Airtable, Sheets, Database): Light Pink `#fce4ec`
- **Distribution** (Social, Email, Webhook): Light Teal `#e0f2f1`

---

## Key Insights from Workflow Analysis

### Daily Energizer (143 nodes)
**Strengths**:
- Comprehensive anti-hallucination system (4 layers)
- Multiple AI stages with verification
- Detailed quality control

**Pattern**: Linear pipeline with heavy AI processing
**Execution Time**: 2-4 minutes
**Complexity**: High (143 nodes for single article)

### News Pipeline (21 nodes)
**Strengths**:
- Efficient parallel processing (12 feeds)
- Single AI analysis stage
- Scalable architecture

**Pattern**: Fan-in (many sources → merge → process)
**Execution Time**: 2-3 minutes for 100-300 articles
**Complexity**: Medium (21 nodes for high volume)

### Content Distribution (Proposed)
**Design Goals**:
- Combine efficiency of News Pipeline
- Quality control from Daily Energizer
- Multi-brand routing logic
- Real-time polling with smart caching

**Pattern**: Hybrid (parallel fetch + merge + AI + multi-path distribution)
**Estimated Nodes**: 40-50
**Execution Time**: < 1 minute (with caching)
**Complexity**: Medium-High

---

## Usage Instructions

1. **Choose Template**: Select based on workflow type
2. **Copy Mermaid Code**: Use code block for your workflow
3. **Customize Nodes**: Replace placeholder names with actual nodes
4. **Update Colors**: Apply consistent color scheme
5. **Add Conditionals**: Use diamond shapes for decision points
6. **Document Flow**: Add notes for complex logic

---

## Rendering Mermaid Diagrams

**GitHub**: Automatically renders in markdown files
**VSCode**: Install "Markdown Preview Mermaid Support" extension
**Online**: https://mermaid.live/ for instant preview
**Documentation Sites**: Hugo, MkDocs, Docusaurus all support Mermaid

---

**Last Updated**: 2025-10-03
**Analysis Source**: Daily Energizer V4 (143 nodes), News Pipeline v2.1.1 (21 nodes)
**Version**: 1.0
