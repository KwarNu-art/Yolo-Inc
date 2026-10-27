import React, { useState } from 'react';
import {
  Copy,
  Check,
  Download,
  FileCode,
  FileText,
  Search,
  ExternalLink,
  Terminal,
  Code2
} from 'lucide-react';
import { TweakConfig, TweakFile } from '../types/tweak';
import { tweakFiles } from '../data/tweakFiles';

interface Props {
  config: TweakConfig;
  activeFileId: string;
  onSelectFile: (fileId: string) => void;
}

export const CodeViewer: React.FC<Props> = ({ config, activeFileId, onSelectFile }) => {
  const [copied, setCopied] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');

  const currentFile = tweakFiles.find((f) => f.id === activeFileId) || tweakFiles[0];
  const codeContent = currentFile.getContent(config);

  const handleCopy = () => {
    navigator.clipboard.writeText(codeContent);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleDownloadSingle = () => {
    const blob = new Blob([codeContent], { type: 'text/plain;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = currentFile.name;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  };

  const lines = codeContent.split('\n');

  const filteredFiles = tweakFiles.filter((f) =>
    f.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    f.path.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="grid grid-cols-1 lg:grid-cols-12 gap-5 min-h-[640px]">
      {/* File Tree / Sidebar */}
      <div className="lg:col-span-4 bg-slate-900/80 border border-slate-800 rounded-2xl p-4 flex flex-col space-y-3">
        <div className="flex items-center justify-between pb-2 border-b border-slate-800">
          <div className="flex items-center gap-2 text-white font-semibold text-sm">
            <FileCode className="w-4 h-4 text-sky-400" />
            <span>Repository Files</span>
          </div>
          <span className="text-xs px-2 py-0.5 rounded-full bg-slate-800 text-slate-400">
            {tweakFiles.length} files
          </span>
        </div>

        {/* Search */}
        <div className="relative">
          <Search className="w-4 h-4 absolute left-3 top-2.5 text-slate-500" />
          <input
            type="text"
            placeholder="Search tweak files..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full bg-slate-950/80 border border-slate-800 text-slate-200 text-xs rounded-xl pl-9 pr-3 py-2 focus:outline-none focus:border-sky-500"
          />
        </div>

        {/* File List */}
        <div className="flex-1 space-y-1.5 overflow-y-auto max-h-[500px] pr-1">
          {filteredFiles.map((file) => {
            const isActive = file.id === currentFile.id;
            return (
              <button
                key={file.id}
                onClick={() => onSelectFile(file.id)}
                className={`w-full text-left p-2.5 rounded-xl transition flex items-start gap-2.5 cursor-pointer ${
                  isActive
                    ? 'bg-sky-500/15 border border-sky-500/40 text-white shadow-sm'
                    : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/50 border border-transparent'
                }`}
              >
                <div className="mt-0.5">
                  {file.name.endsWith('.x') ? (
                    <Terminal className="w-4 h-4 text-sky-400" />
                  ) : file.name.endsWith('.yml') ? (
                    <Code2 className="w-4 h-4 text-emerald-400" />
                  ) : (
                    <FileText className="w-4 h-4 text-slate-400" />
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-semibold truncate text-slate-200">
                      {file.name}
                    </span>
                    <span className="text-[10px] text-slate-500 font-mono">
                      {file.language}
                    </span>
                  </div>
                  <p className="text-[11px] text-slate-400 truncate mt-0.5">
                    {file.path}
                  </p>
                </div>
              </button>
            );
          })}
        </div>

        {/* Quick Tips */}
        <div className="p-3 rounded-xl bg-slate-950/50 border border-slate-800 text-[11px] text-slate-400 space-y-1">
          <div className="font-semibold text-slate-300 flex items-center gap-1.5">
            <span className="w-2 h-2 rounded-full bg-emerald-400"></span>
            Real-time Compilation Sync
          </div>
          <p>
            Any toggle changed in the Configurator instantly updates the Logos hooks and GitHub workflow in real-time.
          </p>
        </div>
      </div>

      {/* Code Display Area */}
      <div className="lg:col-span-8 bg-slate-950 border border-slate-800 rounded-2xl flex flex-col overflow-hidden shadow-2xl">
        {/* Code Header */}
        <div className="bg-slate-900/90 px-4 py-3 border-b border-slate-800 flex items-center justify-between flex-wrap gap-2">
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-1.5">
              <span className="w-3 h-3 rounded-full bg-red-500/80 inline-block"></span>
              <span className="w-3 h-3 rounded-full bg-amber-500/80 inline-block"></span>
              <span className="w-3 h-3 rounded-full bg-emerald-500/80 inline-block"></span>
            </div>
            <div className="h-4 w-px bg-slate-800"></div>
            <div>
              <span className="text-xs font-mono font-semibold text-white">
                {currentFile.path}
              </span>
              <span className="text-[11px] text-slate-400 ml-2">
                ({lines.length} lines)
              </span>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={handleCopy}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium bg-slate-800 hover:bg-slate-700 text-slate-200 transition cursor-pointer"
            >
              {copied ? (
                <>
                  <Check className="w-3.5 h-3.5 text-emerald-400" />
                  <span className="text-emerald-400">Copied!</span>
                </>
              ) : (
                <>
                  <Copy className="w-3.5 h-3.5" />
                  <span>Copy Code</span>
                </>
              )}
            </button>

            <button
              onClick={handleDownloadSingle}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium bg-sky-600 hover:bg-sky-500 text-white transition cursor-pointer shadow"
            >
              <Download className="w-3.5 h-3.5" />
              <span>Download File</span>
            </button>
          </div>
        </div>

        {/* File Description bar */}
        <div className="bg-slate-900/40 px-4 py-2 border-b border-slate-800/60 text-xs text-slate-400 flex items-center justify-between">
          <span>{currentFile.description}</span>
          <span className="text-[11px] font-mono text-sky-400 uppercase">
            {currentFile.language}
          </span>
        </div>

        {/* Code Content with Line Numbers */}
        <div className="flex-1 p-4 overflow-x-auto overflow-y-auto max-h-[580px] font-mono text-xs leading-relaxed text-slate-300 bg-slate-950">
          <table className="w-full border-collapse">
            <tbody>
              {lines.map((line, index) => (
                <tr key={index} className="hover:bg-slate-900/50">
                  <td className="w-12 select-none text-right pr-4 text-slate-600 border-r border-slate-800/80 font-mono text-[11px]">
                    {index + 1}
                  </td>
                  <td className="pl-4 whitespace-pre font-mono">
                    {/* Basic syntax highlight styling */}
                    <span
                      className={
                        line.startsWith('#') || line.startsWith('//') || line.startsWith('/*') || line.startsWith(' *')
                          ? 'text-slate-500 italic'
                          : line.startsWith('%hook') || line.startsWith('%end') || line.startsWith('%ctor')
                          ? 'text-purple-400 font-bold'
                          : line.includes('static ') || line.includes('void ') || line.includes('BOOL ')
                          ? 'text-sky-300'
                          : line.includes('name:') || line.includes('runs-on:') || line.includes('uses:')
                          ? 'text-amber-300'
                          : 'text-slate-200'
                      }
                    >
                      {line}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
