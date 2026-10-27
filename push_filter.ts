import fs from 'fs';

const TOKEN = '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';
const OWNER = 'KwarNu-art';
const REPO = 'Microlab-2';

async function main() {
  const fileUrl = `https://api.github.com/repos/${OWNER}/${REPO}/contents/NovaShield.plist`;
  const content = fs.readFileSync('novashield/NovaShield.plist', 'utf-8');

  const putRes = await fetch(fileUrl, {
    method: 'PUT',
    headers: {
      Authorization: `Bearer ${TOKEN}`,
      'User-Agent': 'NovaShield-Fixer',
      Accept: 'application/vnd.github.v3+json',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      message: 'fix: add NovaShield.plist substrate filter targeting com.apple.springboard',
      content: Buffer.from(content).toString('base64'),
      branch: 'main',
    }),
  });

  if (!putRes.ok) throw new Error(await putRes.text());
  const putData = await putRes.json();
  console.log('✅ Added NovaShield.plist! Commit:', putData.commit.sha);
}

main().catch(console.error);
