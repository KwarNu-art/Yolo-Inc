import React, { useState } from 'react';
import {
  Smartphone,
  Terminal,
  Copy,
  Check,
  Shield,
  Zap,
  Download,
  AlertCircle,
  ExternalLink,
  ChevronRight
} from 'lucide-react';

export const InjectionGuide: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'trollstore' | 'azule' | 'jailbreak' | 'sideloadly'>('trollstore');
  const [copiedId, setCopiedId] = useState<string | null>(null);

  const copySnippet = (text: string, id: string) => {
    navigator.clipboard.writeText(text);
    setCopiedId(id);
    setTimeout(() => setCopiedId(null), 2000);
  };

  const azuleCommand = `# 1. Install Azule (macOS / Linux / iOS)
git clone https://github.com/Al4ise/Azule ~/azule
sudo ln -sf ~/azule/azule /usr/local/bin/azule

# 2. Inject TeleTurbo.dylib into decrypted Telegram IPA
azule -i Telegram.ipa -o TeleTurbo_Telegram.ipa -f TeleTurbo.dylib -m 15.0 -v

# 3. Done! The output TeleTurbo_Telegram.ipa is ready to install.`;

  const jailbreakCommand = `# Copy TeleTurbo-Rootless.deb to your iPhone (via SSH / AirDrop / Filza)
scp TeleTurbo-Rootless.deb mobile@192.168.1.xxx:/var/mobile/

# Install over SSH terminal
ssh mobile@192.168.1.xxx
sudo dpkg -i /var/mobile/TeleTurbo-Rootless.deb
killall -9 Telegraph SpringBoard`;

  return (
    <div className="space-y-6">
      {/* Tab Switcher */}
      <div className="bg-slate-900/80 border border-slate-800 rounded-2xl p-2 flex flex-wrap gap-2">
        <button
          onClick={() => setActiveTab('trollstore')}
          className={`px-4 py-2.5 rounded-xl text-xs font-semibold transition cursor-pointer flex items-center gap-2 ${
            activeTab === 'trollstore'
              ? 'bg-emerald-600 text-white shadow-lg shadow-emerald-600/30'
              : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/60'
          }`}
        >
          <Zap className="w-4 h-4" />
          <span>TrollStore (Permanent Sideload)</span>
        </button>

        <button
          onClick={() => setActiveTab('azule')}
          className={`px-4 py-2.5 rounded-xl text-xs font-semibold transition cursor-pointer flex items-center gap-2 ${
            activeTab === 'azule'
              ? 'bg-sky-600 text-white shadow-lg shadow-sky-600/30'
              : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/60'
          }`}
        >
          <Terminal className="w-4 h-4" />
          <span>Azule Terminal Injection</span>
        </button>

        <button
          onClick={() => setActiveTab('jailbreak')}
          className={`px-4 py-2.5 rounded-xl text-xs font-semibold transition cursor-pointer flex items-center gap-2 ${
            activeTab === 'jailbreak'
              ? 'bg-purple-600 text-white shadow-lg shadow-purple-600/30'
              : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/60'
          }`}
        >
          <Shield className="w-4 h-4" />
          <span>Jailbroken (Dopamine / Sileo)</span>
        </button>

        <button
          onClick={() => setActiveTab('sideloadly')}
          className={`px-4 py-2.5 rounded-xl text-xs font-semibold transition cursor-pointer flex items-center gap-2 ${
            activeTab === 'sideloadly'
              ? 'bg-indigo-600 text-white shadow-lg shadow-indigo-600/30'
              : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/60'
          }`}
        >
          <Smartphone className="w-4 h-4" />
          <span>AltStore / Sideloadly</span>
        </button>
      </div>

      {/* Tab 1: TrollStore */}
      {activeTab === 'trollstore' && (
        <div className="bg-slate-900/80 border border-slate-800 rounded-2xl p-6 space-y-5">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-emerald-500/20 text-emerald-400 flex items-center justify-center font-bold">
              TS
            </div>
            <div>
              <h3 className="text-lg font-bold text-white">TrollStore Installation (Recommended)</h3>
              <p className="text-xs text-slate-400">
                Permanent installation with no 7-day revokes, full JIT access, and zero sandbox restrictions.
              </p>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="p-4 rounded-xl bg-slate-950/60 border border-slate-800 space-y-2">
              <span className="w-6 h-6 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center font-bold text-xs">
                1
              </span>
              <div className="text-sm font-semibold text-white">Download Injected IPA</div>
              <p className="text-xs text-slate-400">
                Download the <code className="text-emerald-400">TeleTurbo_Telegram_Optimized.ipa</code> from your GitHub Actions Release.
              </p>
            </div>

            <div className="p-4 rounded-xl bg-slate-950/60 border border-slate-800 space-y-2">
              <span className="w-6 h-6 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center font-bold text-xs">
                2
              </span>
              <div className="text-sm font-semibold text-white">Open in TrollStore</div>
              <p className="text-xs text-slate-400">
                In Safari on your iPhone, tap the downloaded file &rarr; Share &rarr; Select <strong>TrollStore</strong>.
              </p>
            </div>

            <div className="p-4 rounded-xl bg-slate-950/60 border border-slate-800 space-y-2">
              <span className="w-6 h-6 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center font-bold text-xs">
                3
              </span>
              <div className="text-sm font-semibold text-white">Tap Install & Enjoy</div>
              <p className="text-xs text-slate-400">
                TrollStore will sign and install Telegram instantly. TeleTurbo runs automatically with full background priority.
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Tab 2: Azule CLI */}
      {activeTab === 'azule' && (
        <div className="bg-slate-900/80 border border-slate-800 rounded-2xl p-6 space-y-5">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-sky-500/20 text-sky-400 flex items-center justify-center">
                <Terminal className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-lg font-bold text-white">Manual Azule IPA Patcher</h3>
                <p className="text-xs text-slate-400">
                  Quickly inject <code className="text-sky-300">TeleTurbo.dylib</code> into any decrypted Telegram IPA from your Mac/Linux/WSL terminal.
                </p>
              </div>
            </div>

            <button
              onClick={() => copySnippet(azuleCommand, 'azule-cmd')}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium bg-slate-800 hover:bg-slate-700 text-slate-200 transition cursor-pointer"
            >
              {copiedId === 'azule-cmd' ? (
                <>
                  <Check className="w-3.5 h-3.5 text-emerald-400" />
                  <span className="text-emerald-400">Copied!</span>
                </>
              ) : (
                <>
                  <Copy className="w-3.5 h-3.5" />
                  <span>Copy Commands</span>
                </>
              )}
            </button>
          </div>

          <div className="bg-slate-950 border border-slate-800 rounded-xl p-4 font-mono text-xs text-slate-300 overflow-x-auto">
            <pre>{azuleCommand}</pre>
          </div>
        </div>
      )}

      {/* Tab 3: Jailbroken */}
      {activeTab === 'jailbreak' && (
        <div className="bg-slate-900/80 border border-slate-800 rounded-2xl p-6 space-y-5">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-purple-500/20 text-purple-400 flex items-center justify-center">
                <Shield className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-lg font-bold text-white">Jailbroken Installation (Dopamine / palera1n)</h3>
                <p className="text-xs text-slate-400">
                  Installs system-wide hooking with full SpringBoard background app suspension capability.
                </p>
              </div>
            </div>

            <button
              onClick={() => copySnippet(jailbreakCommand, 'jb-cmd')}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium bg-slate-800 hover:bg-slate-700 text-slate-200 transition cursor-pointer"
            >
              {copiedId === 'jb-cmd' ? (
                <>
                  <Check className="w-3.5 h-3.5 text-emerald-400" />
                  <span className="text-emerald-400">Copied!</span>
                </>
              ) : (
                <>
                  <Copy className="w-3.5 h-3.5" />
                  <span>Copy SSH Script</span>
                </>
              )}
            </button>
          </div>

          <div className="bg-slate-950 border border-slate-800 rounded-xl p-4 font-mono text-xs text-slate-300 overflow-x-auto">
            <pre>{jailbreakCommand}</pre>
          </div>

          <div className="p-4 rounded-xl bg-purple-950/20 border border-purple-500/30 text-xs text-purple-200">
            <strong>Sileo / Zebra GUI Method:</strong> Simply share the downloaded <code className="text-white">TeleTurbo-Rootless.deb</code> to <strong>Filza File Manager</strong> or <strong>Sileo</strong> and tap "Get" &rarr; "Confirm".
          </div>
        </div>
      )}

      {/* Tab 4: Sideloadly / AltStore */}
      {activeTab === 'sideloadly' && (
        <div className="bg-slate-900/80 border border-slate-800 rounded-2xl p-6 space-y-5">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-indigo-500/20 text-indigo-400 flex items-center justify-center">
              <Smartphone className="w-5 h-5" />
            </div>
            <div>
              <h3 className="text-lg font-bold text-white">Sideloading with Computer (Free Apple ID)</h3>
              <p className="text-xs text-slate-400">
                Works on any non-jailbroken iPhone with Mac or Windows PC.
              </p>
            </div>
          </div>

          <div className="space-y-3 text-xs text-slate-300">
            <div className="p-3.5 rounded-xl bg-slate-950/60 border border-slate-800 flex items-start gap-3">
              <span className="font-bold text-sky-400">Step 1:</span>
              <div>Download <strong>Sideloadly</strong> on your PC/Mac from sideloadly.io.</div>
            </div>
            <div className="p-3.5 rounded-xl bg-slate-950/60 border border-slate-800 flex items-start gap-3">
              <span className="font-bold text-sky-400">Step 2:</span>
              <div>Drag and drop the GitHub Release <code className="text-sky-300">TeleTurbo_Telegram_Optimized.ipa</code> into Sideloadly.</div>
            </div>
            <div className="p-3.5 rounded-xl bg-slate-950/60 border border-slate-800 flex items-start gap-3">
              <span className="font-bold text-sky-400">Step 3:</span>
              <div>Enter your Apple ID and click <strong>Start</strong>. When finished, open Telegram and enjoy 24h zero-lag messaging!</div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
