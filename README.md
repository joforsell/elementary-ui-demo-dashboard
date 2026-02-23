<p align="center">
  <a href="https://elementary.codes">
    <img src="https://elementary-swift.github.io/assets/elementary-logo.svg" width="125px" alt="Elementary Logo">
  </a>
</p>

# ElementaryUI Dashboard Demo

A demonstration web application showcasing [ElementaryUI](https://github.com/elementary-swift/elementary-ui) features with Swift on WebAssembly, powered by [Vite](https://vite.dev/).

This demo includes:
- Simple password-based authentication with localStorage persistence
- Interactive collapsible dashboard sections with animations
- Type-safe CSS styling helpers
- Backend integration examples (fetching stats from a demo API)

## Prerequisites

- Swift 6.2+ with matching Swift SDK for WebAssembly ([swift.org](https://www.swift.org/documentation/articles/wasm-getting-started.html))
- Node.js 22+ ([nodejs.org](https://nodejs.org/en/download))
- wasm-opt (optional, [homebrew](https://formulae.brew.sh/formula/binaryen) or [manual](https://github.com/WebAssembly/binaryen/releases))

## Getting Started

```sh
# Verify Swift toolchain
swift --version
# look for a compiler tag like this: (swift-6.2.3-RELEASE)

# Verify Swift SDK for WebAssembly
swift sdk list
# should contain matching entries, eg: swift-6.2.3-RELEASE_wasm and swift-6.2.3-RELEASE_wasm-embedded

# Install dependencies
npm install
```

## Develop

```sh
# Start development server with hot reload
npm run dev
```

Runs an initial debug build of the WebAssembly app in the browser. Swift files are watched and trigger an instant rebuild/reload on save.

## Deploying

```sh
# Build in release and bundle for deployment
npm run build

# Preview the built web app locally
npm run preview
```

## Demo Mode

This demo includes a simple login system for demonstration purposes:

### Environment Variables

Create a `.env` file in the project root with:

```env
DEMO_PASSWORD=demo123
```

Set `DEMO_PASSWORD` to any string you want. The app will validate login attempts against this password.

### How It Works

- **Simple Authentication**: Enter the password matching `DEMO_PASSWORD` in your `.env` file to log in
- **Login State Persistence**: The app uses localStorage to remember login state across sessions
- **Logout**: Clicking "Sign out" clears the login state from localStorage

**Note**: The password is baked into the JavaScript bundle at build time, so this is only suitable for demos.

## Project Structure

```
elementary-ui-demo/
├── Sources/WebApp/          # Swift source files
│   ├── App.swift           # Main application entry point
│   ├── ContentView.swift   # Root view with login state
│   ├── LoginView.swift     # Login screen
│   ├── DashboardView.swift # Dashboard with collapsible sections
│   ├── AuthState.swift     # Authentication storage helpers
│   ├── FetchRequest.swift  # HTTP request utilities
│   └── StyleHelpers.swift  # Type-safe CSS helpers
├── public/                  # Static assets (images, etc.)
├── .env                     # Environment variables (DEMO_PASSWORD)
├── vite.config.ts          # Vite configuration
└── Package.swift           # Swift package manifest
```

## Static Assets

Place static files (images, fonts, etc.) in the `public/` folder:

```
public/
├── images/
│   └── logo.svg
└── icons/
    └── chevron.svg
```

Reference them with absolute paths:
```swift
img(.src("/images/logo.svg"), .alt("Logo"))
```

## Configuration

The project uses standard Swift SDK for WebAssembly (not Embedded Swift). The [Vite config](vite.config.ts) is configured to inject environment variables at build time.

For all configuration options, visit the plugin's homepage: [vite-plugin-swift-wasm](https://github.com/elementary-swift/vite-plugin-swift-wasm).

## License

[0BSD License](LICENSE) - use it freely with no attribution required.
