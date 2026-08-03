import zhzwz from '@zhzwz/eslint-config'

export default zhzwz({
  // 启用 cspell 拼写检查
  cspellConfigFile: new URL('./cspell.config.yaml', import.meta.url),
}).then(configs => [
  ...configs,
  {
    rules: {
      'no-console': 'off',
    },
  },
  {
    files: ['**/.luarc.json'],
    rules: {
      'jsonc/sort-array-values': ['error', {
        pathPattern: '^diagnostics\\.globals$',
        order: { type: 'asc' },
      }],
    },
  },
])
