# Execution Strategy

**n8n Content Distribution System**

Real-time polling architecture with smart caching, minimal executions, and polished content delivery.

---

## Core Execution Philosophy

**Goals**:
- Listen for new content in real-time (feels instant)
- Minimize workflow executions (cost-efficient)
- Avoid checking for content constantly (resource-efficient)
- Deliver polished, sophisticated content (brand-appropriate)

**Solution**: Smart polling with timestamp-based caching

---

## Polling Architecture

### Real-Time Polling Design

**Cron Schedule**: Every 30 minutes
```
*/30 * * * *
```

**Why 30 Minutes?**
- Feels real-time for most content (news cycles are 1-3 hours)
- Balances responsiveness with execution efficiency
- Most RSS feeds update hourly or less frequently
- Sufficient for social media posting cadence

**Execution Flow**:
```
[30-min Cron Trigger]
    ↓
[Load Last-Seen Timestamps from Airtable]
    ↓
[Fetch 33 RSS Feeds in Parallel] (5-10 seconds)
    ↓
[Filter: Only articles published AFTER last-seen timestamp]
    ↓
IF no new content → STOP (zero further execution)
IF new content → Continue
    ↓
[AI Analysis on NEW articles only]
    ↓
[Store in Airtable + Update Last-Seen timestamp]
    ↓
[Route to Brands & Distribute]
```

### Smart Caching Mechanism

**Last-Seen Timestamp Storage**:
- Airtable table: `Feed_Status`
- Columns:
  - `feed_url` (primary key)
  - `last_seen_timestamp` (ISO 8601 datetime)
  - `last_checked` (ISO 8601 datetime)
  - `status` (active/inactive)
  - `error_count` (for monitoring)

**Caching Logic**:
```javascript
// At start of workflow
const lastSeen = await airtable.getLastSeenTimestamp(feedUrl);

// Fetch RSS feed
const articles = await fetchRSSFeed(feedUrl);

// Filter for NEW content only
const newArticles = articles.filter(article =>
  new Date(article.pubDate) > new Date(lastSeen)
);

// If zero new articles, skip this feed entirely
if (newArticles.length === 0) {
  return; // No execution needed
}

// Process new articles, then update timestamp
await processArticles(newArticles);
await airtable.updateLastSeenTimestamp(feedUrl, mostRecentPubDate);
```

### Execution Efficiency

**Worst Case** (all feeds have new content):
- 33 feeds × 5 new articles each = 165 articles
- AI analysis: ~30 seconds for batch processing
- Distribution: ~10 seconds
- Total: ~1 minute execution time
- Cost: ~500 n8n execution credits

**Average Case** (10-20% feeds have new content):
- 3-6 feeds × 2 new articles each = 6-12 articles
- AI analysis: ~5 seconds
- Distribution: ~5 seconds
- Total: ~15 seconds execution time
- Cost: ~100 n8n execution credits

**Best Case** (no new content):
- Timestamp check only
- Zero articles processed
- Total: ~5 seconds execution time
- Cost: ~10 n8n execution credits

**Daily Execution Cost**:
- 48 executions per day (every 30 minutes)
- Average: ~100 credits × 48 = 4,800 credits/day
- Monthly: ~144,000 credits (~$0.00 for self-hosted n8n)

---

## Content Processing Pipeline

### Stage 1: RSS Feed Fetching (Parallel)

**Parallel Execution**:
- 33 feeds fetched simultaneously
- Timeout: 10 seconds per feed
- Retry: 2 attempts with exponential backoff
- Error handling: Skip failed feeds, log errors

**Performance**:
- 33 parallel HTTP requests complete in ~5-10 seconds
- Failed feeds don't block successful ones
- Errors logged to Airtable for monitoring

### Stage 2: Content Filtering

**Timestamp Filter**:
- Only articles published AFTER last-seen timestamp
- Prevents duplicate processing
- Zero-cost for unchanged feeds

**Quality Pre-Filter** (before AI analysis):
- Minimum content length: 100 characters
- Valid URL required
- Not older than 7 days (safety check)
- Title must exist

**Result**: Typically 80-90% reduction in articles before AI analysis

### Stage 3: AI Analysis (Batch Processing)

**Batch Configuration**:
- Process up to 10 articles per AI call
- Structured JSON prompt for consistent output
- Temperature: 0.2 (deterministic)
- Model: GPT-4o-mini (fast, cost-effective)

