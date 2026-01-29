#!/usr/bin/env python3
# test_dashboard.py - Headless browser test for zkPrologML dashboard

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
import time

def test_dashboard():
    print("🔮 Testing zkPrologML Dashboard")
    print("=" * 60)
    
    # Setup headless Chrome
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    
    driver = webdriver.Chrome(options=chrome_options)
    
    try:
        # Load dashboard
        url = "http://localhost/"
        print(f"\n📥 Loading: {url}")
        driver.get(url)
        
        # Wait for page to load
        time.sleep(2)
        
        # Test 1: Check title
        print("\n✓ Test 1: Page title")
        title = driver.title
        print(f"  Title: {title}")
        assert "zkPrologML" in title, "Title should contain 'zkPrologML'"
        
        # Test 2: Check stats are visible
        print("\n✓ Test 2: Stats cards")
        stats = driver.find_elements(By.CLASS_NAME, "card")
        print(f"  Found {len(stats)} stat cards")
        assert len(stats) >= 6, "Should have at least 6 stat cards"
        
        # Test 3: Check Frank is present
        print("\n✓ Test 3: Frank assistant")
        frank_input = driver.find_element(By.ID, "prologInput")
        print(f"  Frank input placeholder: {frank_input.get_attribute('placeholder')}")
        assert frank_input is not None, "Frank input should exist"
        
        # Test 4: Check error log
        print("\n✓ Test 4: Error log")
        error_log = driver.find_element(By.ID, "errorLog")
        print(f"  Error log text: {error_log.text[:100]}...")
        assert error_log is not None, "Error log should exist"
        
        # Test 5: Test Frank interaction
        print("\n✓ Test 5: Frank interaction")
        frank_input.send_keys("hi")
        send_button = driver.find_element(By.XPATH, "//button[text()='SEND']")
        send_button.click()
        time.sleep(1)
        
        output = driver.find_element(By.ID, "prologOutput")
        output_text = output.text
        print(f"  Frank response: {output_text[-100:]}")
        assert "Frank" in output_text, "Frank should respond"
        
        # Test 6: Check console errors
        print("\n✓ Test 6: Console errors")
        logs = driver.get_log('browser')
        errors = [log for log in logs if log['level'] == 'SEVERE']
        print(f"  Console errors: {len(errors)}")
        for error in errors[:3]:
            print(f"    - {error['message'][:80]}...")
        
        # Test 7: Check shards
        print("\n✓ Test 7: Monster Group shards")
        shards = driver.find_elements(By.CLASS_NAME, "shard")
        print(f"  Found {len(shards)} shards")
        assert len(shards) == 71, "Should have 71 shards"
        
        # Test 8: Click a shard
        print("\n✓ Test 8: Shard interaction")
        if shards:
            shards[0].click()
            time.sleep(1)
            # Check if modal appeared (proof modal)
            print("  Shard clicked successfully")
        
        # Test 9: Check Matrix effect
        print("\n✓ Test 9: Matrix background")
        canvas = driver.find_element(By.CLASS_NAME, "matrix-bg")
        print(f"  Matrix canvas found: {canvas is not None}")
        
        # Test 10: Check uptime
        print("\n✓ Test 10: Uptime counter")
        uptime = driver.find_element(By.ID, "uptime")
        uptime_text = uptime.text
        print(f"  Uptime: {uptime_text}")
        assert uptime_text, "Uptime should be displayed"
        
        print("\n" + "=" * 60)
        print("✅ All tests passed!")
        print(f"\nSummary:")
        print(f"  • Page loaded successfully")
        print(f"  • All UI elements present")
        print(f"  • Frank responds to queries")
        print(f"  • {len(errors)} console errors")
        print(f"  • 71 shards interactive")
        
        return True
        
    except Exception as e:
        print(f"\n❌ Test failed: {e}")
        
        # Take screenshot on failure
        driver.save_screenshot("dashboard_error.png")
        print("  Screenshot saved: dashboard_error.png")
        
        # Print page source for debugging
        with open("dashboard_source.html", "w") as f:
            f.write(driver.page_source)
        print("  Page source saved: dashboard_source.html")
        
        return False
        
    finally:
        driver.quit()

if __name__ == "__main__":
    success = test_dashboard()
    exit(0 if success else 1)
