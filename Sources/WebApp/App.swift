import ElementaryUI
import JavaScriptEventLoop

@main
struct App {
  static func main() {
    // Swift's concurrency runtime needs an executor to schedule async work — normally this is
    // provided by the OS (Dispatch on Apple platforms, pthreads elsewhere). In a WebAssembly
    // environment there is no OS thread scheduler, so JavaScriptEventLoop provides one backed
    // by the browser's event loop via JavaScript Promises.
    //
    // Without this call, `Task { }` closures are created but never run: there's nothing to
    // drive them. This must be called before any async work is started, so it goes first in main().
    JavaScriptEventLoop.installGlobalExecutor()
    let app = Application(ContentView())
    app.mount(in: .body)
  }
}