**AI Prompt Structure**:
```json
{
  "task": "Analyze and score the following articles",
  "articles": [
    {
      "id": 1,
      "title": "...",
      "content": "...",
      "source": "..."
    }
  ],
  "output_format": {
    "article_id": "number",
    "quality_score": "1-5",
    "category": "string",
    "key_insights": "array",
    "brand_fit": "Intent Solutions | StartAITools | DixieRoad | None"
  }
}
```

**Expected Response Time**:
- 1-5 articles: ~3 seconds
- 6-10 articles: ~8 seconds
- 10+ articles: Split into multiple batches

### Stage 4: Content Storage

**Airtable Write Operations**:
- Bulk insert for new articles (single API call)
- Update last-seen timestamp (single API call)
- Update feed status (single API call)

**Data Structure**:
```
Articles Table:
- article_id (auto-generated)
- title
- url (unique)
- source_feed
- pub_date (ISO 8601)
- quality_score (1-5)
- category
- brand_assignment
- content_summary
- distribution_status (pending/distributed/skipped)
- created_at (auto)
```

### Stage 5: Distribution Routing

**Quality-Based Routing**:
```
IF quality_score >= 4:
  → Social media (LinkedIn, X)
  → Discord (high-value notifications)
  → Website
  → Slack

IF quality_score == 3:
  → Website only
  → Slack (team review)

IF quality_score < 3:
  → Archive in Airtable
  → No distribution
```

**Brand-Based Routing**:
```
IF brand_assignment == "Intent Solutions":
  → LinkedIn Company Page
  → X (@IntentSolutions)
  → Discord #tech-news
  → Slack #content-pipeline

IF brand_assignment == "StartAITools":
  → StartAITools.com (GitHub push)
  → Discord #tech-news
  → Slack #content-pipeline

IF brand_assignment == "DixieRoad":
  → DixieRoad.org
  → X (@DixieRoad)
  → Discord #repair-survival
  → Slack #content-pipeline
```

### Stage 6: Platform Distribution

**Parallel Distribution** (non-blocking):
- All platform posts happen simultaneously
- Webhook-based (fast, async)
- Retry logic for failed posts
- Error tracking in Airtable

**Platform-Specific Formatting**:

**LinkedIn** (professional tone):
```
{title}

{2-3 sentence summary highlighting key insight}

Read more: {url}

#{relevant} #{hashtags} #{here}
```

**X/Twitter** (casual, engaging):
```
{attention-grabbing insight}

{url}

#{hashtag1} #{hashtag2}
```

**Discord** (community-focused):
```
**{title}**

{brief summary}

Quality Score: {score}/5
Category: {category}

{url}
```

**Slack** (internal monitoring):
```
New Content: {title}
Source: {source_feed}
Score: {score}/5
Brand: {brand_assignment}
Status: {distributed_to_platforms}

{url}
```

**Website** (full blog post):
```markdown
---
title: "{title}"
date: {pub_date}
categories: ["{category}"]
tags: ["{auto_generated_tags}"]
source: "{source_feed}"
source_url: "{url}"
---

{content_summary}

[Read original article]({url})
```

---

## Rate Limiting & Throttling

### Platform Rate Limits

**LinkedIn Company Pages**:
- Limit: 1 post per 3 hours (unofficial guideline)
- Implementation: Queue posts, space 3+ hours apart
- Fallback: Skip if queue full, alert via Slack

**X/Twitter**:
- Limit: 300 posts per 3 hours (per account)
- Implementation: Track post count in Airtable
- Fallback: Queue excess posts for next cycle

**Discord**:
- Limit: 50 messages per 10 seconds per channel
- Implementation: Batch notifications, 1-second delays
- Fallback: None needed (low volume)

**Slack**:
- Limit: 1 message per second (recommended)
- Implementation: Queue messages with 1-second spacing
- Fallback: None needed (internal only)

**GitHub API**:
- Limit: 5,000 requests per hour (authenticated)
- Implementation: Single commit per content batch
- Fallback: Queue commits if limit approached

### Throttling Strategy

**Peak Hours** (9 AM - 5 PM ET, Tue-Thu):
- Prioritize high-quality content (score 4-5)
- Space social media posts 2-3 hours apart
- Batch website updates once per hour

**Off-Peak Hours** (evenings, weekends):
- More frequent social posts allowed
- Lower quality threshold (score 3+)
- Real-time website updates

---

## Content Formatting Standards

### Professional & Sophisticated Tone

