import React, { useState } from 'react';
import {
  X,
  Sparkles,
  Copy,
  Check,
  Github,
  Tag,
  Star,
  Layers,
  Zap,
  Flame,
  Shield
} from 'lucide-react';

interface Props {
  isOpen: boolean;
  onClose: () => void;
}

export const GitHubRepoIdeasModal: React.FC<Props> = ({ isOpen, onClose }) => {
  const [copiedKey, setCopiedKey] = useState<string | null>(null);

  if (!isOpen) return null;

  const copyToClipboard = (text: string, key: string) => {
    navigator.clipboard.writeText(text);
    setCopiedKey(key);
    setTimeout(() => setCopiedKey(null), 2000);
  };

  const repoIdeas = [
    {
      name: 'TeleTurbo-iOS',
      tagline: 'World-fastest Telegram iOS performance tweak, anti-thermal shield, and automated CI/CD IPA builder.',
      highlight: 'Recommended & Catchy',
      badge: 'TOP PICK'
    },
    {
      name: 'TeleApex-Optimizer',
      tagline: 'Apex performance engine for Telegram iOS: background app freezer, VIP QoS priority, and zero-lag typing.',
      highlight: 'High-tech & Premium',
      badge: 'PERFORMANCE'
    },
    {
      name: 'Telegram-UltraPerformance',
      tagline: 'Jailbreak tweak and TrollStore IPA injector to eliminate Telegram overheating and memory crashes.',
      highlight: 'SEO & Search Friendly',
      badge: 'POPULAR'
    },
    {
      name: 'TeleFreeze-Tweak',
      tagline: 'Focus exclusively on Telegram by automatically freezing non-essential background processes in iOS.',
      highlight: 'Feature-Specific',
      badge: 'INNOVATION'
    },
    {
      name: 'TeleLite-Turbo',
      tagline: 'Strips bloat, stories, and heavy vector animations to keep Telegram iOS running 24/7 without lag.',
      highlight: 'Lightweight & Clean',
      badge: 'LITE'
    },
    {
      name: 'Telegram-ThermalShield',
      tagline: 'Stop iPhone overheating and battery depletion while running Telegram with heavy group chats.',
      highlight: 'Anti-Overheat',
      badge: 'COOLING'
    }
  ];

  const githubTopics = [
    'telegram-ios',
    'theos-tweak',
    'jailbreak',
    'performance-optimization',
    'trollstore',
    'github-actions-ci-cd',
    'dylib-injection',
    'objective-c-plus-plus',
    'azule',
    'rootless-tweak'
  ];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-in fade-in">
      <div className="bg-slate-900 border border-slate-800 rounded-3xl max-w-3xl w-full max-h-[90vh] overflow-y-auto shadow-2xl p-6 space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between pb-4 border-b border-slate-800">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-sky-500 to-indigo-600 flex items-center justify-center text-white shadow-lg shadow-sky-500/20">
              <Github className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-lg font-bold text-white">GitHub Project Names & Launch Ideas</h2>
              <p className="text-xs text-slate-400">
                Curated repository names, descriptions, topic tags, and community metadata.
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-2 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800 transition cursor-pointer"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Names List */}
        <div className="space-y-3">
          <h3 className="text-xs font-semibold uppercase tracking-wider text-slate-400 flex items-center gap-1.5">
            <Sparkles className="w-4 h-4 text-amber-400" />
            Recommended Repository Names
          </h3>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            {repoIdeas.map((idea, index) => (
              <div
                key={index}
                className="p-4 rounded-xl bg-slate-950/70 border border-slate-800/80 hover:border-slate-700 transition flex flex-col justify-between"
              >
                <div>
                  <div className="flex items-center justify-between mb-1.5">
                    <span className="font-mono font-bold text-white text-sm text-sky-400">
                      {idea.name}
                    </span>
                    <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-sky-500/20 text-sky-300">
                      {idea.badge}
                    </span>
                  </div>
                  <p className="text-xs text-slate-400 leading-relaxed mb-3">
                    {idea.tagline}
                  </p>
                </div>

                <div className="flex items-center justify-between pt-2 border-t border-slate-900">
                  <span className="text-[11px] text-slate-500">{idea.highlight}</span>
                  <button
                    onClick={() => copyToClipboard(idea.name, `name-${index}`)}
                    className="flex items-center gap-1 text-xs text-sky-400 hover:text-sky-300 cursor-pointer font-medium"
                  >
                    {copiedKey === `name-${index}` ? (
                      <>
                        <Check className="w-3 h-3 text-emerald-400" />
                        <span className="text-emerald-400">Copied</span>
                      </>
                    ) : (
                      <>
                        <Copy className="w-3 h-3" />
                        <span>Copy Name</span>
                      </>
                    )}
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* GitHub Topics / Tags */}
        <div className="p-4 rounded-xl bg-slate-950/70 border border-slate-800 space-y-3">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-slate-300 flex items-center gap-1.5">
              <Tag className="w-4 h-4 text-purple-400" />
              Recommended GitHub Repository Topics (Tags)
            </span>
            <button
              onClick={() => copyToClipboard(githubTopics.join(' '), 'all-tags')}
              className="text-xs text-purple-400 hover:text-purple-300 cursor-pointer flex items-center gap-1"
            >
              {copiedKey === 'all-tags' ? (
                <>
                  <Check className="w-3 h-3 text-emerald-400" />
                  <span className="text-emerald-400">Copied</span>
                </>
              ) : (
                <>
                  <Copy className="w-3 h-3" />
                  <span>Copy All Tags</span>
                </>
              )}
            </button>
          </div>

          <div className="flex flex-wrap gap-1.5">
            {githubTopics.map((tag) => (
              <span
                key={tag}
                className="px-2.5 py-1 rounded-lg bg-slate-900 border border-slate-800 text-[11px] font-mono text-slate-300"
              >
                #{tag}
              </span>
            ))}
          </div>
        </div>

        {/* Modal Footer */}
        <div className="flex justify-end pt-2">
          <button
            onClick={onClose}
            className="px-5 py-2 text-xs font-semibold bg-slate-800 hover:bg-slate-700 text-white rounded-xl transition cursor-pointer"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
};
