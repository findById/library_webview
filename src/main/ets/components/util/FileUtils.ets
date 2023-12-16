import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import Hash from '@ohos.file.hash';

/**
 * 文件目录操作
 */
class FileUtils {
  _cacheRootDir: string = ''; // 本地缓存根目录

  init(ctx: common.Context) {
    this._cacheRootDir = ctx.filesDir + '/web-caches';
    this.createFolder(this._cacheRootDir + '/temp')
  }

  /**
   * 本地缓存目录
   */
  getCacheDir(appId: string) {
    let dir = this._cacheRootDir + '/' + appId + '.localhost.dir';
    this.createFolder(dir)
    return dir;
  }

  /**
   * 离线包下载临时缓存目录
   */
  getTempZipFile(appId: string, version: string) {
    let file = this._cacheRootDir + '/temp/' + appId + "_" + version + '.zip';
    this.createParentFile(file)
    return file;
  }

  /**
   * 离线包解压后，标记文件
   */
  getLockFile(appId: string, version: string) {
    return this.getCacheDir(appId) + '/.lock_' + version;
  }

  /**
   * 文件夹MD5值
   */
  getFileMD5(path: string): Promise<string> {
    return new Promise<string>(async (resolve, _) => {
      Hash.hash(path, "md5").then((str) => {
        resolve(str)
      }).catch(() => {
        resolve('')
      })
    });
  }

  /**
   * 文件夹SHA256值
   */
  getFileSHA256(path: string): Promise<string> {
    return new Promise<string>(async (resolve, _) => {
      Hash.hash(path, "md5").then((str) => {
        resolve(str)
      }).catch(() => {
        resolve('')
      })
    });
  }

  /**
   * 创建文件夹
   */
  createFolder(path: string) {
    this.createParentFile(path)
    if (!fs.accessSync(path)) {
      fs.mkdirSync(path);
    }
  }

  /**
   * 创建父文件夹
   */
  createParentFile(path: string) {
    if (!path) {
      return
    }
    try {
      let parent = path.substring(0, path.lastIndexOf('/'))
      if (!fs.accessSync(parent)) {
        this.createParentFile(parent)
        fs.mkdirSync(parent);
      }
    } catch (e) {
      console.error(e)
    }
  }
}

const manager = new FileUtils();

export default manager