**Intent Solutions (Company Voice)**:
```
Example LinkedIn Post:

AI model efficiency has reached a critical inflection point.

New research from Google DeepMind demonstrates 40% reduction in inference
costs while maintaining accuracy—a game-changer for enterprise AI adoption.

This shift enables smaller companies to deploy sophisticated AI solutions
without massive infrastructure investments.

Read the full research: [url]

#AIInnovation #EnterpriseAI #TechLeadership
```

**Characteristics**:
- Lead with insight, not headline
- 2-3 sentence summary (concise, valuable)
- Business implications highlighted
- Professional hashtags (3-5 max)
- No clickbait, no hype

### Casual & Minimalistic Tone

**StartAITools (Developer Voice)**:
```
Example Blog Post Intro:

Deploying LLMs to production is tricky. Here's what we learned building
DiagnosticPro's AI diagnostic engine:

1. Model selection matters more than prompt engineering
2. Caching saves 80% on API costs
3. Fallback strategies are non-negotiable

Let's break down each lesson with code examples...
```

**Characteristics**:
- Direct, conversational tone
- Numbered lists for clarity
- Real-world examples
- No fluff, straight to value

### Practical & Straightforward Tone

**DixieRoad (Community Voice)**:
```
Example X Post:

Quick tip: Check your generator oil BEFORE you need it in an emergency.

5W-30 is universal, keep 2 quarts on hand.

#Prepping #Homestead
```

**Characteristics**:
- Actionable advice immediately
- No jargon, plain language
- Community-oriented
- Practical, field-tested

---

## Monitoring & Alerts

### Real-Time Monitoring

**Discord Alerts**:
- Feed fetch failures (after 3 retries)
- AI analysis errors
- Distribution failures (per platform)
- Daily execution summary

**Slack Notifications**:
- All content processed (team visibility)
- Quality score trends (weekly)
- System health status (daily)
- Manual review queue (as needed)

### Performance Metrics

**Daily Execution Report** (Slack, 6 PM ET):
```
Content Distribution Summary - {date}

Executions: 48 total (1 per 30 min)
New Articles: 35 processed
Quality Breakdown:
  - Score 5: 3 articles (8.6%)
  - Score 4: 12 articles (34.3%)
  - Score 3: 15 articles (42.9%)
  - Score 2: 5 articles (14.3%)

Distribution:
  - LinkedIn: 15 posts
  - X: 25 posts
  - Discord: 35 notifications
  - Websites: 30 articles

Errors: 2 feed fetch failures (Family Handyman, TechCrunch)

View full report: [Airtable link]
```

### Error Handling

**Feed Failures**:
1. Retry with exponential backoff (3 attempts)
2. If still failing, mark feed as "degraded"
3. Alert via Discord if critical feed
4. Continue with successful feeds

**AI Analysis Failures**:
1. Retry once with simplified prompt
2. If still failing, assign default score (3)
3. Flag for manual review
4. Log error details to Airtable

**Distribution Failures**:
1. Queue failed posts for retry (up to 3 attempts)
2. Alert via Slack if critical platform
3. Continue with successful platforms
4. Log failure for analysis

---

## Deployment Checklist

**Before First Run**:
- [ ] Test all 33 RSS feed URLs
- [ ] Configure Airtable base with all tables
- [ ] Set up API credentials (OpenRouter, LinkedIn, X, etc.)
- [ ] Initialize last-seen timestamps (set to current time)
- [ ] Test AI analysis with sample articles
- [ ] Test distribution to each platform
- [ ] Configure Discord/Slack webhooks
- [ ] Set up monitoring alerts
- [ ] Create backup/rollback plan

**After First Run**:
- [ ] Verify articles processed correctly
- [ ] Check quality score distribution
- [ ] Confirm distribution to all platforms
- [ ] Review formatting on each platform
- [ ] Monitor execution time and costs
- [ ] Adjust thresholds if needed

---

## Future Optimizations

**Phase 2 Enhancements**:
- Webhook-based RSS updates (Superfeedr integration)
- Image generation for social posts (DALL-E 3)
- Engagement tracking per platform
- A/B testing for post formats
- Predictive quality scoring (ML model)

**Phase 3 Enhancements**:
- Multi-language support
- Video content distribution
- Automated response to comments
- Influencer outreach automation
- Advanced analytics dashboard

---

**Last Updated**: 2025-10-03
**Status**: Planning Phase
**Version**: 1.0
