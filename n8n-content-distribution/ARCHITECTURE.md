# System Architecture

**n8n Content Distribution System**

Scalable, multi-brand content automation platform with intelligent routing and real-time distribution.

---

## Overview

A sophisticated content pipeline that monitors premium RSS feeds, analyzes content quality using AI, and distributes curated content across multiple brands, platforms, and channels with minimal manual intervention.

---

## System Components

### 1. Content Ingestion Layer

**RSS Feed Monitoring**
- 20+ tier-1 RSS feeds across tech and lifestyle categories
- Real-time polling every 30 minutes
- Smart caching to detect only NEW content
- Timestamp-based duplicate detection

**Feed Categories**:
- AI Research & Industry (OpenAI, Anthropic, Google AI, Hugging Face)
- Tech News (TechCrunch, Ars Technica, The Verge, Wired)
- Repair & Maintenance (DIY, home improvement, automotive)
- Survival & Homesteading (prepping, self-sufficiency, rural living)
- Guns & Ammo (firearms, hunting, shooting sports)

### 2. AI Analysis Layer

**Content Scoring Engine**
- Model: GPT-4o-mini (OpenRouter)
- Temperature: 0.2 (consistent, deterministic output)
- Quality scoring: 1-5 scale
- Topic extraction & categorization
- Sentiment analysis
- Entity recognition

**Quality Criteria**:
- Relevance to brand focus areas
- Content depth and technical accuracy
- Timeliness and newsworthiness
- Audience value and actionability
- Source credibility

### 3. Content Storage Layer

**Primary Storage: Airtable**
- Separate base for content distribution (independent from existing news pipeline)
- Tables:
  - `Articles` - All ingested content with metadata
  - `Distribution_Log` - Track what was posted where
  - `RSS_Sources` - Feed management and status
  - `Quality_Scores` - Historical scoring data

**Data Schema**:
```
Articles Table:
- article_id (primary key)
- title
- url
- source_feed
- pub_date
- quality_score (1-5)
- category
- brand_assignment
- content_summary
- extracted_entities
- distribution_status
```

### 4. Brand Routing Engine

**Intelligent Content Routing**

Content flows to appropriate brands based on:
- Category match (tech → StartAITools, survival → DixieRoad)
- Quality score threshold (4+ for social media)
- Brand voice alignment
- Audience relevance

**Routing Logic**:
```
IF category = "AI" OR "Tech" OR "Development"
  → Intent Solutions (company authority)
  → StartAITools (detailed content)

IF category = "Repair" OR "Maintenance" OR "DIY"
  → DixieRoad

IF category = "Survival" OR "Homesteading" OR "Guns"
  → DixieRoad

IF quality_score >= 4
  → Social media (LinkedIn, X)
  → Discord notifications

ALL content
  → Website publishing
  → Slack team notifications
```

### 5. Distribution Layer

**Multi-Channel Publishing**

**LinkedIn Company Pages**:
- Intent Solutions official page
- Professional tone, industry insights
- High-value content only (score 4+)
- Rate limit: 1 post per 3 hours

**X (Twitter)**:
- Intent Solutions company account
- DixieRoad niche account (separate)
- Casual, engaging tone
- Rate limit: 3-5 posts per day

**Discord**:
- Tech channel (StartAITools content)
- Repair channel (DixieRoad content)
- Real-time notifications for team
- No rate limits

**Slack**:
- Internal team monitoring
- All content fed to #content-pipeline channel
- Digest format with quality scores

**Websites**:
- StartAITools.com (Hugo blog, Netlify)
- DixieRoad.org (format TBD)
- GitHub push → auto-deploy via Netlify

### 6. Execution & Scheduling

**Real-Time Polling Architecture**

n8n Cron Trigger: `*/30 * * * *` (every 30 minutes)

