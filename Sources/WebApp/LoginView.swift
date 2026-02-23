import Foundation
import ElementaryUI
import JavaScriptKit


@View
struct LoginView {
    @Binding var isLoggedIn: Bool

    @State var inputPassword: String = ""
    @State var isLoading: Bool = false
    @State var errorMessage: String? = nil

    var body: some View {
        div {
            div {
                img(.src("https://elementary-swift.github.io/assets/elementary-logo.svg"), .alt("ElementaryUI"))
                    .styles(
                        .width(.px(80)),
                        .height(.auto),
                        .margin(.px(0), .auto, .rem(1.5)),
                        .display(.block)
                    )

                h1 { "Demo dashboard" }
                    .styles(
                        .fontWeight(.regular),
                        .fontSize(.rem(1.75)),
                        .letterSpacing(.em(-0.02)),
                        .textAlign(.center),
                        .margin(.bottom(.rem(0.5)))
                    )

                p { "Enter your password to continue" }
                    .styles(
                        .textAlign(.center),
                        .fontSize(.rem(0.875)),
                        .color(.textMuted),
                        .margin(.bottom(.rem(2.0)))
                    )

                div {
                    label { "Password" }
                        .styles(
                            .display(.block),
                            .fontSize(.rem(0.75)),
                            .fontWeight(.semiBold),
                            .textTransform(.uppercase),
                            .letterSpacing(.em(0.05)),
                            .color(.textMuted),
                            .margin(.bottom(.rem(0.5)))
                        )

                    input(.type(.password), .placeholder("Enter password"))
                        .styles(
                            .width(.percent(100)),
                            .padding(.rem(0.75)),
                            .fontSize(.rem(1.0)),
                            .backgroundColor(.bg),
                            .border(.solid(color: .border)),
                            .borderRadius(.px(8)),
                            .color(.text),
                            .margin(.bottom(.rem(1.0))),
                            .outline(.none)
                        )
                        .bindValue($inputPassword)
                        .onKeyDown { event in
                            if event.key == "Enter", !isLoading, !inputPassword.isEmpty {
                                let password = inputPassword
                                Task { await login(password: password) }
                            }
                        }

                    if let error = errorMessage {
                        p { error }
                            .styles(
                                .fontSize(.rem(0.8125)),
                                .color(.error),
                                .margin(.bottom(.rem(1.0)))
                            )
                    }

                    button { isLoading ? "Signing in..." : "Sign In" }
                        .styles(
                            .width(.percent(100)),
                            .padding(.rem(0.75)),
                            .fontSize(.rem(1.0)),
                            .fontWeight(.medium),
                            .backgroundColor(.text),
                            .color(.bg),
                            .border(.none),
                            .borderRadius(.px(8)),
                            .custom(key: "opacity", value: isLoading ? "0.6" : "1"),
                            .custom(key: "cursor", value: isLoading ? "not-allowed" : "pointer")
                        )
                        .onClick { _ in
                            guard !isLoading, !inputPassword.isEmpty else { return }
                            let password = inputPassword
                            Task { await login(password: password) }
                        }
                }
                .styles(
                    .backgroundColor(.bgSecondary),
                    .border(.solid(color: .border)),
                    .borderRadius(.px(12)),
                    .padding(.rem(1.5))
                )
            }
            .styles(.width(.percent(100)), .maxWidth(.px(380)))
        }
        .styles(
            .minHeight(.vh(100)),
            .display(.flex),
            .alignItems(.center),
            .justifyContent(.center),
            .backgroundColor(.bg),
            .padding(.rem(1.0))
        )
    }

    private func login(password: String) async {
        isLoading = true
        errorMessage = nil

        // Get the demo password from environment
        let demoPassword = JSObject.global.__DEMO_PASSWORD__.string ?? ""
        
        // Check password against environment variable
        if !demoPassword.isEmpty && password == demoPassword {
            isLoading = false
            AuthStorage.saveLoginState(true)
            isLoggedIn = true
        } else {
            isLoading = false
            errorMessage = "Invalid password."
        }
    }
}
