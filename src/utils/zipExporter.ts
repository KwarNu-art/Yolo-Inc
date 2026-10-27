import JSZip from 'jszip';
import { TweakConfig } from '../types/tweak';
import { tweakFiles } from '../data/tweakFiles';

export async function generateAndDownloadZip(config: TweakConfig, repoName = 'TeleTurbo-iOS') {
  const zip = new JSZip();

  // Add all tweak files
  for (const file of tweakFiles) {
    const content = file.getContent(config);
    zip.file(file.path, content);
  }

  // Add .gitignore
  zip.file(
    '.gitignore',
    `# Theos build artifacts
.theos/
_theos/
packages/
*.deb
*.dylib
*.ipa
.DS_Store
build/
`
  );

  // Generate binary zip
  const blob = await zip.generateAsync({ type: 'blob' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `${repoName}.zip`;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}
