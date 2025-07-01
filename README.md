# ModularRouter

A lightweight, modular, and Swift 6-concurrent-safe routing system for SwiftUI **iOS apps**.

## 📦 Overview

`ModularRouter` enables feature-based routing with support for:

- 🧩 Modular route registration (`RoutePatternProvider`)
- 🗺️ Path and query parameter decoding (`RouteParameters`)
- 🧵 Full Swift Concurrency + `Sendable` safety
- 🔁 Clean fallback handling for unknown routes
- ✅ iOS 16+ support, SwiftUI-compatible

---

## 🚀 Getting Started (iOS)

### 1. Define Routes in Your Feature

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
}
```

### 2. Provide RoutePatterns in Your Module

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

### 3. Register from Host App

```swift
try await RouteParser.register(SettingsRouteProvider.routePatterns)
```

## 🔎 Usage Example

```swift
let route = await RouteParser.parse(path: "/settings/12")

switch route {
case .wrapped(let wrapped):
    print("Matched: \(wrapped.path)")
case .notFound(let raw):
    print("No match: \(raw)")
}
```

## 📱 iOS Requirements

✅ Swift 5.9+
✅ iOS 16+
✅ SwiftUI or UIKit compatible

## 📚 License

MIT License © 2025 — Rasyadh Abdul Aziz
