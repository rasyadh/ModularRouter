# ModularRouter

A lightweight, modular, and Swift 6-concurrent-safe routing system for SwiftUI **iOS apps**.

## 📦 Overview

`ModularRouter` enables feature-based routing with support for:

- 🧩 Modular route registration (`RoutePatternProvider`)
- 🔐 Guard mechanism via `RouteGuard` + `RouteGuardResult`
- 🧵 Full Swift Concurrency + `Sendable` safety
- 🔁 Redirect and fallback route support
- 🧭 Deep linking with path + query decoding (`RouteParameters`)
- 📚 Built-in support for `NavigationStack` (`Router.path`)
- ✅ iOS 16+ support, SwiftUI-compatible

---

## 🚀 Getting Started (iOS)

### 1. Define `AppRoute` in Your Feature

```swift
enum SettingsRoute: AppRoute {
    case main
    case detail(id: Int)

    var path: String {
        switch self {
        case .main: return "/settings"
        case .detail(let id): return "/settings/\(id)"
        }
    }
    
    var pattern: String {
        switch self {
        case .main: return "/settings"
        case .detail: return "/settings/:id"
        }
    }
}
```

### 2. Provide RoutePatterns via `RoutePatternProvider`

```swift
struct SettingsRouteProvider: RoutePatternProvider {
    static var routePatterns: [RoutePattern] {
        [
            RoutePattern(pattern: "/settings") { _ in
                .wrapped(WrappedAppRoute(SettingsRoute.main))
            },
            RoutePattern(pattern: "/settings/:id") { params in
                guard let id = params.int("id") else { return nil }
                return .wrapped(WrappedAppRoute(SettingsRoute.detail(id: id)))
            }
        ]
    }
}
```

### 3. Register Routes (and optional Guards) in the Host App

```swift
try RouteRegistry.shared.register(SettingsRouteProvider.routePatterns[0])
try RouteRegistry.shared.register(SettingsRouteProvider.routePatterns[1], guard: SettingsDetailGuard())
```

## Navigation Example

```swift
let router = Router()
await router.navigate(to: .wrapped(WrappedAppRoute(SettingsRoute.detail(id: 12))))
```

Use .go(to:) for fire-and-forget or .navigate(to:) if awaiting result is needed.

## 🔐 Guard Support Example

```swift
struct SettingsDetailGuard: RouteGuard {
    func shouldAllow(route: any AppRoute, parameters: RouteParameters) async -> RouteGuardResult {
        if parameters.int("id") == 0 {
            return .deny
        } else {
            return .allow
        }
    }
}
```

Return .redirect(to:) to reroute dynamically.

## 🔍 Deep Linking Example

```swift
let route = await RouteParser.parse(path: "/settings/99")

switch route {
case .wrapped(let wrapped):
    print("Matched route:", wrapped.path)
case .notFound(let raw):
    print("Unknown route:", raw)
}
```

## 🧵 Parameter Decoding

Use RouteParameters to extract typed values:

```swift
params.int("id")           // Int?
params.stringArray("tags") // [String]?
params.decodedObject("payload", as: User.self) // JSON-decoded struct
```

## 📱 iOS Requirements

✅ Swift 5.9+
✅ iOS 16+
✅ SwiftUI compatible
✅ UIKit supported (manually integrate with your own coordinator)

## 📚 License

MIT License © 2025 — Rasyadh Abdul Aziz
