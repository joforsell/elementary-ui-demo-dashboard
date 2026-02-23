import { defineConfig, loadEnv } from "vite";
import swiftWasm from "@elementary-swift/vite-plugin-swift-wasm";

export default defineConfig(({ mode }) => {
  // Load env file based on `mode` in the current working directory.
  // Set the third parameter to '' to load all env regardless of the `VITE_` prefix.
  const env = loadEnv(mode, process.cwd(), '');
  
  return {
    base: "/",
    plugins: [
      swiftWasm({
        useEmbeddedSDK: false,
      }),
    ],
    define: {
      '__DEMO_PASSWORD__': JSON.stringify(env.DEMO_PASSWORD || ''),
    },
  };
});
