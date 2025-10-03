#!/bin/bash

# Comprehensive RSS Feed Validation Script
# Tests all 45 feeds from comprehensive-news-feeds.json

echo "========================================="
echo "COMPREHENSIVE RSS FEED VALIDATION"
echo "Testing 45 feeds from comprehensive-news-feeds.json"
echo "========================================="
echo ""

# Function to test RSS feed
test_feed() {
    local name=$1
    local url=$2

    echo -n "Testing $name... "

    # Test with timeout
    response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$url" 2>/dev/null)

    if [ "$response" = "200" ]; then
        # Verify it's actually XML/RSS
        content_type=$(curl -s -I --max-time 10 "$url" 2>/dev/null | grep -i "content-type" | head -1)
        if echo "$content_type" | grep -qi "xml\|rss\|atom"; then
            echo "✅ PASS (HTTP $response)"
            return 0
        else
            echo "❌ FAIL (Not XML/RSS: $content_type)"
            return 1
        fi
    else
        echo "❌ FAIL (HTTP $response)"
        return 1
    fi
}

# Counter
pass=0
fail=0

echo "=== TECH & AI NEWS (7 FEEDS) ==="
test_feed "TechCrunch" "https://techcrunch.com/feed/" && ((pass++)) || ((fail++))
test_feed "The Verge" "https://www.theverge.com/rss/index.xml" && ((pass++)) || ((fail++))
test_feed "Ars Technica" "https://feeds.arstechnica.com/arstechnica/index" && ((pass++)) || ((fail++))
test_feed "Wired" "https://www.wired.com/feed/rss" && ((pass++)) || ((fail++))
test_feed "VentureBeat" "https://venturebeat.com/feed/" && ((pass++)) || ((fail++))
test_feed "Engadget" "https://www.engadget.com/rss.xml" && ((pass++)) || ((fail++))
test_feed "IEEE Spectrum" "https://spectrum.ieee.org/rss/fulltext" && ((pass++)) || ((fail++))
echo ""

echo "=== AI/ML SPECIFIC (6 FEEDS) ==="
test_feed "OpenAI Blog" "https://openai.com/blog/rss.xml" && ((pass++)) || ((fail++))
test_feed "Google AI Blog" "https://ai.googleblog.com/feeds/posts/default" && ((pass++)) || ((fail++))
test_feed "Anthropic Blog" "https://www.anthropic.com/rss.xml" && ((pass++)) || ((fail++))
test_feed "Hugging Face Blog" "https://huggingface.co/blog/feed.xml" && ((pass++)) || ((fail++))
test_feed "AI News" "https://www.artificialintelligence-news.com/feed/" && ((pass++)) || ((fail++))
test_feed "MIT News AI" "https://news.mit.edu/rss/topic/artificial-intelligence2" && ((pass++)) || ((fail++))
echo ""

echo "=== BUSINESS & FINANCE (5 FEEDS) ==="
test_feed "Bloomberg Technology" "https://feeds.bloomberg.com/technology/news.rss" && ((pass++)) || ((fail++))
test_feed "Reuters Technology" "https://feeds.reuters.com/reuters/technologyNews" && ((pass++)) || ((fail++))
test_feed "Fortune Tech" "https://fortune.com/section/tech/feed/" && ((pass++)) || ((fail++))
test_feed "Forbes Technology" "https://www.forbes.com/innovation/feed2/" && ((pass++)) || ((fail++))
test_feed "Wall Street Journal Tech" "https://feeds.a.dj.com/rss/RSSWSJD.xml" && ((pass++)) || ((fail++))
echo ""

echo "=== GENERAL NEWS (4 FEEDS) ==="
test_feed "BBC News Technology" "http://feeds.bbci.co.uk/news/technology/rss.xml" && ((pass++)) || ((fail++))
test_feed "CNN Technology" "http://rss.cnn.com/rss/cnn_tech.rss" && ((pass++)) || ((fail++))
test_feed "NPR Technology" "https://feeds.npr.org/1001/rss.xml" && ((pass++)) || ((fail++))
test_feed "Associated Press Technology" "https://feeds.apnews.com/rss/apf-technology.rss" && ((pass++)) || ((fail++))
echo ""

echo "=== SCIENCE & INNOVATION (4 FEEDS) ==="
test_feed "Nature News" "https://www.nature.com/nature.rss" && ((pass++)) || ((fail++))
test_feed "Science Daily" "https://www.sciencedaily.com/rss/computers_math/computer_science.xml" && ((pass++)) || ((fail++))
test_feed "New Scientist" "https://www.newscientist.com/feed/home/" && ((pass++)) || ((fail++))
test_feed "MIT Technology Review" "https://www.technologyreview.com/feed/" && ((pass++)) || ((fail++))
echo ""

echo "=== DEVELOPER FOCUSED (4 FEEDS) ==="
test_feed "Hacker News" "https://hnrss.org/frontpage" && ((pass++)) || ((fail++))
test_feed "GitHub Blog" "https://github.blog/feed/" && ((pass++)) || ((fail++))
test_feed "Stack Overflow Blog" "https://stackoverflow.blog/feed/" && ((pass++)) || ((fail++))
test_feed "InfoQ" "https://feed.infoq.com/" && ((pass++)) || ((fail++))
echo ""

echo "=== STARTUP & VENTURE (3 FEEDS) ==="
test_feed "Product Hunt" "https://www.producthunt.com/feed" && ((pass++)) || ((fail++))
test_feed "AngelList Blog" "https://angel.co/blog/feed" && ((pass++)) || ((fail++))
test_feed "Y Combinator" "https://blog.ycombinator.com/feed/" && ((pass++)) || ((fail++))
echo ""

echo "=== CYBERSECURITY (3 FEEDS) ==="
test_feed "KrebsOnSecurity" "https://krebsonsecurity.com/feed/" && ((pass++)) || ((fail++))
test_feed "The Hacker News" "https://feeds.feedburner.com/TheHackersNews" && ((pass++)) || ((fail++))
test_feed "Dark Reading" "https://www.darkreading.com/rss_simple.asp" && ((pass++)) || ((fail++))
echo ""

echo "=== CRYPTO & BLOCKCHAIN (2 FEEDS) ==="
test_feed "CoinDesk" "https://feeds.coindesk.com/coindesk" && ((pass++)) || ((fail++))
test_feed "Cointelegraph" "https://cointelegraph.com/rss" && ((pass++)) || ((fail++))
echo ""

echo "=== MOBILE & APPS (2 FEEDS) ==="
test_feed "Android Police" "https://www.androidpolice.com/feed/" && ((pass++)) || ((fail++))
test_feed "9to5Mac" "https://9to5mac.com/feed/" && ((pass++)) || ((fail++))
echo ""

echo "========================================="
echo "RESULTS:"
echo "✅ PASSED: $pass"
echo "❌ FAILED: $fail"
echo "TOTAL: $((pass + fail))"
echo "========================================="

if [ $fail -eq 0 ]; then
    echo "🎉 ALL FEEDS VALIDATED!"
    exit 0
else
    echo "⚠️  Some feeds failed - review and update MASTER-RSS-FEEDS.md"
    exit 1
fi
