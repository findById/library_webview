import HashMap from '@ohos.util.HashMap';
import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import uri from '@ohos.uri';
import fu from '../util/FileUtils';
import mtu from '../util/MimeTypeUtils';
import ResUpdateManager from './ResUpdateManager';
import { PackageConfig } from '../model/PackageConfig';

/**
 * 缓存管理
 */
class ResCacheManager {
  private domainMapped: HashMap<string, string> = new HashMap<string, string>();
  private initial = false;

  public init(ctx: common.Context) {
    if (this.initial) {
      return
    }
    console.debug('=======================ResCacheManager init')
    fu.init(ctx)

    this.initial = true
  }

  public checkUpdate(ctx: common.Context, config: PackageConfig, sync: boolean /* true 当次生效, false 下次生效 */): Promise<boolean> {

    this.domainMapped.set(config.domain, config.appId)
    console.debug(`=======================addAppDomain: ${config.domain}, ${config.appId}`)

    return ResUpdateManager.checkUpdate(ctx, config, sync)
  }

  public getCacheFromRequest(request: WebResourceRequest) {
    console.debug(`getCacheFromRequest: ${request.getRequestUrl() ?? ""}`);

    let temp = new uri.URI(request.getRequestUrl())

    // for test start (请使用合适项目的目录映射逻辑)
    let appId = this.domainMapped.get(temp.host);
    console.debug('============================appId: ' + appId + ', ' + temp.host)
    if (!appId) {
      return null;
    }
    // for test end

    let path = fu.getCacheDir(appId) + temp.path
    if (temp.path.endsWith("/")) {
      if (fs.accessSync(path + 'index.html')) {
        path += 'index.html'
      } else if (fs.accessSync(path + 'index.htm')) {
        path += 'index.htm'
      } else {
        return null
      }
    }

    console.debug(`path: ${path}, ${fs.accessSync(path)}`);

    if (!fs.accessSync(path)) {
      return null;
    }

    let data = fs.readTextSync(path)

    let resp = new WebResourceResponse();

    resp.setResponseData(data);
    resp.setResponseEncoding("utf-8");
    resp.setResponseMimeType(mtu.getMimeType(path));
    resp.setResponseCode(200);
    resp.setReasonMessage('OK');

    return resp;
  }

  public clearCache(appId: string) {
    let path = fu.getCacheDir(appId)
    if (fs.accessSync(path)) {
      fs.rmdirSync(path)
    }
  }
}

const manager = new ResCacheManager();

export default manager