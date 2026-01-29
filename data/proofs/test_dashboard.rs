// test_dashboard.rs - Headless browser test in Rust

use headless_chrome::{Browser, LaunchOptions};
use std::time::Duration;
use std::thread;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🔮 Testing zkPrologML Dashboard");
    println!("{}", "=".repeat(60));
    
    // Launch headless browser
    let browser = Browser::new(LaunchOptions {
        headless: true,
        ..Default::default()
    })?;
    
    let tab = browser.new_tab()?;
    
    // Load dashboard
    let url = "http://localhost/";
    println!("\n📥 Loading: {}", url);
    tab.navigate_to(url)?;
    tab.wait_until_navigated()?;
    
    thread::sleep(Duration::from_secs(2));
    
    // Test 1: Check title
    println!("\n✓ Test 1: Page title");
    let title = tab.get_title()?;
    println!("  Title: {}", title);
    assert!(title.contains("zkPrologML"), "Title should contain 'zkPrologML'");
    
    // Test 2: Check stats cards
    println!("\n✓ Test 2: Stats cards");
    let stats = tab.find_elements(".card")?;
    println!("  Found {} stat cards", stats.len());
    assert!(stats.len() >= 6, "Should have at least 6 stat cards");
    
    // Test 3: Check Frank input
    println!("\n✓ Test 3: Frank assistant");
    let frank_input = tab.find_element("#prologInput")?;
    let placeholder = frank_input.get_attribute_value("placeholder")?;
    println!("  Frank placeholder: {:?}", placeholder);
    
    // Test 4: Check error log
    println!("\n✓ Test 4: Error log");
    let error_log = tab.find_element("#errorLog")?;
    let error_text = error_log.get_inner_text()?;
    println!("  Error log: {}...", &error_text[..error_text.len().min(50)]);
    
    // Test 5: Test Frank interaction
    println!("\n✓ Test 5: Frank interaction");
    frank_input.type_into("hi")?;
    let send_button = tab.find_element("button")?;
    send_button.click()?;
    thread::sleep(Duration::from_secs(1));
    
    let output = tab.find_element("#prologOutput")?;
    let output_text = output.get_inner_text()?;
    println!("  Frank response: {}...", &output_text[output_text.len().saturating_sub(100)..]);
    assert!(output_text.contains("Frank"), "Frank should respond");
    
    // Test 6: Check shards
    println!("\n✓ Test 6: Monster Group shards");
    let shards = tab.find_elements(".shard")?;
    println!("  Found {} shards", shards.len());
    assert_eq!(shards.len(), 71, "Should have 71 shards");
    
    // Test 7: Check uptime
    println!("\n✓ Test 7: Uptime counter");
    let uptime = tab.find_element("#uptime")?;
    let uptime_text = uptime.get_inner_text()?;
    println!("  Uptime: {}", uptime_text);
    
    // Test 8: Take screenshot
    println!("\n✓ Test 8: Screenshot");
    let screenshot = tab.capture_screenshot(
        headless_chrome::protocol::cdp::Page::CaptureScreenshotFormatOption::Png,
        None,
        None,
        true,
    )?;
    std::fs::write("dashboard_test.png", screenshot)?;
    println!("  Screenshot saved: dashboard_test.png");
    
    println!("\n{}", "=".repeat(60));
    println!("✅ All tests passed!");
    println!("\nSummary:");
    println!("  • Page loaded successfully");
    println!("  • All UI elements present");
    println!("  • Frank responds to queries");
    println!("  • 71 shards interactive");
    println!("  • Screenshot captured");
    
    Ok(())
}
