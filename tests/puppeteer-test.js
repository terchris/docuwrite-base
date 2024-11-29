/**
 * Puppeteer Integration Tests
 * 
 * File: /usr/local/tests/puppeteer-test.js
 * 
 * Purpose:
 * Validates Puppeteer functionality in the DocuWrite container environment
 * by running a series of tests to verify browser automation capabilities.
 * Tests include page navigation, screenshot capture, PDF generation, and
 * DOM manipulation.
 * 
 * Output Files (all saved in /usr/local/tests/):
 * - puppeteer-example-screenshot.png: Full page screenshot of example.com
 * - puppeteer-example-page.pdf: PDF export of example.com
 * - puppeteer-test-page.pdf: PDF export of a simple test page
 * 
 * Requirements:
 * - Puppeteer must be installed in /usr/local/app/node_modules
 * - Chrome/Chromium must be installed
 * - Write permissions to /usr/local/tests/
 * 
 * Environment Variables Required:
 * - PUPPETEER_CONFIG: Path to Puppeteer configuration file
 * - NODE_PATH: Must include /usr/local/app/node_modules
 * 
 * Usage:
 * NODE_PATH=/usr/local/app/node_modules \
 * PUPPETEER_CONFIG=/usr/local/etc/puppeteer-config.json \
 * node /usr/local/tests/puppeteer-test.js
 * 
 * Exit Codes:
 * 0 - All tests passed
 * 1 - Test failure (error message will be displayed)
 */

const puppeteer = require('puppeteer');
const fs = require('fs');

if (!process.env.PUPPETEER_CONFIG) {
    console.error('ERROR: PUPPETEER_CONFIG environment variable not set');
    process.exit(1);
}

// Load Puppeteer configuration from the same file used by test-install.sh
const PUPPETEER_CONFIG = JSON.parse(
    fs.readFileSync(process.env.PUPPETEER_CONFIG, 'utf8')
);

console.log(`Using Puppeteer config from: ${process.env.PUPPETEER_CONFIG}`);

/**
 * Main test execution function that runs all Puppeteer integration tests
 * @returns {Promise<void>}
 */
async function runTests() {
    console.log('=== Running Puppeteer Tests ===\n');
    
    try {
        // Launch browser using configuration from PUPPETEER_CONFIG
        const browser = await puppeteer.launch({
            ...PUPPETEER_CONFIG,
            executablePath: process.env.PUPPETEER_EXECUTABLE_PATH || undefined
        });

        console.log('✓ Browser launched successfully with config from PUPPETEER_CONFIG');
        
        // Basic page creation test
        const page = await browser.newPage();
        console.log('✓ New page created');

        // Test viewport manipulation - sets a standard desktop resolution
        await page.setViewport({ width: 1200, height: 800 });
        console.log('✓ Viewport manipulation successful');

        // Test simple HTML page navigation and rendering
        await page.goto('data:text/html,<h1>Test Page</h1>');
        console.log('✓ Basic page navigation successful');

        // Verify DOM manipulation capabilities
        const heading = await page.evaluate(() => document.querySelector('h1').textContent);
        if (heading !== 'Test Page') {
            throw new Error('DOM manipulation test failed');
        }
        console.log('✓ DOM manipulation successful');

        // Test external website navigation and content extraction
        await page.goto('http://example.com');
        console.log('✓ Navigated to example.com');

        // Extract key content from example.com
        const exampleData = await page.evaluate(() => ({
            title: document.title,
            heading: document.querySelector('h1')?.textContent,
            paragraphText: document.querySelector('p')?.textContent
        }));

        console.log('\nExample.com Content:');
        console.log('- Title:', exampleData.title);
        console.log('- Heading:', exampleData.heading);
        console.log('- First Paragraph:', exampleData.paragraphText);

        // Test screenshot functionality
        await page.screenshot({
            path: '/usr/local/tests/puppeteer-example-screenshot.png',
            fullPage: true
        });
        console.log('✓ Example.com screenshot captured');

        // Test PDF generation of external website
        await page.pdf({
            path: '/usr/local/tests/puppeteer-example-page.pdf',
            format: 'A4'
        });
        console.log('✓ Example.com PDF generated');

        // Test PDF generation of simple test page
        await page.goto('data:text/html,<h1>Test PDF Generation</h1><p>This is a test page for PDF generation.</p>');
        await page.pdf({
            path: '/usr/local/tests/puppeteer-test-page.pdf',
            format: 'A4'
        });
        console.log('✓ Test page PDF generation successful');

        // Collect and display performance metrics
        const metrics = await page.metrics();
        console.log('\nPerformance Metrics:');
        console.log(`- JS Heap Size: ${Math.round(metrics.JSHeapUsedSize / 1024 / 1024)}MB`);
        console.log(`- DOM Nodes: ${metrics.Nodes}`);
        console.log(`- Scripts: ${metrics.Scripts}`);

        await browser.close();
        console.log('\n✓ Browser closed successfully');
        console.log('\n=== All Puppeteer tests completed successfully ===');
        
    } catch (error) {
        console.error('\nERROR:', error.message);
        process.exit(1);
    }
}

// Execute the tests
runTests();