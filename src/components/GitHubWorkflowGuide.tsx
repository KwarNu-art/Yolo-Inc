import React, { useState } from 'react';
import {
  Github,
  Play,
  CheckCircle,
  Copy,
  Check,
  Package,
  Layers,
  ArrowRight,
  Sparkles,
  Download,
  AlertTriangle,
  Lightbulb,
  ExternalLink,
  ShieldCheck
} from 'lucide-react';
import { TweakConfig } from '../types/tweak';

interface Props {
  config: TweakConfig;
  onOpenRepoIdeas: () => void;
  onDownloadZip: () => void;
}

export const GitHubWorkflowGuide: React.FC<Props> = ({ config, onOpenRepoIdeas, onDownloadZip }) => {
  const [copiedSnippet, setCopiedSnippet] = useState<string | null>(null);

  const copyToClipboard = (text: string, id: string) => {
    navigator.clipboard.writeText(text);
    setCopiedSnippet(id);
    setTimeout(() => setCopiedSnippet(null), 2000);
  };

  const gitCommands = `# 1. Create a new directory and clone or initialize
mkdir TeleTurbo-iOS
cd TeleTurbo-iOS
git init

# 2. Extract downloaded TeleTurbo-iOS.zip into this folder
# (or create files as viewed in the Code Inspector)

# 3. Stage and commit
git add .
git commit -m "feat: initial release of TeleTurbo ultra performance tweak & CI/CD"

# 4. Link to your GitHub repository & push
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/TeleTurbo-iOS.git
git push -u origin main`;

  return (
    <div className="space-y-6">
      {/* Intro Header */}
      <div className="bg-gradient-to-r from-slate-900 via-sky-950 to-slate-900 border border-sky-500/30 rounded-2xl p-6 shadow-xl">
        <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
          <div>
            <div className="flex items-center gap-2 mb-1">
              <Github className="w-6 h-6 text-white" />
              <h2 className="text-xl font-bold text-white">Automated GitHub CI/CD Cloud Pipeline</h2>
            </div>
            <p className="text-sm text-slate-300 max-w-2xl">
              Compile your custom iOS Tweak (<code className="text-sky-300">.deb</code>) and inject it into decrypted Telegram IPA (<code className="text-sky-300">.ipa</code>) completely free on GitHub's cloud runners. No Mac, no Xcode, and no local Theos setup required!
            </p>
          </div>
          <div className="flex items-center gap-3">
            <button
              onClick={onOpenRepoIdeas}
              className="px-4 py-2 text-xs font-semibold bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 rounded-xl transition flex items-center gap-2 cursor-pointer shadow"
            >
              <Lightbulb className="w-4 h-4 text-amber-400" />
              Repo Names & Ideas
            </button>
            <button
              onClick={onDownloadZip}
              className="px-4 py-2 text-xs font-semibold bg-sky-600 hover:bg-sky-500 text-white rounded-xl shadow-lg shadow-sky-600/30 transition flex items-center gap-2 cursor-pointer"
            >
              <Download className="w-4 h-4" />
              Download Ready Zip
            </button>
          </div>
        </div>
      </div>

      {/* Visual Pipeline Flow */}
      <div className="bg-slate-900/80 border border-slate-800 rounded-2xl p-5">
        <h3 className="text-sm font-semibold uppercase tracking-wider text-slate-400 mb-4 flex items-center gap-2">
          <Layers className="w-4 h-4 text-sky-400" />
          Cloud Build & Injection Flowchart
        </h3>

        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 relative">
          {/* Step 1 */}
          <div className="bg-slate-950/70 border border-slate-800 p-4 rounded-xl relative">
            <div className="w-8 h-8 rounded-lg bg-sky-500/20 text-sky-400 flex items-center justify-center font-bold text-xs mb-3">
              01
            </div>
            <div className="font-semibold text-white text-sm">GitHub Push / Dispatch</div>
            <p className="text-xs text-slate-400 mt-1">
              Triggered automatically when you push to main branch or click "Run workflow" in GitHub Actions tab.
            </p>
          </div>

          {/* Step 2 */}
          <div className="bg-slate-950/70 border border-slate-800 p-4 rounded-xl relative">
            <div className="w-8 h-8 rounded-lg bg-indigo-500/20 text-indigo-400 flex items-center justify-center font-bold text-xs mb-3">
              02
            </div>
            <div className="font-semibold text-white text-sm">Theos Compilation</div>
            <p className="text-xs text-slate-400 mt-1">
              Spawns macOS-14 cloud runner, prepares iOS 16.5 SDK, compiles <code className="text-sky-300">TeleTurbo.dylib</code> and <code className="text-sky-300">.deb</code> packages.
            </p>
          </div>

          {/* Step 3 */}
          <div className="bg-slate-950/70 border border-slate-800 p-4 rounded-xl relative">
            <div className="w-8 h-8 rounded-lg bg-purple-500/20 text-purple-400 flex items-center justify-center font-bold text-xs mb-3">
              03
            </div>
            <div className="font-semibold text-white text-sm">Azule IPA Injection</div>
            <p className="text-xs text-slate-400 mt-1">
              Patches official decrypted Telegram IPA with <code className="text-sky-300">TeleTurbo.dylib</code>, configures entitlements & ad-hoc signs with ldid.
            </p>
          </div>

          {/* Step 4 */}
          <div className="bg-slate-950/70 border border-emerald-500/40 p-4 rounded-xl relative bg-emerald-950/15">
            <div className="w-8 h-8 rounded-lg bg-emerald-500/20 text-emerald-400 flex items-center justify-center font-bold text-xs mb-3">
              04
            </div>
            <div className="font-semibold text-white text-sm flex items-center gap-1.5">
              Instant Release
              <CheckCircle className="w-4 h-4 text-emerald-400" />
            </div>
            <p className="text-xs text-slate-300 mt-1">
              Publishes automated release with ready-to-sideload <code className="text-emerald-400 font-bold">.ipa</code> & <code className="text-emerald-400 font-bold">.deb</code> download links!
            </p>
          </div>
        </div>
      </div>

      {/* Step by Step Setup on GitHub */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-5">
        {/* Terminal Push Guide */}
        <div className="lg:col-span-7 bg-slate-900/80 border border-slate-800 rounded-2xl p-5 space-y-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2 text-white font-semibold text-sm">
              <Github className="w-4 h-4 text-sky-400" />
              <span>Step-by-Step GitHub Setup</span>
            </div>
            <button
              onClick={() => copyToClipboard(gitCommands, 'git-cmds')}
              className="flex items-center gap-1 text-xs text-sky-400 hover:text-sky-300 cursor-pointer"
            >
              {copiedSnippet === 'git-cmds' ? (
                <>
                  <Check className="w-3.5 h-3.5" />
                  <span>Copied!</span>
                </>
              ) : (
                <>
                  <Copy className="w-3.5 h-3.5" />
                  <span>Copy Git Commands</span>
                </>
              )}
            </button>
          </div>

          <div className="bg-slate-950 border border-slate-800 rounded-xl p-4 font-mono text-xs text-slate-300 overflow-x-auto">
            <pre>{gitCommands}</pre>
          </div>

          <div className="space-y-3 pt-2">
            <div className="flex items-start gap-3 text-xs text-slate-300">
              <span className="w-5 h-5 rounded-full bg-sky-500/20 text-sky-400 font-bold flex items-center justify-center shrink-0 mt-0.5">
                1
              </span>
              <div>
                <strong className="text-white">Create a GitHub Repository:</strong> Go to <a href="https://github.com/new" target="_blank" rel="noreferrer" className="text-sky-400 hover:underline">github.com/new</a> and name it <code className="text-sky-300">TeleTurbo-iOS</code>. Set it to Public or Private.
              </div>
            </div>

            <div className="flex items-start gap-3 text-xs text-slate-300">
              <span className="w-5 h-5 rounded-full bg-sky-500/20 text-sky-400 font-bold flex items-center justify-center shrink-0 mt-0.5">
                2
              </span>
              <div>
                <strong className="text-white">Enable GitHub Actions:</strong> In your new repo, navigate to the <strong>Settings</strong> tab &rarr; <strong>Actions</strong> &rarr; <strong>General</strong> &rarr; Ensure "Allow all actions and reusable workflows" is checked, and Workflow permissions are set to "Read and write permissions".
              </div>
            </div>

            <div className="flex items-start gap-3 text-xs text-slate-300">
              <span className="w-5 h-5 rounded-full bg-sky-500/20 text-sky-400 font-bold flex items-center justify-center shrink-0 mt-0.5">
                3
              </span>
              <div>
                <strong className="text-white">Trigger Build:</strong> Push your code or click the <strong>Actions</strong> tab &rarr; select <strong>TeleTurbo CI/CD</strong> &rarr; click <strong>Run workflow</strong>.
              </div>
            </div>
          </div>
        </div>

        {/* Workflow Dispatch Customization */}
        <div className="lg:col-span-5 bg-slate-900/80 border border-slate-800 rounded-2xl p-5 space-y-4">
          <div className="flex items-center gap-2 text-white font-semibold text-sm">
            <Play className="w-4 h-4 text-emerald-400" />
            <span>Workflow Dispatch Inputs</span>
          </div>

          <p className="text-xs text-slate-400 leading-relaxed">
            The workflow file supports custom on-demand inputs directly in GitHub's web interface:
          </p>

          <div className="space-y-3">
            <div className="p-3 rounded-xl bg-slate-950/60 border border-slate-800">
              <div className="text-xs font-semibold text-slate-200">
                <code className="text-sky-300">telegram_ipa_url</code> (Optional)
              </div>
              <p className="text-[11px] text-slate-400 mt-1">
                Provide a direct URL to any specific decrypted Telegram iOS IPA version (e.g. from your Google Drive, MEGA, or Telegram-iOS releases mirror). If empty, uses the official latest mirror.
              </p>
            </div>

            <div className="p-3 rounded-xl bg-slate-950/60 border border-slate-800">
              <div className="text-xs font-semibold text-slate-200">
                <code className="text-sky-300">build_target</code>
              </div>
              <p className="text-[11px] text-slate-400 mt-1">
                Select <code className="text-emerald-400">all</code> (both .deb and .ipa), <code className="text-emerald-400">deb-only</code> (for quick jailbreak updates), or <code className="text-emerald-400">ipa-only</code> (for TrollStore/AltStore sideloaders).
              </p>
            </div>
          </div>

          <div className="p-3 rounded-xl bg-emerald-950/20 border border-emerald-500/30 flex items-start gap-2.5 text-xs text-emerald-200">
            <ShieldCheck className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
            <span>
              <strong>Zero Cost Guarantee:</strong> Public GitHub repositories have unlimited free macOS runner build minutes for open-source iOS tweak automation!
            </span>
          </div>
        </div>
      </div>
    </div>
  );
};
