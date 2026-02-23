import Foundation
import JavaScriptKit
import JavaScriptEventLoop

// MARK: - FetchError

enum FetchError: Error {
    /// The body could not be JSON-encoded before sending.
    case encodingFailed
    /// The browser's `fetch` global was not available.
    case fetchUnavailable
    /// The JS Promise for the request or body-reading step could not be created.
    case promiseFailed
    /// The response body could not be decoded into the expected type.
    case decodingFailed
}

// MARK: - FetchResponse

/// The result of a completed `FetchRequest.send()` call.
struct FetchResponse {
    /// The HTTP status code returned by the server (e.g. 200, 401).
    let status: Int
    /// The raw response body as a UTF-8 string.
    let body: String

    /// Decodes the response body as JSON into the given `Decodable` type.
    ///
    /// Throws `FetchError.decodingFailed` if the body is not valid JSON for `T`.
    func decode<T: Decodable>(_ type: T.Type = T.self) throws -> T {
        guard let data = body.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            throw FetchError.decodingFailed
        }
        return decoded
    }
}

// MARK: - FetchRequest

/// A Swift representation of the browser's `RequestInit` options passed to `fetch()`.
///
/// Construct a request and call `send(to:)` to execute it. When a `body` is provided it is
/// JSON-encoded automatically and `Content-Type: application/json` is added to the headers.
struct FetchRequest {
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }

    var method: Method
    var headers: [String: String]
    /// An `Encodable` value to send as the JSON request body. When set, `send(to:)` encodes
    /// it with `JSONEncoder` and automatically adds `Content-Type: application/json`.
    var body: (any Encodable)?

    init(method: Method, headers: [String: String] = [:], body: (any Encodable)? = nil) {
        self.method = method
        self.headers = headers
        self.body = body
    }

    /// Sends the request to `url` and returns a `FetchResponse` with the status and body text.
    ///
    /// All JavaScript bridging is handled internally:
    /// - The body (if any) is JSON-encoded and `Content-Type` is set automatically.
    /// - The browser's `fetch` Promise is bridged to Swift async/await via `JavaScriptEventLoop`.
    /// - The response body is read with `.text()`, preserving the JS `this` binding.
    ///
    /// Throws a `FetchError` for setup failures or a bridging error for network-level failures.
    func send(to url: String) async throws -> FetchResponse {
        // Build the RequestInit object, encoding the body to JSON if present.
        var resolvedHeaders = headers
        var encodedBody: String? = nil
        if let body {
            guard let data = try? JSONEncoder().encode(body),
                  let json = String(data: data, encoding: .utf8) else {
                throw FetchError.encodingFailed
            }
            encodedBody = json
            // Only inject the header if the caller hasn't set it explicitly.
            if resolvedHeaders["Content-Type"] == nil {
                resolvedHeaders["Content-Type"] = "application/json"
            }
        }

        let headersObj = JSObject()
        for (key, value) in resolvedHeaders {
            headersObj[key] = value.jsValue
        }
        let options = JSObject()
        options["method"] = method.rawValue.jsValue
        options["headers"] = headersObj.jsValue
        if let encodedBody {
            options["body"] = encodedBody.jsValue
        }

        // `JSObject.global.fetch` gives us the global `fetch` function as a `JSValue`. We need
        // it as a `JSObject` to call it, but we must NOT use `JSObject.global.fetch.function`
        // and then call that directly — extracting the function loses its JavaScript `this`
        // binding, which causes "Illegal invocation" at runtime. Getting `.object` and then
        // calling it as a JSObject preserves the binding correctly.
        guard let jsFetch = JSObject.global.fetch.object else {
            throw FetchError.fetchUnavailable
        }

        // `jsFetch(...)` returns a `JSValue` wrapping the Promise. We extract `.object`
        // to pass it to `JSPromise`, which bridges the JS Promise to Swift's async/await
        // via the JavaScriptEventLoop package.
        guard let responseObject = jsFetch(url.jsValue, options.jsValue).object,
              let responsePromise = JSPromise(responseObject) else {
            throw FetchError.promiseFailed
        }
        let response = try await responsePromise.value()

        let status = response.status.number.map { Int($0) } ?? 0

        // `response` is a `JSValue` (not a `JSObject`). This is intentional: calling
        // `.text()` via dynamic member lookup on `JSValue` keeps the JavaScript `this`
        // binding intact. If we had called `.object` on the response and then accessed
        // `.text` on the resulting `JSObject`, the function reference would lose its
        // receiver and throw "Illegal invocation" when awaited.
        guard let textObject = response.text().object,
              let textPromise = JSPromise(textObject) else {
            throw FetchError.promiseFailed
        }
        let bodyText = try await textPromise.value()

        return FetchResponse(status: status, body: bodyText.string ?? "")
    }
}
