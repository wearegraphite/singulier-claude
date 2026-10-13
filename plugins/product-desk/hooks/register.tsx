import type { Register } from 'claude-code'

import { registerUpdateBand } from './update-band'

export const register: Register = on => {
  registerUpdateBand(on, {
    marketplace: 'singulier',
    repo: 'wearegraphite/singulier-claude',
    manifestPath: 'plugins/product-desk/.claude-plugin/plugin.json',
    // Like every hook of this plugin: nothing outside the workspace folder.
    workspace: { dir: '~/Singulier' },
  })
}
