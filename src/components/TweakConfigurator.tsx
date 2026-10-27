import React, { useState } from 'react';
import {
  Zap,
  Flame,
  Snowflake,
  ShieldAlert,
  Cpu,
  Layers,
  Sparkles,
  Sliders,
  CheckCircle2,
  Clock,
  Smartphone,
  EyeOff,
  Keyboard,
  RefreshCw,
  FolderTree
} from 'lucide-react';
import { TweakConfig } from '../types/tweak';

interface Props {
  config: TweakConfig;
  onChange: (newConfig: TweakConfig) => void;
  onOpenCodeView: (fileId: string) => void;
}

export const TweakConfigurator: React.FC<Props> = ({ config, onChange, onOpenCodeView }) => {
  const [selectedPreset, setSelectedPreset] = useState<string>('extreme');

  const applyPreset = (presetKey: string) => {
    setSelectedPreset(presetKey);
    if (presetKey === 'extreme') {
      onChange({
        ...config,
        extremeMode: true,
        backgroundFreezer: true,
        freezeMethod: 'hybrid',
        storyStripper: true,
        lottieStripper: true,
        reactionStripper: true,
        blurBypass: true,
        typingZeroLag: true,
        qosVipElevation: true,
        thermalThrottleShield: true,
        aggressiveRamPurge: true,
        ramPurgeIntervalMinutes: 5,
        sqliteVacuum: true,
        proMotionClampIdle: true,
      });
    } else if (presetKey === 'cool') {
      onChange({
        ...config,
        extremeMode: true,
        backgroundFreezer: true,
        freezeMethod: 'sigstop',
        storyStripper: true,
        lottieStripper: true,
        reactionStripper: true,
        blurBypass: true,
        typingZeroLag: true,
        qosVipElevation: false,
        thermalThrottleShield: true,
        aggressiveRamPurge: true,
        ramPurgeIntervalMinutes: 3,
        sqliteVacuum: true,
        proMotionClampIdle: true,
      });
    } else if (presetKey === 'typing') {
      onChange({
        ...config,
        extremeMode: true,
        backgroundFreezer: false,
        storyStripper: true,
        lottieStripper: false,
        reactionStripper: true,
        blurBypass: false,
        typingZeroLag: true,
        qosVipElevation: true,
        thermalThrottleShield: true,
        aggressiveRamPurge: true,
        ramPurgeIntervalMinutes: 10,
        sqliteVacuum: true,
        proMotionClampIdle: false,
      });
    } else if (presetKey === 'potato') {
      onChange({
        ...config,
        extremeMode: true,
        backgroundFreezer: true,
        freezeMethod: 'hybrid',
        storyStripper: true,
        lottieStripper: true,
        reactionStripper: true,
        blurBypass: true,
        typingZeroLag: true,
        qosVipElevation: true,
        thermalThrottleShield: true,
        aggressiveRamPurge: true,
        ramPurgeIntervalMinutes: 2,
        sqliteVacuum: true,
        proMotionClampIdle: true,
      });
    }
  };

  const updateField = <K extends keyof TweakConfig>(key: K, value: TweakConfig[K]) => {
    onChange({ ...config, [key]: value });
  };

  return (
    <div className="space-y-6">
      {/* Top Banner Alert */}
      <div className="bg-gradient-to-r from-sky-950/80 via-slate-900 to-indigo-950/80 border border-sky-500/30 rounded-2xl p-5 shadow-xl backdrop-blur-md">
        <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-xl bg-sky-500/20 border border-sky-400/40 flex items-center justify-center text-sky-400 shadow-inner">
              <Zap className="w-6 h-6 animate-pulse" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h2 className="text-xl font-bold text-white tracking-tight">TeleTurbo Engine Optimizer</h2>
                <span className="px-2.5 py-0.5 text-xs font-semibold bg-emerald-500/20 text-emerald-400 border border-emerald-500/40 rounded-full">
                  v1.0.0 Active
                </span>
              </div>
              <p className="text-sm text-slate-300 mt-0.5">
                Engineered specifically to cure Telegram iOS phone overheating, freezing screen, input typing lag, and background resource competition.
              </p>
            </div>
          </div>
          <button
            onClick={() => onOpenCodeView('tweak_x')}
            className="flex items-center gap-2 px-4 py-2 text-xs font-semibold bg-sky-600 hover:bg-sky-500 text-white rounded-xl shadow-lg shadow-sky-600/30 transition cursor-pointer"
          >
            <FolderTree className="w-4 h-4" />
            Inspect Generated Tweak.x
          </button>
        </div>
      </div>

      {/* Preset Profiles */}
      <div>
        <div className="flex items-center justify-between mb-3">
          <h3 className="text-sm font-semibold uppercase tracking-wider text-slate-400 flex items-center gap-2">
            <Sliders className="w-4 h-4 text-sky-400" />
            Optimization Profiles
          </h3>
          <span className="text-xs text-slate-400">Click a preset to auto-tune all hooks</span>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          <button
            onClick={() => applyPreset('extreme')}
            className={`p-4 rounded-xl border text-left transition relative cursor-pointer ${
              selectedPreset === 'extreme'
                ? 'bg-sky-950/70 border-sky-400 shadow-lg shadow-sky-500/20'
                : 'bg-slate-900/60 border-slate-800 hover:border-slate-700'
            }`}
          >
            <div className="flex items-center justify-between mb-2">
              <span className="p-2 rounded-lg bg-sky-500/20 text-sky-400">
                <Zap className="w-5 h-5" />
              </span>
              {selectedPreset === 'extreme' && (
                <CheckCircle2 className="w-4 h-4 text-sky-400" />
              )}
            </div>
            <div className="font-semibold text-white text-sm">24/7 Apex Focus</div>
            <div className="text-xs text-slate-400 mt-1 leading-relaxed">
              Full background app freeze, VIP CPU QoS, 0ms typing response, zero heat.
            </div>
          </button>

          <button
            onClick={() => applyPreset('cool')}
            className={`p-4 rounded-xl border text-left transition relative cursor-pointer ${
              selectedPreset === 'cool'
                ? 'bg-indigo-950/70 border-indigo-400 shadow-lg shadow-indigo-500/20'
                : 'bg-slate-900/60 border-slate-800 hover:border-slate-700'
            }`}
          >
            <div className="flex items-center justify-between mb-2">
              <span className="p-2 rounded-lg bg-indigo-500/20 text-indigo-400">
                <Snowflake className="w-5 h-5" />
              </span>
              {selectedPreset === 'cool' && (
                <CheckCircle2 className="w-4 h-4 text-indigo-400" />
              )}
            </div>
            <div className="font-semibold text-white text-sm">Cool Phone & Battery</div>
            <div className="text-xs text-slate-400 mt-1 leading-relaxed">
              Max thermal throttling defense, aggressive 3-min RAM flush, blur bypass.
            </div>
          </button>

          <button
            onClick={() => applyPreset('typing')}
            className={`p-4 rounded-xl border text-left transition relative cursor-pointer ${
              selectedPreset === 'typing'
                ? 'bg-emerald-950/70 border-emerald-400 shadow-lg shadow-emerald-500/20'
                : 'bg-slate-900/60 border-slate-800 hover:border-slate-700'
            }`}
          >
            <div className="flex items-center justify-between mb-2">
              <span className="p-2 rounded-lg bg-emerald-500/20 text-emerald-400">
                <Keyboard className="w-5 h-5" />
              </span>
              {selectedPreset === 'typing' && (
                <CheckCircle2 className="w-4 h-4 text-emerald-400" />
              )}
            </div>
            <div className="font-semibold text-white text-sm">Instant Keyboard & Chat</div>
            <div className="text-xs text-slate-400 mt-1 leading-relaxed">
              Bypasses text layout re-measure loops, direct network socket prioritization.
            </div>
          </button>

          <button
            onClick={() => applyPreset('potato')}
            className={`p-4 rounded-xl border text-left transition relative cursor-pointer ${
              selectedPreset === 'potato'
                ? 'bg-amber-950/70 border-amber-400 shadow-lg shadow-amber-500/20'
                : 'bg-slate-900/60 border-slate-800 hover:border-slate-700'
            }`}
          >
            <div className="flex items-center justify-between mb-2">
              <span className="p-2 rounded-lg bg-amber-500/20 text-amber-400">
                <Layers className="w-5 h-5" />
              </span>
              {selectedPreset === 'potato' && (
                <CheckCircle2 className="w-4 h-4 text-amber-400" />
              )}
            </div>
            <div className="font-semibold text-white text-sm">Potato iPhone Mode</div>
            <div className="text-xs text-slate-400 mt-1 leading-relaxed">
              Strips 100% of Telegram bloat: stories, Lottie animations, particle effects.
            </div>
          </button>
        </div>
      </div>

      {/* Granular Tweak Modules */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
        {/* Module 1: CPU & System Scheduling */}
        <div className="bg-slate-900/70 border border-slate-800 rounded-2xl p-5 space-y-4">
          <div className="flex items-center gap-2.5 pb-3 border-b border-slate-800 text-sky-400 font-semibold">
            <Cpu className="w-5 h-5" />
            <span>Process & Background Management</span>
          </div>

          {/* Toggle: Background Freezer */}
          <div className="flex items-start justify-between gap-4 p-3 rounded-xl bg-slate-950/60 border border-slate-800/80">
            <div>
              <div className="font-medium text-white text-sm flex items-center gap-2">
                Auto-Freeze Background Apps
                <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded bg-sky-500/20 text-sky-300">
                  Core Solution
                </span>
              </div>
              <p className="text-xs text-slate-400 mt-1">
                When Telegram opens, sends <code className="text-sky-300">SIGSTOP</code> to non-essential processes so your iPhone gives 100% CPU to Telegram only. Resumes instantly when exiting.
              </p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer shrink-0 mt-1">
              <input
                type="checkbox"
                checked={config.backgroundFreezer}
                onChange={(e) => updateField('backgroundFreezer', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-slate-800 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-sky-500"></div>
            </label>
          </div>

          {/* Toggle: VIP QoS Thread Elevation */}
          <div className="flex items-start justify-between gap-4 p-3 rounded-xl bg-slate-950/60 border border-slate-800/80">
            <div>
              <div className="font-medium text-white text-sm">VIP CPU Scheduling & QoS Boost</div>
              <p className="text-xs text-slate-400 mt-1">
                Sets process priority to <code className="text-sky-300">nice(-20)</code> and Main Thread to <code className="text-sky-300">QOS_CLASS_USER_INTERACTIVE</code>. Eliminates UI thread stalls.
              </p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer shrink-0 mt-1">
              <input
                type="checkbox"
                checked={config.qosVipElevation}
                onChange={(e) => updateField('qosVipElevation', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-slate-800 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-sky-500"></div>
            </label>
          </div>

          {/* Toggle: Zero-Lag Typing */}
          <div className="flex items-start justify-between gap-4 p-3 rounded-xl bg-slate-950/60 border border-slate-800/80">
            <div>
              <div className="font-medium text-white text-sm flex items-center gap-2">
                Zero-Lag Keyboard & Chat Input
                <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded bg-emerald-500/20 text-emerald-300">
                  User Fix
                </span>
              </div>
              <p className="text-xs text-slate-400 mt-1">
                Disables recursive autolayout recalculations in <code className="text-sky-300">ChatTextInputNodeView</code>. Instant typing without keyboard freeze or delayed character draw.
              </p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer shrink-0 mt-1">
              <input
                type="checkbox"
                checked={config.typingZeroLag}
                onChange={(e) => updateField('typingZeroLag', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-slate-800 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-sky-500"></div>
            </label>
          </div>
        </div>

        {/* Module 2: Anti-Thermal & Bloat Stripper */}
        <div className="bg-slate-900/70 border border-slate-800 rounded-2xl p-5 space-y-4">
          <div className="flex items-center gap-2.5 pb-3 border-b border-slate-800 text-rose-400 font-semibold">
            <Flame className="w-5 h-5" />
            <span>Thermal Defense & Bloat Stripper</span>
          </div>

          {/* Toggle: Thermal Throttle Shield */}
          <div className="flex items-start justify-between gap-4 p-3 rounded-xl bg-slate-950/60 border border-slate-800/80">
            <div>
              <div className="font-medium text-white text-sm flex items-center gap-2">
                Anti-Thermal Overheating Shield
                <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded bg-rose-500/20 text-rose-300">
                  Stops Heat
                </span>
              </div>
              <p className="text-xs text-slate-400 mt-1">
                Monitors <code className="text-sky-300">NSProcessInfoThermalState</code>. Automatically throttles background prefetching and clamps idle loops when phone begins warming up.
              </p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer shrink-0 mt-1">
              <input
                type="checkbox"
                checked={config.thermalThrottleShield}
                onChange={(e) => updateField('thermalThrottleShield', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-slate-800 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-sky-500"></div>
            </label>
          </div>

          {/* Toggle: Stories Stripper */}
          <div className="flex items-start justify-between gap-4 p-3 rounded-xl bg-slate-950/60 border border-slate-800/80">
            <div>
              <div className="font-medium text-white text-sm">Telegram Stories Stripper</div>
              <p className="text-xs text-slate-400 mt-1">
                Completely blocks <code className="text-sky-300">PeerStoriesNode</code>. Saves over 250MB RAM and stops heavy background video stories caching.
              </p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer shrink-0 mt-1">
              <input
                type="checkbox"
                checked={config.storyStripper}
                onChange={(e) => updateField('storyStripper', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-slate-800 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-sky-500"></div>
            </label>
          </div>

          {/* Toggle: Lottie & Reaction Stripper */}
          <div className="flex items-start justify-between gap-4 p-3 rounded-xl bg-slate-950/60 border border-slate-800/80">
            <div>
              <div className="font-medium text-white text-sm">Lottie & Animated Stickers Throttle</div>
              <p className="text-xs text-slate-400 mt-1">
                Renders stickers as lightweight static cached previews. Prevents RLottie 60FPS vector calculation spikes that cause screen freezes.
              </p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer shrink-0 mt-1">
              <input
                type="checkbox"
                checked={config.lottieStripper}
                onChange={(e) => updateField('lottieStripper', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-slate-800 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-sky-500"></div>
            </label>
          </div>

          {/* Toggle: Blur Bypass */}
          <div className="flex items-start justify-between gap-4 p-3 rounded-xl bg-slate-950/60 border border-slate-800/80">
            <div>
              <div className="font-medium text-white text-sm">GPU Blur & Vibrancy Bypass</div>
              <p className="text-xs text-slate-400 mt-1">
                Replaces costly Metal Gaussian blur passes with fast opaque tinted layers. Reduces GPU drawing load by 35%.
              </p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer shrink-0 mt-1">
              <input
                type="checkbox"
                checked={config.blurBypass}
                onChange={(e) => updateField('blurBypass', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-slate-800 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-sky-500"></div>
            </label>
          </div>
        </div>
      </div>

      {/* Module 3: Memory & Target Architecture */}
      <div className="bg-slate-900/70 border border-slate-800 rounded-2xl p-5">
        <div className="flex items-center gap-2.5 pb-3 border-b border-slate-800 text-purple-400 font-semibold mb-4">
          <Smartphone className="w-5 h-5" />
          <span>RAM Purge Engine & Build Settings</span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {/* Periodic RAM Purge */}
          <div className="p-4 rounded-xl bg-slate-950/60 border border-slate-800/80 space-y-2">
            <div className="flex items-center justify-between">
              <span className="text-xs font-semibold text-slate-300">Periodic RAM Purge</span>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  checked={config.aggressiveRamPurge}
                  onChange={(e) => updateField('aggressiveRamPurge', e.target.checked)}
                  className="sr-only peer"
                />
                <div className="w-9 h-5 bg-slate-800 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-purple-500"></div>
              </label>
            </div>
            <p className="text-[11px] text-slate-400">
              Triggers memory warning notification every {config.ramPurgeIntervalMinutes} mins to flush decoded image textures from RAM.
            </p>
            {config.aggressiveRamPurge && (
              <div className="pt-2">
                <div className="flex justify-between text-xs text-slate-300 mb-1">
                  <span>Purge Interval:</span>
                  <span className="font-semibold text-purple-400">{config.ramPurgeIntervalMinutes} minutes</span>
                </div>
                <input
                  type="range"
                  min="2"
                  max="30"
                  value={config.ramPurgeIntervalMinutes}
                  onChange={(e) => updateField('ramPurgeIntervalMinutes', Number(e.target.value))}
                  className="w-full h-1.5 bg-slate-800 rounded-lg appearance-none cursor-pointer accent-purple-500"
                />
              </div>
            )}
          </div>

          {/* Target Architecture */}
          <div className="p-4 rounded-xl bg-slate-950/60 border border-slate-800/80 space-y-2">
            <span className="text-xs font-semibold text-slate-300 block">Package Architecture</span>
            <p className="text-[11px] text-slate-400">
              Choose target jailbreak environment or standalone sideloading package.
            </p>
            <select
              value={config.targetArchitecture}
              onChange={(e) => updateField('targetArchitecture', e.target.value as any)}
              className="w-full bg-slate-900 border border-slate-700 text-white rounded-lg px-3 py-2 text-xs focus:outline-none focus:border-sky-500 cursor-pointer"
            >
              <option value="both">Both Rootless & Rootful (.deb + .ipa)</option>
              <option value="rootless">Rootless Only (Dopamine, palera1n, iOS 15-17+)</option>
              <option value="rootful">Rootful Only (Legacy checkra1n)</option>
            </select>
          </div>

          {/* Minimum iOS Version */}
          <div className="p-4 rounded-xl bg-slate-950/60 border border-slate-800/80 space-y-2">
            <span className="text-xs font-semibold text-slate-300 block">Minimum iOS Version</span>
            <p className="text-[11px] text-slate-400">
              Target minimum SDK requirement for clang / theos compilation.
            </p>
            <select
              value={config.targetIosMin}
              onChange={(e) => updateField('targetIosMin', e.target.value)}
              className="w-full bg-slate-900 border border-slate-700 text-white rounded-lg px-3 py-2 text-xs focus:outline-none focus:border-sky-500 cursor-pointer"
            >
              <option value="15.0">iOS 15.0+ (Universal Recommended)</option>
              <option value="16.0">iOS 16.0+</option>
              <option value="17.0">iOS 17.0+</option>
            </select>
          </div>
        </div>
      </div>
    </div>
  );
};
