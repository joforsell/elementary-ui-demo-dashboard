import JavaScriptKit

private let loginStateKey = "isLoggedIn"

/// Simple authentication storage for demo purposes using localStorage.
///
/// ## Security Note for Production Apps:
/// This implementation uses `localStorage` which is **not recommended** for storing
/// sensitive authentication tokens in production applications because:
///
/// - **XSS Vulnerability**: Any JavaScript code (including malicious scripts) can read localStorage
/// - **No Expiration**: Data persists indefinitely until explicitly cleared
/// - **Always Accessible**: Unlike httpOnly cookies, localStorage is always accessible to JavaScript
///
/// ### Better Alternatives for Production:
/// - **httpOnly Cookies** (most secure): Set by server with `HttpOnly; Secure; SameSite=Strict` flags
/// - **Memory Storage**: Store tokens in variables/state (lost on page refresh)
/// - **SessionStorage**: Cleared when tab closes (but still XSS vulnerable)
///
enum AuthStorage {
    static func saveLoginState(_ isLoggedIn: Bool) {
        let value = isLoggedIn ? "true" : "false"
        _ = JSObject.global.localStorage.setItem(loginStateKey.jsValue, value.jsValue)
    }
    
    static func loadLoginState() -> Bool {
        let value = JSObject.global.localStorage.getItem(loginStateKey.jsValue)
        guard let str = value.string else { return false }
        return str == "true"
    }
    
    static func clearLoginState() {
        _ = JSObject.global.localStorage.removeItem(loginStateKey.jsValue)
    }
}
