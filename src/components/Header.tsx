import React from 'react';
import {
  Zap,
  Github,
  Download,
  Flame,
  Snowflake,
  Code2,
  Sliders,
  Activity,
  Smartphone,
  Lightbulb
} from 'lucide-react';
import confetti from 'canvas-confetti';

interface Props {
  activeTab: 'config' | 'code' | 'github' | 'github-control' | 'benchmark' | 'sideload';
  onTabChange: (tab: 'config' | 'code' | 'github' | 'github-control' | 'benchmark' | 'sideload') => void;
  onOpenRepoIdeas: () => void;
  onDownloadZip: () => void;
  isDownloadingZip: boolean;
}

export const Header: React.FC<Props> = ({
  activeTab,
  onTabChange,
  onOpenRepoIdeas,
  onDownloadZip,
  isDownloadingZip,
}) => {
  const triggerDownloadWithConfetti = () => {
    confetti({
      particleCount: 80,
      spread: 60,
      origin: { y: 0.15 },
    });
    onDownloadZip();
  };

  return (
    <header className="border-b border-slate-800/80 bg-slate-950/80 backdrop-blur-md sticky top-0 z-40">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16 gap-4">
          {/* Logo & Branding */}
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-sky-500 to-indigo-600 flex items-center justify-center text-white shadow-lg shadow-sky-500/25 ring-1 ring-white/20">
              <Zap className="w-5 h-5 fill-white" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="font-bold text-white text-base tracking-tight font-mono">
                  TeleTurbo<span className="text-sky-400">.iOS</span>
                </span>
                <span className="hidden sm:inline-block px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider rounded-full bg-emerald-500/15 text-emerald-400 border border-emerald-500/30">
                  Tweak &amp; CI/CD
                </span>
              </div>
              <p className="text-[11px] text-slate-400 hidden sm:block">
                Ultra Performance • Auto Background Freeze • Anti-Thermal Shield
              </p>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex items-center gap-2.5">
            <button
              onClick={onOpenRepoIdeas}
              className="hidden md:flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-medium text-slate-300 hover:text-white bg-slate-900 border border-slate-800 hover:border-slate-700 transition cursor-pointer"
            >
              <Lightbulb className="w-3.5 h-3.5 text-amber-400" />
              <span>GitHub Names &amp; Ideas</span>
            </button>

            <button
              onClick={triggerDownloadWithConfetti}
              disabled={isDownloadingZip}
              className="flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-semibold bg-gradient-to-r from-sky-500 to-indigo-600 hover:from-sky-400 hover:to-indigo-500 text-white shadow-lg shadow-sky-500/25 transition cursor-pointer disabled:opacity-50"
            >
              <Download className="w-3.5 h-3.5" />
              <span>{isDownloadingZip ? 'Zipping...' : 'Download GitHub Repo (.zip)'}</span>
            </button>
          </div>
        </div>

        {/* Navigation Tabs */}
        <div className="flex items-center gap-1 overflow-x-auto py-2 scrollbar-none border-t border-slate-900/60">
          <button
            onClick={() => onTabChange('config')}
            className={`flex items-center gap-2 px-3.5 py-1.5 rounded-lg text-xs font-medium transition cursor-pointer whitespace-nowrap ${
              activeTab === 'config'
                ? 'bg-sky-500/15 text-sky-400 border border-sky-500/30'
                : 'text-slate-400 hover:text-slate-200 hover:bg-slate-900'
            }`}
          >
            <Sliders className="w-3.5 h-3.5" />
            <span>Tweak Tuning &amp; Stripper</span>
          </button>

          <button
            onClick={() => onTabChange('code')}
            className={`flex items-center gap-2 px-3.5 py-1.5 rounded-lg text-xs font-medium transition cursor-pointer whitespace-nowrap ${
              activeTab === 'code'
                ? 'bg-sky-500/15 text-sky-400 border border-sky-500/30'
                : 'text-slate-400 hover:text-slate-200 hover:bg-slate-900'
            }`}
          >
            <Code2 className="w-3.5 h-3.5" />
            <span>Code &amp; File Inspector</span>
          </button>

          <button
            onClick={() => onTabChange('github-control')}
            className={`flex items-center gap-2 px-3.5 py-1.5 rounded-lg text-xs font-semibold transition cursor-pointer whitespace-nowrap ${
              activeTab === 'github-control'
                ? 'bg-sky-500/20 text-sky-300 border border-sky-400/50 shadow-sm'
                : 'text-slate-300 hover:text-white hover:bg-slate-900 border border-slate-800/80 bg-slate-900/40'
            }`}
          >
            <Github className="w-3.5 h-3.5 text-sky-400" />
            <span>Connect &amp; Control GitHub</span>
            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
          </button>

          <button
            onClick={() => onTabChange('github')}
            className={`flex items-center gap-2 px-3.5 py-1.5 rounded-lg text-xs font-medium transition cursor-pointer whitespace-nowrap ${
              activeTab === 'github'
                ? 'bg-sky-500/15 text-sky-400 border border-sky-500/30'
                : 'text-slate-400 hover:text-slate-200 hover:bg-slate-900'
            }`}
          >
            <Github className="w-3.5 h-3.5" />
            <span>CI/CD Workflow Guide</span>
          </button>

          <button
            onClick={() => onTabChange('benchmark')}
            className={`flex items-center gap-2 px-3.5 py-1.5 rounded-lg text-xs font-medium transition cursor-pointer whitespace-nowrap ${
              activeTab === 'benchmark'
                ? 'bg-sky-500/15 text-sky-400 border border-sky-500/30'
                : 'text-slate-400 hover:text-slate-200 hover:bg-slate-900'
            }`}
          >
            <Activity className="w-3.5 h-3.5" />
            <span>Thermal &amp; Performance Lab</span>
          </button>

          <button
            onClick={() => onTabChange('sideload')}
            className={`flex items-center gap-2 px-3.5 py-1.5 rounded-lg text-xs font-medium transition cursor-pointer whitespace-nowrap ${
              activeTab === 'sideload'
                ? 'bg-sky-500/15 text-sky-400 border border-sky-500/30'
                : 'text-slate-400 hover:text-slate-200 hover:bg-slate-900'
            }`}
          >
            <Smartphone className="w-3.5 h-3.5" />
            <span>Sideload &amp; Injection Guide</span>
          </button>
        </div>
      </div>
    </header>
  );
};
