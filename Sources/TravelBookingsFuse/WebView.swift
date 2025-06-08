import SwiftUI
#if canImport(WebKit)
import WebKit
#endif

// the platform-specific View supertype that is needed to adapt legacy UIKit to SwiftUI
#if canImport(UIKit)
private typealias View = UIViewRepresentable
#elseif canImport(AppKit)
private typealias View = NSViewRepresentable
#endif

/// This is a very minimal WebView that can be used as an embedded browser view.
/// It has no address bar or navigation buttons.
/// For a more advanced web component, use http://source.skip.tools/skip-web
struct WebView : View {
    let url: URL
    var enableJavaScript: Bool = true

    #if os(Android)
    // for Android platforms, we take a WebView and wrap it in an AndroidView, which
    // adapts traditional views in a Compose context, and then wrap that in a
    // ComposeView, which integrates it with the SwiftUI view hierarchy
    var body: some View {
        ComposeView { WebContentComposer(url: url, enableJavaScript: enableJavaScript) }
    }
    #else
    // for Darwin platforms, we take a WKWebView and load it using the
    // UIViewRepresentable/NSViewRepresentable system for adapting traditional
    // UIKit views to SwiftUI view hierarchy
    func makeCoordinator() -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = enableJavaScript
        webView.load(URLRequest(url: url))
        return webView
    }

    func update(webView: WKWebView) {
    }

    #if canImport(UIKit)
    func makeUIView(context: Context) -> WKWebView { context.coordinator }
    func updateUIView(_ uiView: WKWebView, context: Context) { update(webView: uiView) }
    #elseif canImport(AppKit)
    func makeNSView(context: Context) -> WKWebView { context.coordinator }
    func updateNSView(_ nsView: WKWebView, context: Context) { update(webView: nsView) }
    #endif
    #endif
}


#if SKIP
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.compose.ui.viewinterop.AndroidView

struct WebContentComposer : ContentComposer {
    let url: URL
    let enableJavaScript: Bool

    @Composable func Compose(context: ComposeContext) {
        AndroidView(factory: { ctx in
            let webView = WebView(ctx)
            let client = WebViewClient()
            webView.webViewClient = client
            webView.settings.javaScriptEnabled = enableJavaScript
            webView.setBackgroundColor(0x000000)
            webView.loadUrl(url.absoluteString)
            return webView
        }, modifier: context.modifier, update: { webView in
        })
    }
}

#endif
