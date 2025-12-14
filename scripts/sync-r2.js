import fs from 'fs';
import { execSync } from 'child_process';

// Configuration
const BUCKET_BINDING = 'eva-quotes';

const FILES = [
    { key: 'insults.json', localPath: 'assets/insults.json' },
    { key: 'community.json', localPath: 'assets/community.json' }
];

function mergeData(localPath, tempPath) {
    let localData = [];
    let cloudData = [];
    let hasChanges = false;

    // Load Local
    if (fs.existsSync(localPath)) {
        try {
            localData = JSON.parse(fs.readFileSync(localPath, 'utf8'));
        } catch (e) {
            console.warn(`[WARN] Failed to parse local ${localPath}, starting empty.`);
        }
    }

    // Load Cloud (Temp)
    if (fs.existsSync(tempPath)) {
        try {
            cloudData = JSON.parse(fs.readFileSync(tempPath, 'utf8'));
        } catch (e) {
            console.warn(`[WARN] Failed to parse cloud data from ${tempPath}.`);
        }
    }

    // Merge (Deduplicate strings)
    // Assuming these are arrays of strings based on insults.json context
    const mergedSet = new Set([...localData, ...cloudData]);
    const mergedArray = Array.from(mergedSet);

    if (mergedArray.length !== localData.length || JSON.stringify(mergedArray) !== JSON.stringify(localData)) {
        console.log(`[MERGE] Merged ${cloudData.length} cloud items with ${localData.length} local items. Total: ${mergedArray.length}`);
        fs.writeFileSync(localPath, JSON.stringify(mergedArray, null, 2), 'utf8');
        return true;
    } else {
        console.log(`[SKIP] No changes detected for ${localPath}.`);
        return false;
    }
}

async function run() {
    console.log("========================================");
    console.log("      EVA SYSTEM: DATA SYNC START       ");
    console.log("========================================");

    if (!fs.existsSync('assets')) fs.mkdirSync('assets');

    for (const file of FILES) {
        const tempFile = `temp_${file.key}`;
        console.log(`\nProcessing: ${file.key}`);

        // 1. Download from R2
        try {
            console.log(`[DOWN] Fetching from R2...`);
            // Creates temp file
            execSync(`npx wrangler r2 object get eva-quotes/${file.key} --file=${tempFile}`, { stdio: 'ignore' });
        } catch (e) {
            console.log(`[INFO] Could not fetch ${file.key} (might not exist yet).`);
        }

        // 2. Merge & Write Local
        const updated = mergeData(file.localPath, tempFile);

        // 3. Upload back to R2 (if updated or just to ensure consistency)
        try {
            console.log(`[UP] Uploading merged data to R2...`);
            execSync(`npx wrangler r2 object put eva-quotes/${file.key} --file=${file.localPath}`, { stdio: 'inherit' });
        } catch (e) {
            console.error(`[ERR] Failed to upload ${file.key}.`);
        }

        // Cleanup
        if (fs.existsSync(tempFile)) fs.unlinkSync(tempFile);
    }

    console.log("\n========================================");
    console.log("       DATA SYNC COMPLETE               ");
    console.log("========================================");
}

run();
