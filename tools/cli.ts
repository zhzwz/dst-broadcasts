/**
 * CLI 退出辅助。Bun 没有 Bun.exit，只有这里使用 process.exit，
 * 避免各脚本 throw 导致堆栈噪音、退出码含糊。
 */
import process from 'node:process'

export function exit(code: number): never {
  process.exit(code)
}

export function fail(message: string, code = 1): never {
  console.error(message)
  exit(code)
}

/**
 * 跑完显式 exit：成功 0，失败 1。
 * steamworks.js 等原生句柄会卡住事件循环，不能依赖「自然结束」。
 */
export function runMain(main: () => Promise<void>): void {
  void main()
    .then(() => {
      exit(0)
    })
    .catch((error: unknown) => {
      if (error instanceof Error) {
        if (error.message) {
          console.error(error.message)
        }
      } else {
        console.error(error)
      }
      exit(1)
    })
}
