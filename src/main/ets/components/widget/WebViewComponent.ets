import web_webview from '@ohos.web.webview';
import router from '@ohos.router';
import ResCacheManager from '../cache/ResCacheManager';
import request from '@ohos.request';

/**
 * 测试组建
 */
@Entry
@Component
export struct WebViewComponent {
  controller: web_webview.WebviewController = new web_webview.WebviewController()
  @State title: string = '';

  aboutToAppear() {
    console.log("===============aboutToAppear")
  }

  aboutToDisappear() {
    console.log("===============aboutToDisappear")
  }

  onPageShow() {
    console.log("===============onPageShow")
  }

  onPageHide() {
    console.log("===============onPageShow")
  }

  build() {
    Column() {
      // WebView
      Web({ src: 'https://www.baidu.com', controller: this.controller })
        .cacheMode(CacheMode.None)
        .onPageBegin((event) => {
          console.log("=============onPageBegin");
        })
        .onPageVisible((event) => {
          console.log("=============onPageVisible");
        })
        .onPageEnd((event) => {
          console.log("=============onPageEnd");
        })
        // .onLoadIntercept((event) => {
        //   // this.controller.loadUrl(event.data.getRequestUrl());
        //   return false;
        // })
        .onInterceptRequest((event) => {
          console.debug(`onInterceptRequest: ${event?.request?.getRequestUrl() ?? ""}`)
          let resp = ResCacheManager.getCacheFromRequest(event?.request);
          if (resp == null) {
            console.debug(`=============miss: ${event?.request?.getRequestUrl() ?? ''}`);
          }
          return resp;
        })
        .onTitleReceive((event) => {
          console.debug(`onTitleReceive: ${event?.title ?? ""}`)
          if (event?.title) {
            this.title = event.title;
          }
        })
        .onErrorReceive((event) => {
          console.debug(`onTitleReceive`, event?.error)
        })
        .onHttpErrorReceive((event) => {
          console.debug(`onHttpErrorReceive`, event?.request?.getRequestUrl() ?? "")
        })
        .onSslErrorEventReceive((event) => {
          console.debug(`onSslErrorEventReceive`, event?.error)
          event.handler.handleConfirm()
        })
        .width("100%")
        .height("100%")
    }
    .width('100%')
    .height('100%')
  }

  onBackPress() {
    if (this.controller.accessBackward()) {
      this.controller.backward()
    } else {
      router.back()
    }
  }
}