**Workflow Execution**:
```
1. Check RSS feeds for new content (30 parallel requests)
2. Compare pub_date against last_seen timestamp
3. Only process articles published in last 30 minutes
4. Run AI analysis on new articles
5. Store in Airtable with quality scores
6. Route to appropriate brand channels
7. Distribute to selected platforms
8. Update distribution log
9. Cache latest timestamp for next run
```

**Efficiency Optimizations**:
- Parallel RSS fetching (30 feeds in ~5 seconds)
- Conditional execution (skip if no new content)
- Batch processing for AI analysis
- Async webhook calls for social platforms

---

## Data Flow Diagram

```
[RSS Feeds] → [30-min Polling] → [New Content Detection]
                                          ↓
                                  [AI Analysis Layer]
                                  (Quality Score 1-5)
                                          ↓
                                  [Airtable Storage]
                                          ↓
                                  [Brand Router]
                                    /     |     \
                                   /      |      \
                    [Intent Solutions] [StartAITools] [DixieRoad]
                           |              |              |
                    ---------------  ---------------  ---------------
                    LinkedIn         LinkedIn(opt)    LinkedIn(opt)
                    X                Slack            X (separate)
                    Discord          StartAITools.com Discord
                    Slack                             DixieRoad.org
```

---

## Technology Stack

**Workflow Automation**: n8n (self-hosted)
**AI Analysis**: OpenRouter (GPT-4o-mini)
**Data Storage**: Airtable (cloud)
**Version Control**: Git (brainstorm-intent-solutions repo)
**Hosting**:
- n8n: Local/VPS Docker container
- Websites: Netlify (Hugo static sites)

**APIs & Integrations**:
- Airtable API (data CRUD)
- OpenRouter API (AI analysis)
- LinkedIn API (company page posting)
- X API v2 (tweet posting)
- Discord Webhooks (notifications)
- Slack Webhooks (team alerts)
- GitHub API (content commits)

---

## Scalability Considerations

**Horizontal Scaling**:
- Add new RSS feeds without workflow changes
- Add new brands with routing rules
- Add new distribution channels modularly

**Performance Optimization**:
- Parallel processing for RSS fetching
- Caching layer for duplicate detection
- Batch AI processing (up to 10 articles per call)
- Async webhook distribution

**Cost Management**:
- Self-hosted n8n (no per-execution fees)
- OpenRouter (pay per token, ~$0.10 per 1M tokens)
- Airtable free tier (1,200 records per base)
- Netlify free tier (100GB bandwidth)

**Monitoring**:
- n8n execution logs
- Airtable distribution status field
- Discord error notifications
- Weekly digest reports via email

---

## Security & Compliance

**API Key Management**:
- All credentials stored in n8n encrypted credentials
- Environment variables for sensitive data
- No hardcoded secrets in workflows

**Data Privacy**:
- RSS feeds are public data
- No PII collection
- Content attribution to original sources
- Compliance with platform ToS (LinkedIn, X)

**Rate Limiting**:
- Respect platform rate limits
- Built-in delays between posts
- Exponential backoff on API errors

---

## Edge Cases & Error Handling

**RSS Feed Failures**:
- Skip failed feeds, continue with successful ones
- Log errors to Airtable for review
- Discord notification for critical failures

**AI Analysis Failures**:
- Fallback to basic categorization
- Flag for manual review
- Retry with exponential backoff

**Distribution Failures**:
- Queue failed posts for retry
- Manual approval workflow for critical content
- Error logs in Slack #alerts channel

**Duplicate Content**:
- URL-based deduplication
- Title similarity check (fuzzy matching)
- Cross-brand duplicate detection

---

## Future Enhancements

**Phase 2**:
- Multi-language support
- Image generation for social posts
- A/B testing for post formats
- Engagement analytics dashboard

**Phase 3**:
- Custom AI models for brand voice
- Automated response to comments
- Influencer outreach automation
- SEO optimization for blog posts

---

**Last Updated**: 2025-10-03
**Status**: Planning Phase
**Version**: 1.0
