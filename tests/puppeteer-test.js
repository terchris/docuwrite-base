/**
 * Puppeteer Integration Tests
 * 
 * File: tests/puppeteer-test.js
 * 
 * Purpose:
 * Validates Puppeteer functionality in the docuwrite-base container environment
 * using Firefox with WebDriver BiDi protocol. Tests include page navigation,
 * screenshot capture, PDF generation, and DOM manipulation.
 * 
 * This script is part of the integration test suite for docuwrite-base and is 
 * used to verify that the Puppeteer browser automation is working correctly with
 * Firefox in the container environment.
 * 
 * Environment Variables Required:
 * - PUPPETEER_CONFIG: Path to Puppeteer configuration file with Firefox settings
 * 
 * Output Files Generated:
 * - puppeteer-example-screenshot.png: Full page screenshot of example.com
 * - puppeteer-example-page.pdf: PDF export of example.com
 * - puppeteer-test-page.pdf: PDF export of test page
 * 
 * Test Coverage:
 * 1. Browser launch with Firefox BiDi
 * 2. Page creation and viewport manipulation
 * 3. Basic HTML rendering
 * 4. DOM manipulation
 * 5. External website navigation
 * 6. Content extraction
 * 7. Screenshot capture
 * 8. PDF generation
 * 9. Performance metrics (if supported)
 * 
 * Requirements:
 * - puppeteer-core must be installed
 * - Firefox Nightly must be installed and configured
 * - Write permissions to output directory
 * 
 * Usage:
 * NODE_PATH=/usr/local/app/node_modules \
 * PUPPETEER_CONFIG=/usr/local/etc/puppeteer-config.json \
 * node puppeteer-test.js
 */

const puppeteer = require('puppeteer-core');
const fs = require('fs');

// Verify required environment variable
if (!process.env.PUPPETEER_CONFIG) {
    console.error('ERROR: PUPPETEER_CONFIG environment variable not set');
    process.exit(1);
}

// Load Puppeteer configuration from environment-specified path
const PUPPETEER_CONFIG = JSON.parse(
    fs.readFileSync(process.env.PUPPETEER_CONFIG, 'utf8')
);

console.log(`Using Puppeteer config from: ${process.env.PUPPETEER_CONFIG}`);

/**
 * Main test execution function
 * Runs a series of tests to validate Puppeteer functionality
 * @returns {Promise<void>}
 */
async function runTests() {
    let browser;
    try {
        console.log('=== Running Puppeteer Tests ===\n');
        
        // Launch browser with BiDi configuration
        browser = await puppeteer.launch(PUPPETEER_CONFIG);
        console.log('✓ Browser launched successfully with config from PUPPETEER_CONFIG');
        
        // Test 1: Basic page creation
        const page = await browser.newPage();
        console.log('✓ New page created');

        // Test 2: Viewport manipulation
        await page.setViewport({ width: 1200, height: 800 });
        console.log('✓ Viewport manipulation successful');

        // Test 3: Basic HTML rendering
        await page.goto('data:text/html,<h1>Test Page</h1>');
        console.log('✓ Basic page navigation successful');

        // Test 4: DOM manipulation and content extraction
        const heading = await page.evaluate(() => document.querySelector('h1').textContent);
        if (heading !== 'Test Page') {
            throw new Error('DOM manipulation test failed');
        }
        console.log('✓ DOM manipulation successful');

        // Test 5: External website navigation
        await page.goto('http://example.com');
        console.log('✓ Navigated to example.com');

        // Test 6: Content extraction
        const exampleData = await page.evaluate(() => ({
            title: document.title,
            heading: document.querySelector('h1')?.textContent,
            paragraphText: document.querySelector('p')?.textContent
        }));

        console.log('\nExample.com Content:');
        console.log('- Title:', exampleData.title);
        console.log('- Heading:', exampleData.heading);
        console.log('- First Paragraph:', exampleData.paragraphText);

        // Test 7: Screenshot capture
        await page.screenshot({
            path: '/usr/local/tests/puppeteer-example-screenshot.png',
            fullPage: true
        });
        console.log('✓ Example.com screenshot captured');

        // Test 8: PDF generation of external site
        await page.pdf({
            path: '/usr/local/tests/puppeteer-example-page.pdf',
            format: 'A4'
        });
        console.log('✓ Example.com PDF generated');

        // Test 9: PDF generation of simple test page
        await page.goto('data:text/html,<h1>Test PDF Generation</h1><p>This is a test page for PDF generation.</p>');
        await page.pdf({
            path: '/usr/local/tests/puppeteer-test-page.pdf',
            format: 'A4'
        });
        console.log('✓ Test page PDF generation successful');

        // Test 10: Performance metrics collection (optional)
        try {
            const metrics = await page.metrics();
            console.log('\nPerformance Metrics:');
            console.log(`- JS Heap Size: ${Math.round(metrics.JSHeapUsedSize / 1024 / 1024)}MB`);
            console.log(`- DOM Nodes: ${metrics.Nodes}`);
            console.log(`- Scripts: ${metrics.Scripts}`);
        } catch (metricsError) {
            console.log('\nNote: Performance metrics collection not supported');
        }

        // Cleanup: Close browser
        await browser.close();
        console.log('\n✓ Browser closed successfully');
        console.log('\n=== All Puppeteer tests completed successfully ===');
        process.exit(0);
        
    } catch (error) {
        // Error handling: Log error and ensure browser is closed
        console.error('\nERROR:', error.message);
        if (browser) {
            await browser.close().catch(console.error);
        }
        process.exit(1);
    }
}

// Execute tests with unhandled error catching
runTests().catch(error => {
    console.error('Unhandled error:', error);
    process.exit(1);
});