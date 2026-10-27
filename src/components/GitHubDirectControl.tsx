import React, { useState, useEffect } from 'react';
import {
  Github,
  CheckCircle2,
  AlertTriangle,
  Play,
  RotateCw,
  ExternalLink,
  Plus,
  GitBranch,
  UploadCloud,
  Check,
  Copy,
  Lock,
  Globe,
  Download,
  Terminal,
  ShieldCheck,
  Wrench,
  Clock,
  LogOut,
  Sparkles,
  Key
} from 'lucide-react';
import { TweakConfig } from '../types/tweak';
import { tweakFiles } from '../data/tweakFiles';
import confetti from 'canvas-confetti';

interface Props {
  config: TweakConfig;
  onConfigChange: (newConfig: TweakConfig) => void;
}

interface GitHubUser {
  login: string;
  name: string;
  avatar_url: string;
  html_url: string;
  public_repos: number;
}

interface GitHubRepo {
  id: number;
  name: string;
  full_name: string;
  html_url: string;
  default_branch: string;
  private: boolean;
}

interface WorkflowRun {
  id: number;
  name: string;
  status: string; // queued, in_progress, completed
  conclusion: string | null; // success, failure, null
  html_url: string;
  created_at: string;
  run_number: number;
}

export const GitHubDirectControl: React.FC<Props> = ({ config, onConfigChange }) => {
  const [user, setUser] = useState<GitHubUser | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [tokenInput, setTokenInput] = useState<string>('');
  const [isTokenConnecting, setIsTokenConnecting] = useState<boolean>(false);
  const [authError, setAuthError] = useState<string | null>(null);
  const [oauthConfigured, setOauthConfigured] = useState<boolean>(true);
  const [redirectUri, setRedirectUri] = useState<string>('');

  // Repositories state
  const [repos, setRepos] = useState<GitHubRepo[]>([]);
  const [selectedRepo, setSelectedRepo] = useState<string>('TeleTurbo-iOS');
  const [isCreatingRepo, setIsCreatingRepo] = useState<boolean>(false);
  const [newRepoName, setNewRepoName] = useState<string>('TeleTurbo-iOS');
  const [newRepoPrivate, setNewRepoPrivate] = useState<boolean>(false);

  // Push / Commit state
  const [isPushing, setIsPushing] = useState<boolean>(false);
  const [lastCommitSha, setLastCommitSha] = useState<string | null>(null);
  const [pushSuccess, setPushSuccess] = useState<boolean>(false);

  // Workflow runs state
  const [workflowRuns, setWorkflowRuns] = useState<WorkflowRun[]>([]);
  const [isTriggeringWorkflow, setIsTriggeringWorkflow] = useState<boolean>(false);
  const [isPollingRuns, setIsPollingRuns] = useState<boolean>(false);

  // Auto-Fix state
  const [isAutoFixing, setIsAutoFixing] = useState<boolean>(false);
  const [autoFixMessage, setAutoFixMessage] = useState<string | null>(null);

  // Check auth status on load
  useEffect(() => {
    checkAuthStatus();
    checkOAuthUrl();

    // Listen for OAuth success from popup
    const handleMessage = (event: MessageEvent) => {
      const origin = event.origin;
      if (!origin.endsWith('.run.app') && !origin.includes('localhost') && !origin.includes('3000')) {
        return;
      }

      if (event.data?.type === 'OAUTH_AUTH_SUCCESS') {
        checkAuthStatus();
      } else if (event.data?.type === 'OAUTH_AUTH_ERROR') {
        setAuthError(event.data.error || 'GitHub authorization failed');
      }
    };

    window.addEventListener('message', handleMessage);
    return () => window.removeEventListener('message', handleMessage);
  }, []);

  // Poll workflow runs when active run is pending
  useEffect(() => {
    let interval: any;
    const hasRunningWorkflow = workflowRuns.some(
      (r) => r.status === 'in_progress' || r.status === 'queued'
    );

    if (user && selectedRepo && hasRunningWorkflow) {
      setIsPollingRuns(true);
      interval = setInterval(() => {
        fetchWorkflowRuns(user.login, selectedRepo);
      }, 5000);
    } else {
      setIsPollingRuns(false);
    }

    return () => clearInterval(interval);
  }, [workflowRuns, user, selectedRepo]);

  const checkOAuthUrl = async () => {
    try {
      const res = await fetch('/api/github/auth-url');
      const data = await res.json();
      setOauthConfigured(data.configured);
      if (data.redirectUri) {
        setRedirectUri(data.redirectUri);
      }
    } catch (e) {
      console.error(e);
    }
  };

  const checkAuthStatus = async () => {
    setLoading(true);
    setAuthError(null);
    try {
      const res = await fetch('/api/github/user');
      if (res.ok) {
        const data = await res.json();
        setUser(data.user);
        fetchUserRepos();
      } else {
        setUser(null);
      }
    } catch (err: any) {
      console.error('Auth check error:', err);
      setUser(null);
    } finally {
      setLoading(false);
    }
  };

  const fetchUserRepos = async () => {
    try {
      const res = await fetch('/api/github/repos');
      if (res.ok) {
        const data = await res.json();
        setRepos(data.repos || []);
        const gestureX = data.repos?.find((r: any) => r.name.toLowerCase() === 'gesture-x');
        const microlab2 = data.repos?.find((r: any) => r.name.toLowerCase() === 'microlab-2');
        const defaultPick = gestureX || microlab2 || data.repos?.[0];
        if (defaultPick) {
          setSelectedRepo(defaultPick.name);
          fetchWorkflowRuns(defaultPick.owner?.login || (user?.login ?? ''), defaultPick.name);
        }
      }
    } catch (err) {
      console.error('Fetch repos error:', err);
    }
  };

  const handleOAuthConnect = async () => {
    try {
      setAuthError(null);
      const res = await fetch('/api/github/auth-url');
      const data = await res.json();

      if (!data.configured) {
        setAuthError(data.message || 'GitHub OAuth App is not configured. Please use Personal Access Token below.');
        return;
      }

      // Open OAuth provider URL directly in popup as per AI Studio OAuth specification
      const popup = window.open(
        data.url,
        'github_oauth_popup',
        'width=650,height=750,menubar=no,toolbar=no'
      );

      if (!popup) {
        setAuthError('Popup blocked! Please allow popups for this site.');
      }
    } catch (err: any) {
      setAuthError(err.message || 'Failed to start OAuth');
    }
  };

  const handleTokenConnect = async () => {
    if (!tokenInput.trim()) return;
    setIsTokenConnecting(true);
    setAuthError(null);
    try {
      const res = await fetch('/api/github/connect-token', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ token: tokenInput.trim() }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || 'Failed to authenticate token');
      }

      setUser(data.user);
      setTokenInput('');
      fetchUserRepos();
      confetti({ particleCount: 50, spread: 60 });
    } catch (err: any) {
      setAuthError(err.message);
    } finally {
      setIsTokenConnecting(false);
    }
  };

  const handleDisconnect = async () => {
    try {
      await fetch('/api/github/disconnect', { method: 'POST' });
      setUser(null);
      setRepos([]);
      setWorkflowRuns([]);
    } catch (err) {
      console.error(err);
    }
  };

  const handleCreateRepo = async () => {
    if (!newRepoName.trim() || !user) return;
    setIsCreatingRepo(true);
    setAuthError(null);
    try {
      const res = await fetch('/api/github/create-repo', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name: newRepoName.trim(),
          description: 'TeleTurbo iOS: World-Fastest Telegram iOS Performance Tweak & CI/CD IPA Builder',
          isPrivate: newRepoPrivate,
        }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || 'Failed to create repository');
      }

      await fetchUserRepos();
      setSelectedRepo(data.repo.name);
      confetti({ particleCount: 70, spread: 70 });
      // Automatically push files to newly created repo
      await pushFilesToRepo(user.login, data.repo.name);
    } catch (err: any) {
      setAuthError(err.message);
    } finally {
      setIsCreatingRepo(false);
    }
  };

  const pushFilesToRepo = async (owner: string, repo: string) => {
    setIsPushing(true);
    setPushSuccess(false);
    setAuthError(null);
    try {
      const filesPayload = tweakFiles.map((f) => ({
        path: f.path,
        content: f.getContent(config),
      }));

      // Add .gitignore
      filesPayload.push({
        path: '.gitignore',
        content: `.theos/\n_theos/\npackages/\n*.deb\n*.dylib\n*.ipa\n.DS_Store\n`,
      });

      const res = await fetch('/api/github/push-files', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          owner,
          repo,
          files: filesPayload,
          commitMessage: `feat: sync TeleTurbo tweak suite (${config.extremeMode ? 'Extreme Mode' : 'Standard'}, iOS ${config.targetIosMin}+)`,
        }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || 'Failed to push files');
      }

      setLastCommitSha(data.commitSha);
      setPushSuccess(true);
      confetti({ particleCount: 60, spread: 60 });
      fetchWorkflowRuns(owner, repo);
    } catch (err: any) {
      setAuthError(err.message);
    } finally {
      setIsPushing(false);
    }
  };

  const handleTriggerWorkflow = async () => {
    if (!user || !selectedRepo) return;
    setIsTriggeringWorkflow(true);
    setAuthError(null);
    try {
      const res = await fetch('/api/github/trigger-workflow', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          owner: user.login,
          repo: selectedRepo,
          ref: 'main',
          buildTarget: 'all',
        }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || 'Failed to dispatch workflow');
      }

      setTimeout(() => {
        fetchWorkflowRuns(user.login, selectedRepo);
      }, 2000);
    } catch (err: any) {
      setAuthError(err.message);
    } finally {
      setIsTriggeringWorkflow(false);
    }
  };

  const fetchWorkflowRuns = async (owner: string, repo: string) => {
    try {
      const res = await fetch(`/api/github/workflow-runs?owner=${encodeURIComponent(owner)}&repo=${encodeURIComponent(repo)}`);
      if (res.ok) {
        const data = await res.json();
        setWorkflowRuns(data.workflowRuns || []);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const handleAutoFix = async () => {
    if (!user || !selectedRepo) return;
    setIsAutoFixing(true);
    setAutoFixMessage(null);
    setAuthError(null);
    try {
      // Auto-tune config for maximum compatibility and push fix commit
      const fixedConfig = {
        ...config,
        targetArchitecture: 'both' as const,
        targetIosMin: '15.0',
        blurBypass: true,
        typingZeroLag: true,
        thermalThrottleShield: true,
      };
      onConfigChange(fixedConfig);

      const filesPayload = tweakFiles.map((f) => ({
        path: f.path,
        content: f.getContent(fixedConfig),
      }));

      const res = await fetch('/api/github/push-files', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          owner: user.login,
          repo: selectedRepo,
          files: filesPayload,
          commitMessage: 'fix: auto-remediate Theos compiler flags and Azule dylib injection path',
        }),
      });

      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Failed to push auto-fix');

      setAutoFixMessage('Auto-Fix committed to GitHub! Triggering new CI/CD build run now...');
      await handleTriggerWorkflow();
      confetti({ particleCount: 50, spread: 50 });
    } catch (err: any) {
      setAuthError(err.message);
    } finally {
      setIsAutoFixing(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Top Banner */}
      <div className="bg-gradient-to-r from-slate-900 via-sky-950 to-slate-900 border border-sky-500/30 rounded-2xl p-6 shadow-xl">
        <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-xl bg-slate-950 border border-sky-400/40 flex items-center justify-center text-white shadow-inner">
              <Github className="w-7 h-7" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h2 className="text-xl font-bold text-white tracking-tight">Direct GitHub Control &amp; Automation</h2>
                <span className="px-2.5 py-0.5 text-xs font-semibold bg-sky-500/20 text-sky-300 border border-sky-500/30 rounded-full">
                  Claude-Style Direct Control
                </span>
              </div>
              <p className="text-xs text-slate-300 mt-1 max-w-2xl">
                Authorize your GitHub account to directly create repositories, push tweak source code, trigger cloud builds, monitor status, and auto-fix compilation errors without touching git locally.
              </p>
            </div>
          </div>

          {user && (
            <div className="flex items-center gap-3 bg-slate-950/70 border border-slate-800 p-2 rounded-xl">
              <img
                src={user.avatar_url}
                alt={user.login}
                className="w-8 h-8 rounded-full border border-sky-400"
              />
              <div className="text-left text-xs">
                <div className="font-semibold text-white">{user.name || user.login}</div>
                <div className="text-slate-400 font-mono">@{user.login}</div>
              </div>
              <button
                onClick={handleDisconnect}
                className="p-1.5 text-slate-400 hover:text-rose-400 transition cursor-pointer"
                title="Disconnect GitHub"
              >
                <LogOut className="w-4 h-4" />
              </button>
            </div>
          )}
        </div>
      </div>

      {/* Global Error Banner */}
      {authError && (
        <div className="p-4 rounded-xl bg-rose-950/40 border border-rose-500/40 text-xs text-rose-300 flex items-start gap-2.5">
          <AlertTriangle className="w-4 h-4 text-rose-400 shrink-0 mt-0.5" />
          <div className="flex-1">{authError}</div>
        </div>
      )}

      {/* Auto-Fix Banner */}
      {autoFixMessage && (
        <div className="p-4 rounded-xl bg-emerald-950/40 border border-emerald-500/40 text-xs text-emerald-300 flex items-start gap-2.5">
          <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
          <div className="flex-1">{autoFixMessage}</div>
        </div>
      )}

      {/* SECTION 1: Connect GitHub via Personal Access Token */}
      {!user && !loading && (
        <div className="bg-slate-900/90 border border-emerald-500/30 rounded-2xl p-6 sm:p-8 space-y-6 shadow-2xl relative overflow-hidden bg-gradient-to-b from-slate-900 via-slate-900 to-emerald-950/20">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-5 border-b border-slate-800">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 rounded-2xl bg-emerald-500/20 text-emerald-400 flex items-center justify-center border border-emerald-500/40 shadow-inner">
                <Key className="w-6 h-6" />
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <h3 className="text-lg font-bold text-white">Connect with GitHub Personal Access Token</h3>
                  <span className="px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider rounded-full bg-emerald-500/20 text-emerald-300 border border-emerald-500/40">
                    Recommended &amp; 100% OK
                  </span>
                </div>
                <p className="text-xs text-slate-300 mt-0.5">
                  No Client ID, No Client Secret, and no setup hassle. Just paste your token and we'll control your GitHub directly.
                </p>
              </div>
            </div>

            <a
              href="https://github.com/settings/tokens/new?scopes=repo,workflow&description=TeleTurbo+Direct+Control"
              target="_blank"
              rel="noreferrer"
              className="px-4 py-2.5 rounded-xl text-xs font-semibold bg-slate-800 hover:bg-slate-700 text-sky-300 border border-sky-500/30 hover:border-sky-400 transition flex items-center justify-center gap-2 shadow cursor-pointer shrink-0"
            >
              <ExternalLink className="w-4 h-4 text-sky-400" />
              <span>Generate Token on GitHub (1-Click)</span>
            </a>
          </div>

          {/* Token Input Form */}
          <div className="space-y-4 max-w-3xl">
            <div>
              <label className="block text-xs font-semibold text-slate-200 mb-2">
                Paste your Personal Access Token (starts with <code className="text-emerald-400 font-mono">ghp_</code>):
              </label>
              <div className="flex flex-col sm:flex-row items-stretch gap-3">
                <div className="relative flex-1">
                  <Key className="w-4 h-4 absolute left-3.5 top-3.5 text-slate-500" />
                  <input
                    type="password"
                    placeholder="ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
                    value={tokenInput}
                    onChange={(e) => setTokenInput(e.target.value)}
                    onKeyDown={(e) => {
                      if (e.key === 'Enter') handleTokenConnect();
                    }}
                    className="w-full bg-slate-950 border border-slate-700 hover:border-slate-600 focus:border-emerald-400 text-white text-xs rounded-xl pl-10 pr-4 py-3 focus:outline-none font-mono shadow-inner transition"
                  />
                </div>
                <button
                  onClick={handleTokenConnect}
                  disabled={isTokenConnecting || !tokenInput.trim()}
                  className="px-6 py-3 rounded-xl text-xs font-bold bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-400 hover:to-teal-500 text-white transition disabled:opacity-50 cursor-pointer shadow-lg shadow-emerald-500/25 flex items-center justify-center gap-2"
                >
                  <Github className="w-4 h-4" />
                  <span>{isTokenConnecting ? 'Verifying & Connecting...' : 'Connect & Take Control'}</span>
                </button>
              </div>
            </div>

            {/* Quick 3-Step Guide */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-3 pt-2">
              <div className="p-3 rounded-xl bg-slate-950/60 border border-slate-800 text-[11px] text-slate-400 space-y-1">
                <div className="font-semibold text-slate-200 flex items-center gap-1.5">
                  <span className="w-4 h-4 rounded-full bg-sky-500/20 text-sky-400 font-bold flex items-center justify-center text-[10px]">1</span>
                  Click "Generate Token"
                </div>
                <p>The link opens GitHub with <strong className="text-slate-300">repo</strong> and <strong className="text-slate-300">workflow</strong> scopes pre-selected.</p>
              </div>

              <div className="p-3 rounded-xl bg-slate-950/60 border border-slate-800 text-[11px] text-slate-400 space-y-1">
                <div className="font-semibold text-slate-200 flex items-center gap-1.5">
                  <span className="w-4 h-4 rounded-full bg-sky-500/20 text-sky-400 font-bold flex items-center justify-center text-[10px]">2</span>
                  Generate &amp; Copy
                </div>
                <p>Scroll down on GitHub, click green "Generate token", and copy the <code className="text-emerald-400">ghp_...</code> string.</p>
              </div>

              <div className="p-3 rounded-xl bg-slate-950/60 border border-slate-800 text-[11px] text-slate-400 space-y-1">
                <div className="font-semibold text-slate-200 flex items-center gap-1.5">
                  <span className="w-4 h-4 rounded-full bg-sky-500/20 text-sky-400 font-bold flex items-center justify-center text-[10px]">3</span>
                  Paste &amp; Control
                </div>
                <p>Paste here and TeleTurbo will automatically create your repo, push files, and run builds!</p>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* SECTION 2: Authenticated Direct GitHub Control Workspace */}
      {user && (
        <div className="space-y-6">
          {/* Repository Selector & Creator */}
          <div className="bg-slate-900/80 border border-slate-800 rounded-2xl p-6 space-y-5">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-slate-800">
              <div className="flex items-center gap-2 text-white font-semibold text-sm">
                <GitBranch className="w-4 h-4 text-sky-400" />
                <span>Target Repository on @{user.login}</span>
              </div>

              <div className="flex items-center gap-2">
                <span className="text-xs text-slate-400">Active Repo:</span>
                <select
                  value={selectedRepo}
                  onChange={(e) => {
                    setSelectedRepo(e.target.value);
                    fetchWorkflowRuns(user.login, e.target.value);
                  }}
                  className="bg-slate-950 border border-slate-700 text-white text-xs rounded-lg px-3 py-1.5 focus:outline-none focus:border-sky-500 font-mono"
                >
                  {repos.map((r) => (
                    <option key={r.id} value={r.name}>
                      {r.name} {r.private ? '(Private)' : '(Public)'}
                    </option>
                  ))}
                  {repos.length === 0 && <option value="TeleTurbo-iOS">TeleTurbo-iOS (New)</option>}
                </select>
              </div>
            </div>

            {/* Quick Actions Grid */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {/* Action 1: Create New Repo on User's Account */}
              <div className="p-4 rounded-xl bg-slate-950/70 border border-slate-800 space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-semibold text-white flex items-center gap-1.5">
                    <Plus className="w-4 h-4 text-emerald-400" />
                    Create New Repo
                  </span>
                  <label className="text-[10px] text-slate-400 flex items-center gap-1 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={newRepoPrivate}
                      onChange={(e) => setNewRepoPrivate(e.target.checked)}
                      className="rounded bg-slate-800 border-slate-700"
                    />
                    <span>Private</span>
                  </label>
                </div>

                <div className="flex items-center gap-2">
                  <input
                    type="text"
                    value={newRepoName}
                    onChange={(e) => setNewRepoName(e.target.value)}
                    placeholder="Repo name (e.g. TeleTurbo-iOS)"
                    className="flex-1 bg-slate-900 border border-slate-800 text-white text-xs rounded-lg px-2.5 py-1.5 focus:outline-none focus:border-sky-500 font-mono"
                  />
                  <button
                    onClick={handleCreateRepo}
                    disabled={isCreatingRepo || !newRepoName.trim()}
                    className="px-3 py-1.5 rounded-lg text-xs font-semibold bg-sky-600 hover:bg-sky-500 text-white disabled:opacity-50 cursor-pointer transition shadow"
                  >
                    {isCreatingRepo ? 'Creating...' : 'Create'}
                  </button>
                </div>
              </div>

              {/* Action 2: Direct Commit & Push */}
              <div className="p-4 rounded-xl bg-slate-950/70 border border-slate-800 space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-semibold text-white flex items-center gap-1.5">
                    <UploadCloud className="w-4 h-4 text-sky-400" />
                    Push Tweak Suite
                  </span>
                  {lastCommitSha && (
                    <span className="text-[10px] text-emerald-400 font-mono">
                      #{lastCommitSha.substring(0, 7)}
                    </span>
                  )}
                </div>

                <button
                  onClick={() => pushFilesToRepo(user.login, selectedRepo)}
                  disabled={isPushing}
                  className="w-full py-2 px-3 rounded-lg text-xs font-semibold bg-gradient-to-r from-sky-600 to-indigo-600 hover:from-sky-500 hover:to-indigo-500 text-white transition disabled:opacity-50 cursor-pointer shadow flex items-center justify-center gap-2"
                >
                  <UploadCloud className="w-4 h-4" />
                  <span>{isPushing ? 'Pushing 7 files to GitHub...' : 'Push Tweak Files Directly'}</span>
                </button>
              </div>

              {/* Action 3: Trigger Workflow Cloud Build */}
              <div className="p-4 rounded-xl bg-slate-950/70 border border-slate-800 space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-semibold text-white flex items-center gap-1.5">
                    <Play className="w-4 h-4 text-emerald-400" />
                    Run Cloud Build
                  </span>
                  <button
                    onClick={() => fetchWorkflowRuns(user.login, selectedRepo)}
                    className="text-[11px] text-slate-400 hover:text-white flex items-center gap-1 cursor-pointer"
                    title="Refresh runs"
                  >
                    <RotateCw className={`w-3 h-3 ${isPollingRuns ? 'animate-spin text-sky-400' : ''}`} />
                  </button>
                </div>

                <button
                  onClick={handleTriggerWorkflow}
                  disabled={isTriggeringWorkflow}
                  className="w-full py-2 px-3 rounded-lg text-xs font-semibold bg-emerald-600 hover:bg-emerald-500 text-white transition disabled:opacity-50 cursor-pointer shadow flex items-center justify-center gap-2"
                >
                  <Play className="w-4 h-4 fill-white" />
                  <span>{isTriggeringWorkflow ? 'Triggering Action...' : 'Trigger CI/CD Build (.ipa/.deb)'}</span>
                </button>
              </div>
            </div>
          </div>

          {/* Workflow Runs & Release Monitor */}
          <div className="bg-slate-900/80 border border-slate-800 rounded-2xl p-6 space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2 text-white font-semibold text-sm">
                <Clock className="w-4 h-4 text-sky-400" />
                <span>GitHub Actions Live Runs &amp; Releases</span>
              </div>

              <div className="flex items-center gap-3">
                <button
                  onClick={handleAutoFix}
                  disabled={isAutoFixing}
                  className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium bg-amber-500/15 hover:bg-amber-500/25 border border-amber-500/30 text-amber-300 transition cursor-pointer"
                >
                  <Wrench className="w-3.5 h-3.5" />
                  <span>{isAutoFixing ? 'Fixing & Pushing...' : 'Auto-Fix Build & Re-run'}</span>
                </button>

                <a
                  href={`https://github.com/${user.login}/${selectedRepo}/actions`}
                  target="_blank"
                  rel="noreferrer"
                  className="flex items-center gap-1 text-xs text-sky-400 hover:underline"
                >
                  <span>Open in GitHub</span>
                  <ExternalLink className="w-3.5 h-3.5" />
                </a>
              </div>
            </div>

            {/* Runs list */}
            <div className="space-y-2">
              {workflowRuns.length === 0 ? (
                <div className="p-6 rounded-xl bg-slate-950/50 border border-slate-800 text-center text-xs text-slate-400 space-y-2">
                  <p>No workflow runs triggered yet for repository <strong>{selectedRepo}</strong>.</p>
                  <p>Click <strong>"Push Tweak Files Directly"</strong> followed by <strong>"Trigger CI/CD Build"</strong> above to launch your first automated Theos &amp; Azule cloud build!</p>
                </div>
              ) : (
                workflowRuns.map((run) => {
                  const isSuccess = run.conclusion === 'success';
                  const isFailed = run.conclusion === 'failure';
                  const isRunning = run.status === 'in_progress' || run.status === 'queued';

                  return (
                    <div
                      key={run.id}
                      className="p-3.5 rounded-xl bg-slate-950/70 border border-slate-800 flex items-center justify-between flex-wrap gap-3"
                    >
                      <div className="flex items-center gap-3">
                        <div className="w-7 h-7 rounded-lg flex items-center justify-center">
                          {isRunning ? (
                            <RotateCw className="w-4 h-4 text-sky-400 animate-spin" />
                          ) : isSuccess ? (
                            <CheckCircle2 className="w-4 h-4 text-emerald-400" />
                          ) : (
                            <AlertTriangle className="w-4 h-4 text-rose-400" />
                          )}
                        </div>
                        <div>
                          <div className="text-xs font-semibold text-white flex items-center gap-2">
                            <span>#{run.run_number} {run.name}</span>
                            <span
                              className={`text-[10px] px-2 py-0.5 rounded font-mono uppercase ${
                                isSuccess
                                  ? 'bg-emerald-500/20 text-emerald-300'
                                  : isFailed
                                  ? 'bg-rose-500/20 text-rose-300'
                                  : 'bg-sky-500/20 text-sky-300'
                              }`}
                            >
                              {run.conclusion || run.status}
                            </span>
                          </div>
                          <div className="text-[11px] text-slate-400 mt-0.5">
                            Triggered: {new Date(run.created_at).toLocaleTimeString()}
                          </div>
                        </div>
                      </div>

                      <div className="flex items-center gap-2">
                        {isSuccess && (
                          <a
                            href={`https://github.com/${user.login}/${selectedRepo}/releases`}
                            target="_blank"
                            rel="noreferrer"
                            className="px-3 py-1.5 rounded-lg text-xs font-semibold bg-emerald-600 hover:bg-emerald-500 text-white flex items-center gap-1.5 transition shadow"
                          >
                            <Download className="w-3.5 h-3.5" />
                            <span>Download .ipa / .deb</span>
                          </a>
                        )}

                        <a
                          href={run.html_url}
                          target="_blank"
                          rel="noreferrer"
                          className="px-3 py-1.5 rounded-lg text-xs bg-slate-800 hover:bg-slate-700 text-slate-200 flex items-center gap-1 transition"
                        >
                          <span>Logs</span>
                          <ExternalLink className="w-3 h-3" />
                        </a>
                      </div>
                    </div>
                  );
                })
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
