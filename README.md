# FeatureToggleKit

[![Swift Version](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![SPM Compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![CocoaPods Compatible](https://img.shields.io/badge/CocoaPods-Compatible-red.svg)](https://cocoapods.org)

A **production-ready**, modular Swift feature toggle/flag management library for iOS applications, powered by Firebase Remote Config. FeatureToggleKit provides a clean, protocol-oriented architecture with separate modules for interfaces, implementation, and testing—demonstrating **SOLID principles** and **Clean Architecture** best practices.

---

### 🚀 **Why This Library Stands Out**

> **🔄 Zero Vendor Lock-in Architecture**  
> Swap Firebase for LaunchDarkly, Split.io, or your custom backend with **ONE line of code change**. Your entire app depends on interfaces, not implementations. No breaking changes. No feature module rewrites. Just true architectural flexibility.

```swift
// Change this ONE line to switch providers - that's it!
let featureToggle: FeatureToggleKit = FeatureToggleKitImp()      // Firebase
let featureToggle: FeatureToggleKit = LaunchDarklyToggleKit()    // LaunchDarkly  
let featureToggle: FeatureToggleKit = YourCustomProvider()       // Your backend
// ✅ All feature modules keep working - ZERO changes needed!
```

**Perfect for:** Enterprise apps that need provider flexibility, teams concerned about vendor lock-in, or projects that may need to migrate providers in the future.

[📖 See full provider flexibility examples below ↓](#-provider-flexibility-swap-implementations-without-breaking-changes)

---

## 🎯 Features

### Core Capabilities
- ✅ **Type-safe feature toggles** with support for multiple value types (Bool, String, Int64, Double, JSON)
- ✅ **Firebase Remote Config integration** for dynamic feature management without app releases
- ✅ **Real-time updates** via listener pattern for instant feature flag changes
- ✅ **Local override (Tweaks)** for QA testing and development
- ✅ **Thread-safe operations** with Swift 6 strict concurrency support
- ✅ **Zero-dependency interface** for feature modules

### Architecture & Design
- 🏗️ **Clean Architecture** with clear separation of concerns
- 🔌 **Dependency Injection ready** - perfect for modular apps
- 🧪 **100% testable** with comprehensive mock implementations
- 📦 **Modular design** - use only what you need (Interface, Implementation, Mock)
- 🎯 **Protocol-oriented** following Swift best practices
- 🔒 **Type-safe** API prevents runtime errors

## 📦 Modules

FeatureToggleKit follows the **Interface Segregation Principle** and is organized into three distinct modules for maximum flexibility and minimal coupling:

### 1. **FeatureToggleKit** (Interface Module) 🎯
The interface module contains all protocols and data models. This module should be injected into your feature modules to maintain loose coupling.

**Key Benefits:**
- ✅ Zero dependencies (no Firebase, no external frameworks)
- ✅ Lightweight - perfect for feature modules
- ✅ Enables true dependency injection
- ✅ Makes your feature modules independently testable

**Contains:**
- `FeatureToggleKit` - Main protocol for accessing feature toggles
- `FeatureToggleDefinition` - Defines a feature toggle with key and default value
- `FeatureToggleValue` - Type-safe enum representing different value types
- `FeatureToggleKitListener` - Protocol for receiving toggle update notifications

### 2. **FeatureToggleKitImp** (Implementation Module) ⚙️
The implementation module provides production-ready concrete implementations using Firebase Remote Config. Initialize this in your main app and inject it to feature modules.

**Key Benefits:**
- ✅ Firebase Remote Config integration for remote feature management
- ✅ Thread-safe local caching with UserDefaults persistence
- ✅ Observable pattern with listener management
- ✅ Tweak/override support for QA and debugging
- ✅ Async/await Swift 6 concurrency support

### 3. **FeatureToggleKitMock** (Mock Module) 🧪
Mock implementations for unit testing. Use this module in your test targets to write isolated, fast tests without Firebase dependencies.

**Key Benefits:**
- ✅ No network calls - fast test execution
- ✅ Predictable behavior - no flaky tests
- ✅ Full control over test scenarios
- ✅ Works with any testing framework (XCTest, Quick/Nimble, etc.)

**Contains:**
- `FeatureToggleKitMock` - Mock implementation with configurable return values
- `FeatureToggleKitListenerMock` - Mock listener for testing notifications
- Full protocol conformance for drop-in replacement

## 📋 Requirements

- iOS 15.0+
- Swift 6.0+
- Xcode 16.0+
- Firebase Remote Config 12.3.0+

## 🚀 Installation

### Swift Package Manager

Add FeatureToggleKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/harryngict/FeatureToggleKit.git", from: "0.0.0")
]
```

Then add the appropriate modules to your targets:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "FeatureToggleKitImp", package: "FeatureToggleKit")
    ]
),
.target(
    name: "YourFeatureModule",
    dependencies: [
        .product(name: "FeatureToggleKit", package: "FeatureToggleKit")
    ]
),
.testTarget(
    name: "YourTests",
    dependencies: [
        .product(name: "FeatureToggleKitMock", package: "FeatureToggleKit")
    ]
)
```

### CocoaPods

Add to your `Podfile`:

```ruby
# Main app target
target 'YourApp' do
  pod 'FeatureToggleKitImp'
end

# Feature module target
target 'YourFeatureModule' do
  pod 'FeatureToggleKit'
end

# Test target
target 'YourAppTests' do
  pod 'FeatureToggleKitMock'
end
```

## 💡 Usage

### Basic Setup (Main App)

Initialize FeatureToggleKit in your app's entry point:

```swift
import FeatureToggleKitImp
import FirebaseCore

// Configure Firebase
FirebaseApp.configure()

// Create feature toggle definitions
let definitionProvider = YourDefinitionProvider()

// Initialize the implementation
 let featureToggleKit = FeatureToggleKitImp(tweakCacheService: TweakCacheServiceImp(cacheType: .both))
featureToggleKit.setup(definitionProviders: [definitionProvider])

// Inject to your feature modules
let featureModule = FeatureModule(featureToggleKit: featureToggleKit)
```

### Defining Feature Toggles

Create a definition provider:

```swift
enum YourFeatureToggleDefinition: String, CaseIterable {
  case testFeatureToggleBool = "test_bool_enabled"
  case testFeatureToggleInt = "test_int_value"
  case testFeatureToggleDouble = "test_double_value"
  case testFeatureToggleString = "test_string_value"
  case testFeatureToggleJSON = "test_json_value"

  var defaultValue: FeatureToggleValue {
    switch self {
    case .testFeatureToggleBool: return false
    case .testFeatureToggleInt: return 0
    case .testFeatureToggleDouble: return 0.0
    case .testFeatureToggleString: return ""
    case .testFeatureToggleJSON: return .json(value: [:])
    }
  }
}

struct YourDefinitionProvider: FeatureToggleDefinitionProvider {
  init() {}

  let name = "Harry iOS Team"

  var definitions: [FeatureToggleDefinition] {
    YourFeatureToggleDefinition.allCases.map { definition in
      FeatureToggleDefinition(
        key: definition.rawValue,
        defaultValue: definition.defaultValue)
    }
  }
}
```

### Using in Feature Modules (Interface Only)

Feature modules only depend on the interface:

```swift
import FeatureToggleKit

class FeatureModule {
    private let featureToggleKit: FeatureToggleKit
    
    init(featureToggleKit: FeatureToggleKit) {
        self.featureToggleKit = featureToggleKit
    }
    
    func checkFeature() {
        // Get boolean value
        let isEnabled = featureToggleKit.getBoolValue(key: "new_feature_enabled")
        
        // Get string value with fallback
        let message = featureToggleKit.getStringValue(
            key: "welcome_message", 
            fallbackValue: "Default Message"
        )
        
        // Get numeric values
        let timeout = featureToggleKit.getLongValue(key: "api_timeout")
        let multiplier = featureToggleKit.getDoubleValue(key: "price_multiplier")
        
        // Get JSON configuration
        let config = featureToggleKit.getJSONValue(key: "feature_config")
    }
}
```

### Listening to Updates

Implement the listener protocol to receive real-time updates:

```swift
import FeatureToggleKit

class FeatureObserver: FeatureToggleKitListener {
    func didReceiveFeatureToggleUpdates(values: [(String, FeatureToggleValue)]) async {
        for (key, value) in values {
            print("Feature \(key) updated to \(value)")
        }
    }
    
    func didReceiveError(error: Error?) async {
        print("Error receiving updates: \(String(describing: error))")
    }
}

// Add listener
let observer = FeatureObserver()
featureToggleKit.addListener(observer)

// Remove when done
featureToggleKit.removeListener(observer)
```

### Unit Testing with Mocks

Use the mock module in your tests:

```swift
import XCTest
import FeatureToggleKit
import FeatureToggleKitMock

class FeatureModuleTests: XCTestCase {
    func testFeatureWithToggleEnabled() {
        // Create mock
        let mockToggleKit = FeatureToggleKitMock()
        
        // Configure mock behavior
        mockToggleKit.getBoolValueReturnValue = true
        
        // Test your feature
        let feature = FeatureModule(featureToggleKit: mockToggleKit)
        // ... perform assertions
        
        // Verify interactions
        XCTAssertEqual(mockToggleKit.getBoolValueCallCount, 1)
    }
}
```

### Advanced: Local Overrides (Tweaks)

Override feature toggle values locally for testing:

```swift
// Update local value
await featureToggleKit.updateLocal(
    key: "new_feature_enabled", 
    newValue: .bool(value: true)
)

// Get tweak for a definition
let definition = FeatureToggleDefinition(key: "new_feature_enabled", defaultValue: false)
if let tweak = featureToggleKit.getFeatureToggleTweak(definition) {
    tweak.isEnabled = true
    tweak.tweakedValue = .bool(value: false)
}

// Clear all local overrides
featureToggleKit.clearCache()
```

## 🏗️ Architecture

The modular architecture provides clear separation of concerns:

```
┌─────────────────────────────────────────┐
│           Main App                      │
│  (FeatureToggleKitImp)                 │
│  - Initialize implementation            │
│  - Configure Firebase                   │
│  - Inject to feature modules            │
└─────────────┬───────────────────────────┘
              │ inject
              ▼
┌─────────────────────────────────────────┐
│       Feature Modules                   │
│  (FeatureToggleKit - Interface)        │
│  - Depend only on protocols             │
│  - Loosely coupled                      │
│  - Easy to test                         │
└─────────────┬───────────────────────────┘
              │ mock in tests
              ▼
┌─────────────────────────────────────────┐
│           Unit Tests                    │
│  (FeatureToggleKitMock)                │
│  - Mock implementations                 │
│  - Fast, isolated tests                 │
│  - No Firebase dependency               │
└─────────────────────────────────────────┘
```

**Benefits of this Architecture:**
- **Interface Module**: Enables dependency injection and loose coupling (Dependency Inversion Principle)
- **Implementation Module**: Provides real Firebase-backed implementation (Single Responsibility)
- **Mock Module**: Facilitates fast, reliable unit testing without external dependencies
- **Provider Flexibility**: Swap Firebase for LaunchDarkly/Split.io/custom backend with ZERO changes to feature modules
- **Vendor Independence**: No lock-in to any specific provider - migrate freely
- **Team Velocity**: Feature teams can work independently without main app dependencies
- **Compile-time Safety**: Interface changes are caught at compile time across all modules

## 🔄 Provider Flexibility: Swap Implementations Without Breaking Changes

### Why This Matters

One of the most powerful aspects of FeatureToggleKit's architecture is **provider flexibility**. Your entire app depends on the **interface**, not the concrete Firebase implementation. This means:

```swift
// Today: Using Firebase Remote Config
let featureToggle: FeatureToggleKit = FeatureToggleKitImp() // Firebase implementation

// Tomorrow: Switch to LaunchDarkly - ZERO changes to feature modules!
let featureToggle: FeatureToggleKit = LaunchDarklyFeatureToggleKit()

// Or use your custom backend
let featureToggle: FeatureToggleKit = CustomBackendFeatureToggle()

// Your feature modules don't know or care!
class CheckoutModule {
    init(featureToggle: FeatureToggleKit) { // Still just the interface!
        // Works with ANY implementation
    }
}
```

### Real-World Scenarios

**Scenario 1: Vendor Migration**
```swift
// Need to migrate from Firebase to LaunchDarkly? 
// Just implement the FeatureToggleKit protocol!

class LaunchDarklyFeatureToggleKit: FeatureToggleKit {
    // Implement the protocol methods
    func getBoolValue(key: String, fallbackValue: Bool) -> Bool {
        return ldClient.boolVariation(key: key, defaultValue: fallbackValue)
    }
    // ... other methods
}

// In your app initialization - ONE LINE CHANGE
// Before:
let featureToggle = FeatureToggleKitImp() // Firebase

// After:
let featureToggle = LaunchDarklyFeatureToggleKit() // LaunchDarkly

// ✅ All feature modules continue working without ANY changes!
// ✅ No recompilation of feature modules needed!
// ✅ Zero breaking changes!
```

**Scenario 2: Multi-Tenant or Hybrid Solutions**
```swift
// Use different providers for different environments or clients
let featureToggle: FeatureToggleKit = {
    switch environment {
    case .production:
        return FeatureToggleKitImp() // Firebase for most users
    case .enterprise:
        return CustomEnterpriseToggle() // Custom solution for enterprise
    case .testing:
        return FeatureToggleKitMock() // Mocks for automated tests
    }
}()
```

**Scenario 3: Cost Optimization**
```swift
// Start with expensive provider, migrate to cheaper one later
class CombinedFeatureToggleKit: FeatureToggleKit {
    // Use free UserDefaults for low-priority toggles
    // Use paid service only for critical feature flags
    func getBoolValue(key: String, fallbackValue: Bool) -> Bool {
        if criticalFeatures.contains(key) {
            return premiumProvider.getValue(key)
        }
        return userDefaultsProvider.getValue(key)
    }
}
```

### Benefits for Enterprise

| Benefit | Impact |
|---------|--------|
| **No Vendor Lock-in** | Switch providers without rewriting your app |
| **Risk Mitigation** | Test new providers in parallel before full migration |
| **Cost Control** | Move to cheaper alternatives as needed |
| **Flexibility** | Use different providers per market/region/client |
| **Future-Proof** | New providers can be added without breaking changes |

### Implementation Complexity

> 🎯 **ARCHITECTURAL HIGHLIGHT**  
> **Single Point of Integration**: To add a new provider (LaunchDarkly, Split.io, custom backend), you only need to:
> 1. Implement the `FeatureToggleService` protocol (5 simple methods)
> 2. Pass it to `FeatureToggleProviderImp` constructor
> 
> **That's it!** No changes to interfaces, no changes to feature modules, no changes to the rest of the implementation.

---

#### Step 1: Implement the `FeatureToggleService` Protocol

Firebase Remote Config currently implements this protocol. To use a different provider, just create your own implementation:

```swift
import FeatureToggleKit

// Current implementation uses Firebase
// File: FeatureToggleProviderImp.swift (line 10)
public init(featureToggleService: FeatureToggleService = RemoteConfig.remoteConfig()) {
    self.featureToggleService = featureToggleService
}

// The FeatureToggleService protocol (only 5 methods!)
protocol FeatureToggleService {
    func getFeatureToggleValue(_ definition: FeatureToggleDefinition) -> FeatureToggleValue?
    func addOnConfigUpdateListener(completion: @escaping (Set<String>?, Error?) -> Void)
    func activateWithCompletion(completion: @escaping (Bool, Error?) -> Void)
    func setDefaults(_ definition: FeatureToggleDefinition)
    func fetchAndActivate(completion: @escaping () -> Void)
}
```

#### Step 2: Create Your Provider Implementation

```swift
// Example: LaunchDarkly implementation
import LaunchDarkly
import FeatureToggleKit

class LaunchDarklyService: FeatureToggleService {
    private let ldClient: LDClient
    
    init(client: LDClient) {
        self.ldClient = client
    }
    
    func getFeatureToggleValue(_ definition: FeatureToggleDefinition) -> FeatureToggleValue? {
        // Map to LaunchDarkly API
        switch definition.defaultValue {
        case .bool:
            let value = ldClient.variation(forKey: definition.key, defaultValue: false)
            return .bool(value: value)
        case .string:
            let value = ldClient.variation(forKey: definition.key, defaultValue: "")
            return .string(value: value)
        // ... other types
        }
    }
    
    func addOnConfigUpdateListener(completion: @escaping (Set<String>?, Error?) -> Void) {
        // LaunchDarkly listener logic
        ldClient.observe { keys in
            completion(keys, nil)
        }
    }
    
    // Implement remaining 3 methods...
}
```

#### Step 3: Inject Your Provider (ONE Line Change!)

```swift
// Before: Using Firebase
let provider = FeatureToggleProviderImp(
    featureToggleService: RemoteConfig.remoteConfig()  // Firebase
)

// After: Using LaunchDarkly
let provider = FeatureToggleProviderImp(
    featureToggleService: LaunchDarklyService(client: ldClient)  // LaunchDarkly
)

// After: Using your custom backend
let provider = FeatureToggleProviderImp(
    featureToggleService: CustomBackendService(apiClient: myAPI)  // Your backend
)

// ✅ That's it! Everything else remains unchanged!
```

#### Why This is Brilliant

💡 **Single Point of Change**: Only `FeatureToggleProviderImp` needs to know about the underlying provider  
💡 **Protocol Abstraction**: `FeatureToggleService` protocol hides all provider-specific details  
💡 **Dependency Injection**: Provider is injected via constructor - easy to swap  
💡 **Zero Breaking Changes**: Rest of your app continues working without recompilation  

**Total Implementation Time**: ~2-4 hours for most providers (just 5 methods to implement!)


**Supported Providers (community & potential):**
- ✅ Firebase Remote Config (included)
- ✅ Mock Provider (included for testing)
- 🔄 LaunchDarkly (easy to add)
- 🔄 Split.io (easy to add)
- 🔄 Optimizely (easy to add)
- 🔄 Custom REST API (easy to add)
- 🔄 Local UserDefaults (easy to add)

## 🎓 Why This Architecture?

This library demonstrates several software engineering principles:

1. **Dependency Inversion Principle (DIP)**: Feature modules depend on abstractions, not concrete implementations - enabling provider swapping
2. **Interface Segregation Principle (ISP)**: Separate interfaces for different responsibilities (value providing, listener management, etc.)
3. **Single Responsibility Principle (SRP)**: Each module has one clear purpose
4. **Open/Closed Principle**: Open for extension (new providers) but closed for modification (existing code)
5. **Separation of Concerns**: Clear boundaries between interface, implementation, and testing

Perfect for:
- 📱 **Large-scale iOS apps** with multiple teams and modules
- 🧪 **Test-driven development (TDD)** workflows
- 🚀 **Continuous delivery** with dynamic feature rollouts
- 👥 **Team collaboration** with clear module boundaries
- 🎯 **A/B testing** and gradual feature rollouts

## 🔄 Real-World Use Cases

```swift
// Gradual feature rollout
if featureToggleKit.getBoolValue(key: "new_checkout_flow") {
    // Show new checkout UI
} else {
    // Keep old checkout UI
}

// Kill switch for problematic features
if !featureToggleKit.getBoolValue(key: "enable_analytics") {
    return // Disable without app update
}

// Dynamic configuration
let apiTimeout = featureToggleKit.getLongValue(key: "api_timeout_seconds")
let apiConfig = featureToggleKit.getJSONValue(key: "api_config")

// A/B testing variants
let variant = featureToggleKit.getStringValue(key: "experiment_variant") // "A" or "B"
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## ⭐ Show Your Support

If you find this library useful, please consider giving it a star! It helps others discover the project.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Harry Nguyen Chi Hoang**
- Email: harryngict@gmail.com
- GitHub: [@harryngict](https://github.com/harryngict)

## 🙏 Acknowledgments

- Built with [Firebase Remote Config](https://firebase.google.com/products/remote-config)
- Designed with Swift 6 concurrency in mind
