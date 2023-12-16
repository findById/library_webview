import HashMap from '@ohos.util.HashMap';

/**
 * 文件类型
 */
class MimeTypeUtils {
  private _types: HashMap<string, string> = new HashMap<string, string>();

  constructor() {
    this._types.set('.html', 'text/html')
    this._types.set('.js', 'text/javascript')
    this._types.set('.css', 'text/css')
    this._types.set('.svg', 'svg+xml')
    this._types.set('.jpg', 'image/jpeg')
    this._types.set('.png', 'image/png')
    this._types.set('.gif', 'image/gif')
    this._types.set('.ico', 'image/x-icon')
    this._types.set('.json', 'application/json')
    this._types.set('.xml', 'application/xml')
    this._types.set('.pdf', 'application/pdf')
    this._types.set('.zip', 'application/zip')
    this._types.set('.mp3', 'audio/mpeg')
    this._types.set('.mp4', 'video/mp4')
  }

  getMimeType(path: string): string {
    let index = path.lastIndexOf(".");
    let suffix = path.substring(index);

    let mimeType: string = this._types.get(suffix) ?? 'text/html';
    console.debug(`==================${mimeType}, ${path}`)
    return mimeType;
  }
}

const mtu = new MimeTypeUtils();

export default mtu;