import ElementaryUI
import JavaScriptKit

// The backend URL for admin API calls
// Defaults to `http://api.forsell.dev`, check /docs for OpenAPI spec to explore demo options
let backendURL = "http://api.forsell.dev"

@View
struct ContentView {
    @State var isLoggedIn: Bool = AuthStorage.loadLoginState()

    var body: some View {
        div(.style([
            "min-height": "100vh",
            "background-color": "var(--color-bg, #ffffff)",
            "font-family": "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif",
            "color": "var(--color-text, #1a1a1a)",
        ])) {
            style {
                """
                *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
                :root {
                    --color-bg: #ffffff;
                    --color-bg-secondary: #f8f9fa;
                    --color-border: #dee2e6;
                    --color-text: #1a1a1a;
                    --color-text-secondary: #6c757d;
                    --color-text-muted: #adb5bd;
                    --color-accent: #e85d04;
                    --color-error: #c1121f;
                    --font-display: Georgia, serif;
                }
                @media (prefers-color-scheme: dark) {
                    :root {
                        --color-bg: #0d0d0d;
                        --color-bg-secondary: #1a1a1a;
                        --color-border: #404040;
                        --color-text: #f5f5f5;
                        --color-text-secondary: #a3a3a3;
                        --color-text-muted: #737373;
                        --color-accent: #fb923c;
                        --color-error: #f87171;
                    }
                }
                .stats-grid {
                    display: grid;
                    grid-template-columns: repeat(2, 1fr);
                    gap: 1rem;
                    margin-top: 2.5rem;
                }
                @media (min-width: 640px) {
                    .stats-grid { grid-template-columns: repeat(4, 1fr); }
                }
                .stat-card {
                    border: 1px solid var(--color-border);
                    transition: transform 0.15s ease, box-shadow 0.15s ease, border-color 0.15s ease;
                }
                .stat-card:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 8px 24px rgba(0,0,0,0.08);
                    border-color: var(--color-accent);
                }
                """
            }

            if isLoggedIn {
                DashboardView(isLoggedIn: $isLoggedIn)
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}


