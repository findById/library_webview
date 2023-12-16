import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import request from '@ohos.request';
import zlib from '@ohos.zlib';
import { BusinessError } from '@ohos.base';
import fu from '../util/FileUtils';
import { PackageConfig } from '../model/PackageConfig';
import ResCacheManager from './ResCacheManager';

/**
 * 离线缓存下载管理
 */
class ResUpdateManager {
  public checkUpdate(ctx: common.Context, config: PackageConfig, sync: boolean /* true 当次生效, false 下次生效 */): Promise<boolean> {
    let appId = config.appId;
    let domain = config.domain;
    let name = config.name;
    let version = config.version;
    let url = config.url;
    let hash = config.hash;
    console.debug(`==================checkUpdate: ${appId}, ${domain}, ${name}, ${version}, ${url}, ${hash}, ${sync}`)

    ResCacheManager.addAppDomain(appId, domain)

    // 1. 本地是否有离线包
    if (fs.accessSync(fu.getLockFile(appId, version))) {
      console.debug(`==================离线包已存在`)
      return Promise.resolve(true);
    }

    return new Promise<boolean>(async (resolve, _) => {
      // 2. 本地是否有zip离线包
      let tempZipFile = fu.getTempZipFile(appId, version);
      if (fs.accessSync(tempZipFile)) {
        // 2.1 完整性校验
        if ((await fu.getFileMD5(tempZipFile)) == hash) {
          console.debug(`==================离线zip包已存在, 完整性校验通过`)
          if (!sync) { // 非同步更新模式下, 如果本地有下载好的离线zip包, 不处理
            return Promise.resolve(true);
          }

          // 2.2 解压
          if (await this.unzip(appId, version)) {
            resolve(true);
            return;
          }
          console.debug(`==================解压离线失败，删除源文件`)
        } else {
          console.debug(`==================离线zip包已存在, 文件损坏, 删除源文件`)
        }
        // 解压失败后，删除源文件
        fs.rmdirSync(tempZipFile)
      }

      // 3. 下载离线包
      this.download(ctx, config, sync)
        .then((success) => {
          resolve(success)
        })
        .catch((_: BusinessError) => {
          resolve(false)
        });
      return;
    });
  }

  private unzip(appId: string, version: string): Promise<boolean> {
    console.info('unzip: ' + appId);
    // 删除老目录
    fs.rmdirSync(fu.getCacheDir(appId))

    return new Promise<boolean>((resolve, _) => {
      let dir = fu.getCacheDir(appId);
      let zipFile = fu.getTempZipFile(appId, version);

      zlib.decompressFile(zipFile, dir).then(() => {
        console.info('unzip file success: ' + appId);
        // 创建标记文件
        let stream = fs.createStreamSync(fu.getLockFile(appId, version), 'w+');
        stream.write(version);
        stream.flushSync();
        stream.close();

        console.info('============' + fs.readTextSync(fu.getLockFile(appId, version)))
        console.info('==================' + JSON.stringify(fs.listFileSync(dir)))

        // 删除zip包
        fs.rmdir(zipFile)
        resolve(true);
      }).catch((err: BusinessError) => {
        console.error(`unzip file failed, code: ${err.code}, msg: ${err.message}`);
        resolve(false);
      });
    });
  }

  private download(ctx: common.Context, config: PackageConfig, sync: boolean): Promise<boolean> {
    let appId = config.appId
    let version = config.version
    let url = config.url
    let hash = config.hash
    console.info(`download: ${appId}, ${version}, ${url}, ${hash}`);

    return new Promise<boolean>((resolve, reject) => {
      let zipFile = fu.getTempZipFile(appId, version);
      try {
        request.downloadFile(ctx, {
          url: url,
          filePath: zipFile,
        }).then((task: request.DownloadTask) => {
          task.on('progress', (receivedSize: number, totalSize: number) => {
            console.info(`download progress: ${receivedSize}/${totalSize}`);
          })
          task.on('complete', async () => {
            console.info(`download success: ${appId}`);
            // 校验文件是否完整
            if (!fs.accessSync(zipFile)) {
              resolve(false);
              return;
            }
            if ((await fu.getFileMD5(zipFile)) != hash) {
              console.info(`file: ${appId}, ${zipFile}, hash verify failed`);
              // 完整性校验失败，删除源文件
              await fs.rmdir(zipFile)
              resolve(false);
              return;
            }
            // 如果是非同步更新, 直接返回成功, 下次启动时会解压文件
            if (!sync) {
              resolve(true);
              return;
            }

            // 解压文件
            this.unzip(appId, version).then(async (success) => {
              if (success) {
                resolve(true);
                return;
              }
              // 解压失败，删除源文件
              await fs.rmdir(zipFile)
              resolve(false);
            })
          })
        }).catch((err: BusinessError) => {
          console.error(`download file failed, code: ${err.code}, msg: ${err.message}`);
          reject(err)
        });
      } catch (error) {
        let err: BusinessError = error as BusinessError;
        console.error(`download file failed, code: ${err.code}, msg: ${err.message}`);
        reject(err)
      }
    });
  }
}

const manager = new ResUpdateManager();

export default manager