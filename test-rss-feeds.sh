#!/bin/bash

# RSS Feed Validation Script
# Tests all proposed tier-1 feeds for n8n content distribution system

echo "========================================="
echo "RSS FEED VALIDATION TEST"
echo "Testing 33 tier-1 feeds..."
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

echo "=== AI RESEARCH & INDUSTRY ==="
test_feed "OpenAI News" "https://openai.com/news/rss.xml" && ((pass++)) || ((fail++))
test_feed "Google AI Blog" "https://ai.googleblog.com/feeds/posts/default" && ((pass++)) || ((fail++))
test_feed "DeepMind Blog" "https://deepmind.com/blog/feed/basic/" && ((pass++)) || ((fail++))
test_feed "Hugging Face Blog" "https://huggingface.co/blog/feed.xml" && ((pass++)) || ((fail++))
test_feed "Machine Learning Mastery" "https://machinelearningmastery.com/feed/" && ((pass++)) || ((fail++))
test_feed "The Gradient" "https://thegradient.pub/rss/" && ((pass++)) || ((fail++))
test_feed "Papers with Code" "https://paperswithcode.com/rss.xml" && ((pass++)) || ((fail++))
echo ""

echo "=== TECH NEWS ==="
test_feed "TechCrunch" "https://techcrunch.com/feed/" && ((pass++)) || ((fail++))
test_feed "The Verge" "https://www.theverge.com/rss/index.xml" && ((pass++)) || ((fail++))
test_feed "Ars Technica" "https://feeds.arstechnica.com/arstechnica/index" && ((pass++)) || ((fail++))
test_feed "Wired" "https://www.wired.com/feed/rss" && ((pass++)) || ((fail++))
test_feed "VentureBeat AI" "https://venturebeat.com/ai/feed/" && ((pass++)) || ((fail++))
test_feed "MIT Tech Review" "https://www.technologyreview.com/feed/" && ((pass++)) || ((fail++))
test_feed "IEEE Spectrum" "https://spectrum.ieee.org/rss/fulltext" && ((pass++)) || ((fail++))
echo ""

echo "=== HOME REPAIR & DIY ==="
test_feed "Family Handyman" "https://www.familyhandyman.com/feed/" && ((pass++)) || ((fail++))
test_feed "This Old House" "https://www.thisoldhouse.com/rss/all" && ((pass++)) || ((fail++))
test_feed "Bob Vila" "https://www.bobvila.com/feed/" && ((pass++)) || ((fail++))
echo ""

echo "=== AUTOMOTIVE ==="
test_feed "Motor Trend" "https://www.motortrend.com/feed/" && ((pass++)) || ((fail++))
test_feed "Car and Driver" "https://www.caranddriver.com/rss/all.xml/" && ((pass++)) || ((fail++))
echo ""

echo "=== SURVIVAL & PREPPING ==="
test_feed "The Prepper Journal" "https://www.theprepperjournal.com/feed/" && ((pass++)) || ((fail++))
test_feed "Backdoor Survival" "https://www.backdoorsurvival.com/feed/" && ((pass++)) || ((fail++))
test_feed "Survival Blog" "https://survivalblog.com/feed/" && ((pass++)) || ((fail++))
test_feed "Urban Survival Site" "https://urbansurvivalsite.com/feed/" && ((pass++)) || ((fail++))
echo ""

echo "=== HOMESTEADING ==="
test_feed "The Prairie Homestead" "https://www.theprairiehomestead.com/feed" && ((pass++)) || ((fail++))
test_feed "Homesteading.com" "https://www.homesteading.com/feed/" && ((pass++)) || ((fail++))
test_feed "Modern Homesteading" "https://www.modernhomesteading.com/feed/" && ((pass++)) || ((fail++))
echo ""

echo "=== FIREARMS & SHOOTING ==="
test_feed "The Truth About Guns" "https://www.thetruthaboutguns.com/feed/" && ((pass++)) || ((fail++))
test_feed "Guns & Ammo" "https://www.gunsandammo.com/feed/" && ((pass++)) || ((fail++))
test_feed "Shooting Illustrated" "https://www.shootingillustrated.com/rss" && ((pass++)) || ((fail++))
test_feed "The Firearm Blog" "https://www.thefirearmblog.com/blog/feed/" && ((pass++)) || ((fail++))
echo ""

echo "=== HUNTING & OUTDOORS ==="
test_feed "Field & Stream" "https://www.fieldandstream.com/feed/" && ((pass++)) || ((fail++))
test_feed "Outdoor Life" "https://www.outdoorlife.com/feed/" && ((pass++)) || ((fail++))
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
    echo "⚠️  Some feeds failed - review and update RSS-FEEDS.md"
    exit 1
fi
