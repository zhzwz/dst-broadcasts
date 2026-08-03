import steamworks from 'steamworks.js'

interface WorkshopUpload {
  appId: number
  contentPath: string
  descriptionPath: string
  modinfoPath: string
  previewPath: string
  publishedFileId: bigint
  version: string
}

function readLuaBoolean(text: string, name: string): boolean {
  return new RegExp(`^\\s*${name}\\s*=\\s*true\\s*$`, 'm').test(text)
}

async function readWorkshopTags(modinfoPath: string, version: string): Promise<string[]> {
  const text = await Bun.file(modinfoPath).text()
  const tags = [`version:${version}`]
  const compatible = text.match(/^\s*version_compatible\s*=\s*"([^"]+)"/m)?.[1]
  if (compatible) {
    tags.push(`version_compatible:${compatible}`)
  }

  if (readLuaBoolean(text, 'client_only_mod')) {
    tags.push('client_only_mod')
  } else if (readLuaBoolean(text, 'all_clients_require_mod')) {
    tags.push('all_clients_require_mod')
  } else {
    tags.push('server_only_mod')
  }
  return tags
}

export async function uploadWorkshopItem(upload: WorkshopUpload) {
  const client = steamworks.init(upload.appId)
  const tags = await readWorkshopTags(upload.modinfoPath, upload.version)
  const description = (await Bun.file(upload.descriptionPath).text()).trim()
  if (!description) {
    throw new Error('创意工坊描述不能为空')
  }
  console.log(`Steam 用户: ${client.localplayer.getName()}`)
  console.log(`创意工坊标签: ${tags.join(', ')}`)

  const result = await client.workshop.updateItem(upload.publishedFileId, {
    contentPath: upload.contentPath,
    description,
    previewPath: upload.previewPath,
    tags,
    changeNote: '',
  }, upload.appId).catch((error) => {
    const detail = error instanceof Error ? error.message : String(error)
    throw new Error(
      `Steam Workshop 上传失败：${detail}\n`
      + '请确认同一 Steam 账号未在其他电脑运行游戏，且没有其他 Mod Uploader 或上传任务正在执行。',
      { cause: error },
    )
  })

  if (result.itemId !== upload.publishedFileId) {
    throw new Error('Steam 返回了不匹配的创意工坊项目 ID')
  }
  if (result.needsToAcceptAgreement) {
    throw new Error('需要先接受 Steam Workshop 法律协议')
  }
}
