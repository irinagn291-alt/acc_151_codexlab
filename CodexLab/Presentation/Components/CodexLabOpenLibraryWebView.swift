import SwiftUI
import WebKit

struct CodexLabOpenLibraryWebView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            CodexLabOpenLibraryWebViewRepresentable(url: url)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("Open Library")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
        }
    }
}

struct CodexLabOpenLibraryWebViewRepresentable: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct CodexLabViewAtSourceButton: View {
    let url: URL
    var title: String = "Open Library dossier"
    @State private var showWebView = false

    var body: some View {
        Button {
            showWebView = true
        } label: {
            Label(title, systemImage: "doc.text.magnifyingglass")
        }
        .sheet(isPresented: $showWebView) {
            CodexLabOpenLibraryWebView(url: url)
        }
    }
}
