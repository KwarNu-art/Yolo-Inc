import express from 'express';
import cookieParser from 'cookie-parser';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT ? parseInt(process.env.PORT, 10) : 3000;

app.use(express.json({ limit: '10mb' }));
app.use(cookieParser());

// In-memory token store fallback for preview sessions
const sessionTokens = new Map<string, string>();

function getAppUrl(req: express.Request): string {
  if (process.env.APP_URL) {
    return process.env.APP_URL.replace(/\/+$/, '');
  }
  const protocol = req.headers['x-forwarded-proto'] || req.protocol || 'http';
  const host = req.headers['x-forwarded-host'] || req.headers.host || `localhost:${PORT}`;
  return `${protocol}://${host}`;
}

function getGitHubToken(req: express.Request): string | null {
  const authHeader = req.headers.authorization;
  if (authHeader && authHeader.startsWith('Bearer ')) {
    return authHeader.substring(7);
  }
  if (req.cookies && req.cookies.gh_token) {
    return req.cookies.gh_token;
  }
  const sessionId = req.cookies?.tt_session;
  if (sessionId && sessionTokens.has(sessionId)) {
    return sessionTokens.get(sessionId)!;
  }
  if (process.env.GITHUB_TOKEN) {
    return process.env.GITHUB_TOKEN;
  }
  return null;
}

// -------------------------------------------------------------
// GitHub OAuth & Management Endpoints
// -------------------------------------------------------------

// 1. Get OAuth authorization URL
app.get('/api/github/auth-url', (req, res) => {
  const clientId = process.env.GITHUB_CLIENT_ID;
  const appUrl = getAppUrl(req);
  const redirectUri = `${appUrl}/auth/callback`;

  if (!clientId) {
    return res.status(200).json({
      configured: false,
      message: 'GITHUB_CLIENT_ID is not configured yet. You can still connect instantly using a Personal Access Token (PAT) below or configure OAuth.',
      redirectUri,
    });
  }

  const params = new URLSearchParams({
    client_id: clientId,
    redirect_uri: redirectUri,
    scope: 'repo workflow read:user user:email',
    allow_signup: 'true',
  });

  const authUrl = `https://github.com/login/oauth/authorize?${params.toString()}`;
  res.json({
    configured: true,
    url: authUrl,
    redirectUri,
  });
});

// 2. OAuth Callback
const handleCallback = async (req: express.Request, res: express.Response) => {
  const { code, error, error_description } = req.query;

  if (error || !code) {
    const errorMsg = error_description || error || 'Missing authorization code';
    return res.send(`
      <!DOCTYPE html>
      <html>
        <body style="background:#090d16;color:#f87171;font-family:sans-serif;padding:30px;text-align:center;">
          <h2>GitHub Connection Failed</h2>
          <p>${errorMsg}</p>
          <script>
            if (window.opener) {
              window.opener.postMessage({ type: 'OAUTH_AUTH_ERROR', error: '${errorMsg}' }, '*');
              setTimeout(() => window.close(), 2500);
            }
          </script>
        </body>
      </html>
    `);
  }

  try {
    const clientId = process.env.GITHUB_CLIENT_ID;
    const clientSecret = process.env.GITHUB_CLIENT_SECRET;

    if (!clientId || !clientSecret) {
      throw new Error('Server missing GITHUB_CLIENT_ID or GITHUB_CLIENT_SECRET');
    }

    const tokenRes = await fetch('https://github.com/login/oauth/access_token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
      body: JSON.stringify({
        client_id: clientId,
        client_secret: clientSecret,
        code,
      }),
    });

    const tokenData = await tokenRes.json();
    if (tokenData.error) {
      throw new Error(tokenData.error_description || tokenData.error);
    }

    const accessToken = tokenData.access_token;
    const sessionId = 'sess_' + Math.random().toString(36).substring(2) + Date.now().toString(36);
    sessionTokens.set(sessionId, accessToken);

    res.cookie('gh_token', accessToken, {
      secure: true,
      sameSite: 'none',
      httpOnly: false, // Accessible to client if needed
      maxAge: 30 * 24 * 60 * 60 * 1000,
    });

    res.cookie('tt_session', sessionId, {
      secure: true,
      sameSite: 'none',
      httpOnly: true,
      maxAge: 30 * 24 * 60 * 60 * 1000,
    });

    res.send(`
      <!DOCTYPE html>
      <html>
        <head>
          <title>Connecting to GitHub...</title>
          <style>
            body {
              background: #090d16;
              color: #f8fafc;
              font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
              display: flex;
              flex-direction: column;
              align-items: center;
              justify-content: center;
              height: 100vh;
              margin: 0;
            }
            .spinner {
              width: 36px;
              height: 36px;
              border: 3px solid rgba(56, 189, 248, 0.2);
              border-top-color: #38bdf8;
              border-radius: 50%;
              animation: spin 0.8s linear infinite;
              margin-bottom: 16px;
            }
            @keyframes spin { to { transform: rotate(360deg); } }
          </style>
        </head>
        <body>
          <div class="spinner"></div>
          <h3 style="margin:0 0 8px 0; color:#38bdf8;">GitHub Connected Successfully!</h3>
          <p style="margin:0; color:#94a3b8; font-size:14px;">Closing window and returning to TeleTurbo...</p>
          <script>
            const token = ${JSON.stringify(accessToken)};
            if (window.opener) {
              window.opener.postMessage({ type: 'OAUTH_AUTH_SUCCESS', token: token }, '*');
              setTimeout(() => {
                window.close();
              }, 500);
            } else {
              window.location.href = '/';
            }
          </script>
        </body>
      </html>
    `);
  } catch (err: any) {
    res.send(`
      <!DOCTYPE html>
      <html>
        <body style="background:#090d16;color:#f87171;font-family:sans-serif;padding:30px;text-align:center;">
          <h2>Authentication Error</h2>
          <p>${err.message}</p>
        </body>
      </html>
    `);
  }
};

