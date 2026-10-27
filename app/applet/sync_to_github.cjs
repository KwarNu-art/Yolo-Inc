const fs = require('fs');
const path = require('path');
const https = require('https');

const TOKEN = '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';
const OWNER = 'KwarNu-art';
const REPO = 'Yolo-Inc';
const BASE_DIR = '/app/applet/gcool';

function githubRequest(method, endpoint, body) {
  return new Promise((resolve, reject) => {
    const data = body ? JSON.stringify(body) : null;
    const req = https.request({
      hostname: 'api.github.com',
      port: 443,
      path: endpoint,
      method: method,
      headers: {
        'User-Agent': 'GCOOL-Sync-Agent',
        'Authorization': `token ${TOKEN}`,
        'Accept': 'application/vnd.github.v3+json',
        ...(data ? { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(data) } : {})
      }
    }, res => {
      let responseBody = '';
      res.on('data', chunk => responseBody += chunk);
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(JSON.parse(responseBody));
        } else {
          reject(new Error(`GitHub API error ${res.statusCode}: ${responseBody}`));
        }
      });
    });

    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

function getAllFiles(dirPath, arrayOfFiles = []) {
  const files = fs.readdirSync(dirPath);
  for (const file of files) {
    const fullPath = path.join(dirPath, file);
    if (fs.statSync(fullPath).isDirectory()) {
      getAllFiles(fullPath, arrayOfFiles);
    } else {
      arrayOfFiles.push(fullPath);
    }
  }
  return arrayOfFiles;
}

async function run() {
  console.log('Fetching current ref main...');
  const ref = await githubRequest('GET', `/repos/${OWNER}/${REPO}/git/refs/heads/main`);
  const parentCommitSha = ref.object.sha;
  console.log(`Current main commit: ${parentCommitSha}`);

  const allFiles = getAllFiles(BASE_DIR);
  console.log(`Found ${allFiles.length} files to upload.`);

  const treeEntries = [];

  for (const filePath of allFiles) {
    const relPath = path.relative(BASE_DIR, filePath);
    const content = fs.readFileSync(filePath);
    const base64Content = content.toString('base64');

    console.log(`Creating blob for: ${relPath}`);
    const blob = await githubRequest('POST', `/repos/${OWNER}/${REPO}/git/blobs`, {
      content: base64Content,
      encoding: 'base64'
    });

    treeEntries.push({
      path: relPath,
      mode: '100644',
      type: 'blob',
      sha: blob.sha
    });
  }

  console.log(`Creating git tree with ${treeEntries.length} items...`);
  const tree = await githubRequest('POST', `/repos/${OWNER}/${REPO}/git/trees`, {
    tree: treeEntries
  });
  console.log(`New tree created: ${tree.sha}`);

  console.log('Creating commit...');
  const commit = await githubRequest('POST', `/repos/${OWNER}/${REPO}/git/commits`, {
    message: 'feat: implement GCOOL native iOS app, test suite, and CI/CD packaging workflows\n\n- Xcode 13/14/15 compatible project targeting iPhone 7 Plus (iOS 15.0+)\n- Glacier cooling aesthetic with winter theme, dark mode, and battery-conscious snow animation\n- Gaming Mode lock: active game pinning, URL launching, and Guided Access integration\n- Honest technical disclosure on Screen Time and ProcessInfo.thermalState\n- Automated GitHub Actions for unit testing and unsigned IPA packaging',
    tree: tree.sha,
    parents: [parentCommitSha]
  });
  console.log(`New commit created: ${commit.sha}`);

  console.log('Updating refs/heads/main...');
  await githubRequest('PATCH', `/repos/${OWNER}/${REPO}/git/refs/heads/main`, {
    sha: commit.sha,
    force: true
  });

  console.log('Successfully pushed all files to GitHub repository main branch!');
}

run().catch(err => {
  console.error('Fatal sync error:', err);
  process.exit(1);
});
