#!/usr/bin/env bun
/** 运行 scripts/test/ 下全部 *.test.lua */
import { Glob } from 'bun'
import { exit, fail, runMain } from './cli'

runMain(async () => {
  const testDir = `${import.meta.dir}/../scripts/test`
  const tests = (await Array.fromAsync(
    new Glob('*.test.lua').scan({ cwd: testDir }),
  )).sort()

  if (tests.length === 0) {
    fail('未找到 scripts/test/*.test.lua')
  }

  let failed = 0
  for (const rel of tests) {
    const path = `${testDir}/${rel}`
    const proc = Bun.spawn(['lua', path], {
      stdout: 'inherit',
      stderr: 'inherit',
    })
    const code = await proc.exited
    if (code !== 0) {
      failed += 1
      console.error(`FAIL ${rel} (exit ${code})`)
    }
  }

  if (failed > 0) {
    fail(`${failed}/${tests.length} 个测试失败`)
  }
  console.log(`${tests.length} 个测试通过`)
  exit(0)
})
