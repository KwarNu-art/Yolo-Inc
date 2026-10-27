export interface TweakConfig {
  extremeMode: boolean;
  backgroundFreezer: boolean;
  freezeMethod: 'sigstop' | 'assertion' | 'hybrid';
  storyStripper: boolean;
  lottieStripper: boolean;
  reactionStripper: boolean;
  blurBypass: boolean;
  typingZeroLag: boolean;
  qosVipElevation: boolean;
  thermalThrottleShield: boolean;
  aggressiveRamPurge: boolean;
  ramPurgeIntervalMinutes: number;
  sqliteVacuum: boolean;
  proMotionClampIdle: boolean;
  inAppSettingsMenu: boolean;
  targetArchitecture: 'rootless' | 'rootful' | 'both';
  targetIosMin: string;
}

export interface TweakFile {
  id: string;
  name: string;
  path: string;
  language: string;
  description: string;
  getContent: (config: TweakConfig) => string;
}

export interface BenchmarkMetrics {
  stockRamMB: number;
  turboRamMB: number;
  stockCpuPercent: number;
  turboCpuPercent: number;
  stockThermalTempC: number;
  turboThermalTempC: number;
  stockInputLagMs: number;
  turboInputLagMs: number;
  stockBatteryDrainPerHour: number;
  turboBatteryDrainPerHour: number;
  stockFpsDropRate: number;
  turboFpsDropRate: number;
}
