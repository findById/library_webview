
/**
 * 离线包配置
 */
export class PackageConfig {
  appId: string
  domain: string
  name: string
  version: string
  url: string
  hash: string

  constructor(appId: string, domain: string, name: string, version: string, url: string, hash: string) {
    this.appId = appId
    this.domain = domain
    this.name = name
    this.version = version
    this.url = url
    this.hash = hash
  }
}