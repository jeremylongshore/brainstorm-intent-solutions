#!/bin/bash

# Repair & Maintenance RSS Feed Validation
# Tests RV, Motorcycle, Boat, Car, Truck repair feeds

echo "========================================="
echo "REPAIR & MAINTENANCE FEED VALIDATION"
echo "Testing RV, Motorcycle, Boat, Car, Truck feeds"
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

echo "=== RV REPAIR & MAINTENANCE (5 FEEDS) ==="
test_feed "RV Travel" "https://www.rvtravel.com/feed/" && ((pass++)) || ((fail++))
test_feed "RV Life" "https://rvlife.com/feed/" && ((pass++)) || ((fail++))
test_feed "Do It Yourself RV" "https://www.doityourselfrv.com/feed/" && ((pass++)) || ((fail++))
test_feed "RV Repair Club" "https://www.rvrepairclub.com/feed/" && ((pass++)) || ((fail++))
test_feed "Camper Report" "https://camperreport.com/feed/" && ((pass++)) || ((fail++))
echo ""

echo "=== MOTORCYCLE REPAIR & MAINTENANCE (5 FEEDS) ==="
test_feed "Cycle World" "https://www.cycleworld.com/feed/" && ((pass++)) || ((fail++))
test_feed "Motorcyclist" "https://www.motorcyclistonline.com/feed/" && ((pass++)) || ((fail++))
test_feed "RevZilla Common Tread" "https://www.revzilla.com/common-tread/rss" && ((pass++)) || ((fail++))
test_feed "Motorcycle News" "https://www.motorcyclenews.com/feed/" && ((pass++)) || ((fail++))
test_feed "Sport Rider" "https://www.sportrider.com/feed/" && ((pass++)) || ((fail++))
echo ""

echo "=== BOAT REPAIR & MAINTENANCE (5 FEEDS) ==="
test_feed "Boating Magazine" "https://www.boatingmag.com/feed/" && ((pass++)) || ((fail++))
test_feed "Boats.com" "https://www.boats.com/feed/" && ((pass++)) || ((fail++))
test_feed "Sail Magazine" "https://www.sailmagazine.com/feed/" && ((pass++)) || ((fail++))
test_feed "PassageMaker" "https://www.passagemaker.com/feed/" && ((pass++)) || ((fail++))
test_feed "BoatUS Magazine" "https://www.boatus.com/magazine/feed/" && ((pass++)) || ((fail++))
echo ""

echo "=== CAR REPAIR & MAINTENANCE (Already in master - testing for completeness) ==="
test_feed "Car and Driver" "https://www.caranddriver.com/rss/all.xml/" && ((pass++)) || ((fail++))
test_feed "Road & Track" "https://www.roadandtrack.com/rss/all.xml/" && ((pass++)) || ((fail++))
test_feed "Jalopnik" "https://jalopnik.com/rss" && ((pass++)) || ((fail++))
test_feed "The Drive" "https://www.thedrive.com/feeds/all" && ((pass++)) || ((fail++))
test_feed "Autoblog" "https://www.autoblog.com/rss.xml" && ((pass++)) || ((fail++))
echo ""

echo "=== TRUCK REPAIR & MAINTENANCE (5 FEEDS) ==="
test_feed "Truck Trend" "https://www.trucktrend.com/feed/" && ((pass++)) || ((fail++))
test_feed "MotorTrend Trucks" "https://www.motortrend.com/trucks/feed/" && ((pass++)) || ((fail++))
test_feed "Pickup Truck News" "https://www.pickuptrucks.com/feed/" && ((pass++)) || ((fail++))
test_feed "Diesel World" "https://www.dieselworldmag.com/feed/" && ((pass++)) || ((fail++))
test_feed "The Fast Lane Truck" "https://www.tfltruck.com/feed/" && ((pass++)) || ((fail++))
echo ""

echo "=== GENERAL AUTO REPAIR & DIY (5 FEEDS) ==="
test_feed "YourMechanic" "https://www.yourmechanic.com/article/feed" && ((pass++)) || ((fail++))
test_feed "RepairPal" "https://repairpal.com/blog/feed" && ((pass++)) || ((fail++))
test_feed "The Car Connection" "https://www.thecarconnection.com/news/feed" && ((pass++)) || ((fail++))
test_feed "Auto Service World" "https://www.autoserviceworld.com/feed/" && ((pass++)) || ((fail++))
test_feed "Popular Mechanics Auto" "https://www.popularmechanics.com/cars/feed/" && ((pass++)) || ((fail++))
echo ""

echo "========================================="
echo "RESULTS:"
echo "✅ PASSED: $pass"
echo "❌ FAILED: $fail"
echo "TOTAL: $((pass + fail))"
echo "========================================="

if [ $fail -eq 0 ]; then
    echo "🎉 ALL REPAIR FEEDS VALIDATED!"
    exit 0
else
    echo "⚠️  Some feeds failed - review and update MASTER-RSS-FEEDS.md"
    exit 1
fi
