import React, { useState } from 'react';
import { Header } from './components/Header';
import { TweakConfigurator } from './components/TweakConfigurator';
import { CodeViewer } from './components/CodeViewer';
import { GitHubWorkflowGuide } from './components/GitHubWorkflowGuide';
import { PerformanceBenchmark } from './components/PerformanceBenchmark';
import { InjectionGuide } from './components/InjectionGuide';
import { GitHubRepoIdeasModal } from './components/GitHubRepoIdeasModal';
import { GitHubDirectControl } from './components/GitHubDirectControl';
import { defaultTweakConfig } from './data/tweakFiles';
import { TweakConfig } from './types/tweak';
import { generateAndDownloadZip } from './utils/zipExporter';
import {
  Zap,
  Snowflake,
  Cpu,
  Layers,
  Sparkles,
  ShieldCheck,
  CheckCircle2,
  Clock,
  ArrowRight,
  ExternalLink
} from 'lucide-react';

export default function App() {
  const [config, setConfig] = useState<TweakConfig>(defaultTweakConfig);
  const [activeTab, setActiveTab] = useState<'config' | 'code' | 'github' | 'github-control' | 'benchmark' | 'sideload'>('github-control');
  const [activeFileId, setActiveFileId] = useState<string>('tweak_x');
  const [isRepoIdeasOpen, setIsRepoIdeasOpen] = useState(false);
  const [isDownloadingZip, setIsDownloadingZip] = useState(false);

  const handleDownloadZip = async () => {
    try {
      setIsDownloadingZip(true);
      await generateAndDownloadZip(config, 'TeleTurbo-iOS');
    } catch (err) {
      console.error('Failed to generate zip:', err);
    } finally {
      setIsDownloadingZip(false);
    }
  };

  const handleOpenCodeView = (fileId: string) => {
    setActiveFileId(fileId);
    setActiveTab('code');
  };

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col font-sans selection:bg-sky-500/30 selection:text-sky-200">
      {/* Top App Header */}
      <Header
        activeTab={activeTab}
        onTabChange={setActiveTab}
        onOpenRepoIdeas={() => setIsRepoIdeasOpen(true)}
        onDownloadZip={handleDownloadZip}
        isDownloadingZip={isDownloadingZip}
      />

      {/* Live System Engine Status Strip */}
      <div className="bg-slate-900/40 border-b border-slate-800/60 py-2 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto flex items-center justify-between text-xs text-slate-400 overflow-x-auto gap-4">
          <div className="flex items-center gap-5 whitespace-nowrap">
            <span className="flex items-center gap-1.5 text-sky-400 font-medium">
              <Zap className="w-3.5 h-3.5" />
              <span>Main Thread: User Interactive VIP</span>
            </span>

            <span className="flex items-center gap-1.5 text-indigo-400 font-medium">
              <Snowflake className="w-3.5 h-3.5" />
              <span>Background Freezing: SIGSTOP Hook Active</span>
            </span>

            <span className="flex items-center gap-1.5 text-emerald-400 font-medium">
              <CheckCircle2 className="w-3.5 h-3.5" />
              <span>Stories &amp; Heavy Lottie: Stripped</span>
            </span>

            <span className="flex items-center gap-1.5 text-purple-400 font-medium">
              <Cpu className="w-3.5 h-3.5" />
              <span>Target: ARM64/ARM64e • iOS {config.targetIosMin}+</span>
            </span>
          </div>

          <div className="hidden lg:flex items-center gap-2 text-[11px] text-slate-500 font-mono">
            <span>Bundle: ph.telegra.Telegraph</span>
            <span>•</span>
            <span>Theos 2.0+ Compatible</span>
          </div>
        </div>
      </div>

      {/* Main Workspace Body */}
      <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-6">
        {activeTab === 'github-control' && (
          <GitHubDirectControl
            config={config}
            onConfigChange={setConfig}
          />
        )}

        {activeTab === 'config' && (
          <TweakConfigurator
            config={config}
            onChange={setConfig}
            onOpenCodeView={handleOpenCodeView}
          />
        )}

        {activeTab === 'code' && (
          <CodeViewer
            config={config}
            activeFileId={activeFileId}
            onSelectFile={setActiveFileId}
          />
        )}

        {activeTab === 'github' && (
          <GitHubWorkflowGuide
            config={config}
            onOpenRepoIdeas={() => setIsRepoIdeasOpen(true)}
            onDownloadZip={handleDownloadZip}
          />
        )}

        {activeTab === 'benchmark' && (
          <PerformanceBenchmark config={config} />
        )}

        {activeTab === 'sideload' && (
          <InjectionGuide />
        )}
      </main>

      {/* Bottom Sticky Action Footer for quick deployment */}
      <footer className="border-t border-slate-900 bg-slate-950/90 py-4 px-4 sm:px-6 lg:px-8 text-xs text-slate-500">
        <div className="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-3">
          <div className="flex items-center gap-2 text-slate-400">
            <span className="font-semibold text-white">TeleTurbo Suite for Telegram iOS</span>
            <span>—</span>
            <span>Designed for 24-hour continuous non-stop operation with zero overheating and zero lag.</span>
          </div>

          <div className="flex items-center gap-4">
            <button
              onClick={() => setIsRepoIdeasOpen(true)}
              className="text-slate-400 hover:text-white transition cursor-pointer"
            >
              GitHub Repository Names
            </button>
            <button
              onClick={() => handleOpenCodeView('github_workflow')}
              className="text-sky-400 hover:text-sky-300 transition cursor-pointer font-medium"
            >
              Inspect CI/CD Workflow
            </button>
          </div>
        </div>
      </footer>

      {/* GitHub Repository Ideas Modal */}
      <GitHubRepoIdeasModal
        isOpen={isRepoIdeasOpen}
        onClose={() => setIsRepoIdeasOpen(false)}
      />
    </div>
  );
}
