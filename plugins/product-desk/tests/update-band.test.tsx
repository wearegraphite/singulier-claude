import { expect, test } from 'claude-code/testing'
import type { On } from 'claude-code'

const SURFACES = ['terminal', 'desktop'] as const
const BAND = {
  plugin: 'product-desk',
  component: 'AbovePrompt',
  props: { hasSurvey: false, isWorking: false, maxRows: 10, bodyColumns: 100 },
  viewport: { columns: 120, rows: 30 },
} as const

/** The engine beneath the plugin: a published version and where the session runs. */
function engine(on: On, published: string, root: string) {
  on('http.fetch', () => ({ value: { status: 200, ok: true, headers: {}, text: `{"version":"${published}"}` } }))
  on('fs.read', () => ({ value: '{"name":"product-desk","version":"0.7.0"}' }))
  on('env.get', ($, e) => ({ value: e.name === 'HOME' ? '/Users/u' : undefined }))
  on('session.root', () => ({ value: root }))
  on('ui.render', ($, e) => {
    const { Box } = $.ui.resolve(e)
    return <Box />
  })
}

for (const surface of SURFACES) {
  test(`${surface}: a newer version inside the workspace shows the update band`, async ($, on) => {
    engine(on, '0.8.0', '/Users/u/Singulier/projet')
    await (await $.ui.mount({ ...BAND, surface })).unmount()
    const ui = await $.ui.mount({ ...BAND, surface })
    expect(await ui.find({ type: 'Text', text: /0\.8\.0 disponible/ })).toBeDefined()
    expect(await ui.find({ type: 'Button', label: 'Mettre à jour' })).toBeDefined()
    await ui.unmount()
  })

  test(`${surface}: outside the workspace the band stays silent`, async ($, on) => {
    engine(on, '0.8.0', '/Users/u/autre-projet')
    await (await $.ui.mount({ ...BAND, surface })).unmount()
    const ui = await $.ui.mount({ ...BAND, surface })
    expect(await ui.find({ type: 'Text', text: /disponible/ })).toBeUndefined()
    await ui.unmount()
  })

  test(`${surface}: up to date, no band`, async ($, on) => {
    engine(on, '0.7.0', '/Users/u/Singulier')
    await (await $.ui.mount({ ...BAND, surface })).unmount()
    const ui = await $.ui.mount({ ...BAND, surface })
    expect(await ui.find({ type: 'Text', text: /disponible/ })).toBeUndefined()
    await ui.unmount()
  })
}
