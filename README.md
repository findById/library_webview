
## HarmonyOS Next Web离线包管理


#### 组件测试代码
```ts
import { WebViewComponent } from '@ohos/library_webview';
import { ResCacheManager } from '@ohos/library_webview';
import { ResUpdateManager } from '@ohos/library_webview';
import { PackageConfig } from '@ohos/library_webview';

@Entry
@Component
struct WebPageIndex {

  aboutToAppear() {
    console.debug('======================WebPageIndex=aboutToAppear')
    // 初始化缓存管理器
    ResCacheManager.init(getContext())
    // 更新本地离线包
    ResUpdateManager.checkUpdate(getContext(), new PackageConfig(
      "appId", "域名", "应用名", "版本号", "离线zip包下载地址", "zip包哈希值"
    ), true)
  }

  build() {
    Column() {
      WebViewComponent()
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```