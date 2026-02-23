<p align="center">
  <a href="https://elementary.codes">
    <img src="https://elementary-swift.github.io/assets/elementary-logo.svg" width="125px" alt="Elementary Logo">
  </a>
</p>

# Minimal Vite Starter for ElementaryUI

A starter template for building web applications with [ElementaryUI](https://github.com/elementary-swift/elementary-ui) powered by [Vite](https://vite.dev/).

Click **Use this template** on GitHub or check the [docs](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template) about using templates.

You can use [degit](https://github.com/Rich-Harris/degit) to scaffold a local project.
```sh
npx degit elementary-swift/starter-vite my-swift-web-app
cd my-swift-web-app
```

<p align="center">
  <img src="https://elementary-swift.github.io/assets/vite-starter-split-screen.gif" alt="Elementary Demo Split Screen">
</p>

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

## Configuration

The template comes with a [Vite config](vite.config.ts) that uses *Embedded Swift* for release builds.

```ts
// vite.config.ts
import { defineConfig } from "vite";
import swiftWasm from "@elementary-swift/vite-plugin-swift-wasm";

export default defineConfig({
  plugins: [
    swiftWasm({
      useEmbeddedSDK: true,
    }),
  ],
});
```

For all configuration options, visit the plugin's homepage: [vite-plugin-swift-wasm](https://github.com/elementary-swift/vite-plugin-swift-wasm).

## License

[0BSD License](LICENSE) - use it freely with no attribution required.
