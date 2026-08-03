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
])