app.get(['/auth/callback', '/auth/callback/'], handleCallback);

// 3. Connect via PAT or direct token
app.post('/api/github/connect-token', async (req, res) => {
  const { token } = req.body;
  if (!token) {
    return res.status(400).json({ error: 'GitHub Personal Access Token is required' });
  }

  try {
    const userRes = await fetch('https://api.github.com/user', {
      headers: {
        Authorization: `Bearer ${token}`,
        'User-Agent': 'TeleTurbo-iOS-App',
        Accept: 'application/vnd.github.v3+json',
      },
    });

    if (!userRes.ok) {
      const err = await userRes.json();
      return res.status(userRes.status).json({ error: err.message || 'Invalid GitHub token' });
    }

    const userData = await userRes.json();

    res.cookie('gh_token', token, {
      secure: true,
      sameSite: 'none',
      httpOnly: false,
      maxAge: 30 * 24 * 60 * 60 * 1000,
    });

    res.json({ success: true, user: userData, token });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

// 4. Disconnect GitHub
app.post('/api/github/disconnect', (req, res) => {
  res.clearCookie('gh_token');
  res.clearCookie('tt_session');
  res.json({ success: true });
});

// 5. Get authenticated user profile
app.get('/api/github/user', async (req, res) => {
  const token = getGitHubToken(req);
  if (!token) {
    return res.status(401).json({ error: 'Not authenticated with GitHub' });
  }

  try {
    const userRes = await fetch('https://api.github.com/user', {
      headers: {
        Authorization: `Bearer ${token}`,
        'User-Agent': 'TeleTurbo-iOS-App',
        Accept: 'application/vnd.github.v3+json',
      },
    });

    if (!userRes.ok) {
      return res.status(userRes.status).json({ error: 'Token expired or invalid' });
    }

    const user = await userRes.json();
    res.json({ user });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

// 6. List user repositories
app.get('/api/github/repos', async (req, res) => {
  const token = getGitHubToken(req);
  if (!token) {
    return res.status(401).json({ error: 'Not authenticated with GitHub' });
  }

  try {
    const reposRes = await fetch('https://api.github.com/user/repos?sort=updated&per_page=100', {
      headers: {
        Authorization: `Bearer ${token}`,
        'User-Agent': 'TeleTurbo-iOS-App',
        Accept: 'application/vnd.github.v3+json',
      },
    });

    if (!reposRes.ok) {
      const err = await reposRes.json();
      return res.status(reposRes.status).json({ error: err.message });
    }

    const repos = await reposRes.json();
    res.json({ repos });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

// 7. Create a new repository on user's GitHub
app.post('/api/github/create-repo', async (req, res) => {
  const token = getGitHubToken(req);
  if (!token) {
    return res.status(401).json({ error: 'Not authenticated with GitHub' });
  }

  const { name, description, isPrivate } = req.body;
  if (!name) {
    return res.status(400).json({ error: 'Repository name is required' });
  }

  try {
    const createRes = await fetch('https://api.github.com/user/repos', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'User-Agent': 'TeleTurbo-iOS-App',
        Accept: 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        name,
        description: description || 'TeleTurbo iOS: Telegram Ultra Performance Tweak & CI/CD IPA Builder',
        private: !!isPrivate,
        auto_init: true, // Creates default branch so we can commit files immediately
      }),
    });

    const repo = await createRes.json();
    if (!createRes.ok) {
      return res.status(createRes.status).json({ error: repo.message || 'Failed to create repository' });
    }

    res.json({ success: true, repo });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

// 8. Commit and Push Files directly to GitHub repository (using Contents or Git Trees)
app.post('/api/github/push-files', async (req, res) => {
  const token = getGitHubToken(req);
  if (!token) {
    return res.status(401).json({ error: 'Not authenticated with GitHub' });
  }

  const { owner, repo, files, commitMessage } = req.body;
  if (!owner || !repo || !files || !Array.isArray(files)) {
    return res.status(400).json({ error: 'owner, repo, and files array are required' });
  }

  try {
    // 1. Get default branch & current commit SHA
    const repoInfoRes = await fetch(`https://api.github.com/repos/${owner}/${repo}`, {
      headers: {
        Authorization: `Bearer ${token}`,
        'User-Agent': 'TeleTurbo-iOS-App',
        Accept: 'application/vnd.github.v3+json',
      },
    });

    if (!repoInfoRes.ok) {
      const err = await repoInfoRes.json();
      return res.status(repoInfoRes.status).json({ error: `Repository not found: ${err.message}` });
    }

    const repoInfo = await repoInfoRes.json();
    const branch = repoInfo.default_branch || 'main';

    // Get latest commit on branch
    const refRes = await fetch(`https://api.github.com/repos/${owner}/${repo}/git/ref/heads/${branch}`, {
      headers: {
        Authorization: `Bearer ${token}`,
        'User-Agent': 'TeleTurbo-iOS-App',
        Accept: 'application/vnd.github.v3+json',
      },
    });

    let baseTreeSha: string | null = null;
    let parentCommitSha: string | null = null;

    if (refRes.ok) {
      const refData = await refRes.json();
      parentCommitSha = refData.object.sha;

      // Get commit to find base_tree
      const commitRes = await fetch(`https://api.github.com/repos/${owner}/${repo}/git/commits/${parentCommitSha}`, {
        headers: {
          Authorization: `Bearer ${token}`,
          'User-Agent': 'TeleTurbo-iOS-App',
          Accept: 'application/vnd.github.v3+json',
        },
      });
      if (commitRes.ok) {
        const commitData = await commitRes.json();
        baseTreeSha = commitData.tree.sha;
      }
    }

    // 2. Create Tree with all files
    const treePayload = {
      base_tree: baseTreeSha || undefined,
      tree: files.map((f: { path: string; content: string }) => ({
        path: f.path,
        mode: '100644',
        type: 'blob',
        content: f.content,
      })),
    };

    const treeRes = await fetch(`https://api.github.com/repos/${owner}/${repo}/git/trees`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'User-Agent': 'TeleTurbo-iOS-App',
        Accept: 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(treePayload),
    });

    if (!treeRes.ok) {
      const err = await treeRes.json();
      return res.status(treeRes.status).json({ error: `Tree creation failed: ${err.message}` });
    }
    const treeData = await treeRes.json();

    // 3. Create Commit
    const commitPayload: any = {
      message: commitMessage || 'feat: deploy TeleTurbo ultra performance tweak suite and CI/CD workflow',
      tree: treeData.sha,
    };
    if (parentCommitSha) {
      commitPayload.parents = [parentCommitSha];
    }

    const createCommitRes = await fetch(`https://api.github.com/repos/${owner}/${repo}/git/commits`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'User-Agent': 'TeleTurbo-iOS-App',
        Accept: 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(commitPayload),
    });

    if (!createCommitRes.ok) {
      const err = await createCommitRes.json();
      return res.status(createCommitRes.status).json({ error: `Commit creation failed: ${err.message}` });
    }
    const newCommit = await createCommitRes.json();

    // 4. Update Reference
    const updateRefRes = await fetch(`https://api.github.com/repos/${owner}/${repo}/git/refs/heads/${branch}`, {
      method: parentCommitSha ? 'PATCH' : 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'User-Agent': 'TeleTurbo-iOS-App',
        Accept: 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(
        parentCommitSha
          ? { sha: newCommit.sha, force: true }
          : { ref: `refs/heads/${branch}`, sha: newCommit.sha }
      ),
    });

    res.json({
      success: true,
      commitSha: newCommit.sha,
      branch,
      repoUrl: repoInfo.html_url,
      pushedFilesCount: files.length,
    });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

// 9. Trigger GitHub Actions Workflow Dispatch
app.post('/api/github/trigger-workflow', async (req, res) => {
  const token = getGitHubToken(req);
  if (!token) {
    return res.status(401).json({ error: 'Not authenticated with GitHub' });
  }

  const { owner, repo, ref, telegramIpaUrl, buildTarget } = req.body;
  if (!owner || !repo) {
    return res.status(400).json({ error: 'owner and repo are required' });
  }

  try {
    const dispatchRes = await fetch(
      `https://api.github.com/repos/${owner}/${repo}/actions/workflows/build-tweak-ipa.yml/dispatches`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
          'User-Agent': 'TeleTurbo-iOS-App',
          Accept: 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          ref: ref || 'main',
          inputs: {
            telegram_ipa_url: telegramIpaUrl || '',
            build_target: buildTarget || 'all',
          },
        }),
      }
    );

    if (!dispatchRes.ok) {
      const err = await dispatchRes.json().catch(() => ({}));
      return res.status(dispatchRes.status).json({
        error: err.message || 'Failed to trigger workflow. Ensure the workflow file exists on default branch.',
      });
    }

    res.json({ success: true, message: 'Workflow dispatched successfully!' });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

// 10. Fetch Workflow Runs & Release Artifacts
app.get('/api/github/workflow-runs', async (req, res) => {
  const token = getGitHubToken(req);
  if (!token) {
    return res.status(401).json({ error: 'Not authenticated with GitHub' });
  }

  const { owner, repo } = req.query;
  if (!owner || !repo) {
    return res.status(400).json({ error: 'owner and repo query params are required' });
  }

  try {
    const runsRes = await fetch(`https://api.github.com/repos/${owner}/${repo}/actions/runs?per_page=10`, {
      headers: {
        Authorization: `Bearer ${token}`,
        'User-Agent': 'TeleTurbo-iOS-App',
        Accept: 'application/vnd.github.v3+json',
      },
    });

    if (!runsRes.ok) {
      const err = await runsRes.json().catch(() => ({}));
      return res.status(runsRes.status).json({ error: err.message || 'Failed to fetch workflow runs' });
    }

    const runsData = await runsRes.json();

    // Also fetch releases
    const releasesRes = await fetch(`https://api.github.com/repos/${owner}/${repo}/releases?per_page=5`, {
      headers: {
        Authorization: `Bearer ${token}`,
        'User-Agent': 'TeleTurbo-iOS-App',
        Accept: 'application/vnd.github.v3+json',
      },
    });

    const releases = releasesRes.ok ? await releasesRes.json() : [];

    res.json({
      workflowRuns: runsData.workflow_runs || [],
      releases: Array.isArray(releases) ? releases : [],
    });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

// -------------------------------------------------------------
// Vite Dev Server / Static Hosting Integration
// -------------------------------------------------------------
async function startServer() {
  if (process.env.NODE_ENV !== 'production') {
    const { createServer } = await import('vite');
    const vite = await createServer({
      server: { middlewareMode: true },
      appType: 'spa',
    });
    app.use(vite.middlewares);
  } else {
    app.use(express.static(path.join(__dirname, 'dist')));
    app.get('*', (req, res) => {
      res.sendFile(path.join(__dirname, 'dist', 'index.html'));
    });
  }

  app.listen(PORT, '0.0.0.0', () => {
    console.log(`[TeleTurbo Server] Running at http://localhost:${PORT}`);
  });
}

startServer();
