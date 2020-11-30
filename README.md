# Alpacka

A lightweight Swift package built for simple 2D bin packing on iOS and macOS.

# Adding & Using this Package:
1. Add Alpacka to your Xcode Project. 
  * File > Swift Packages > Add Package Dependency...
  * Paste repo URL https://github.com/ejjonny/alpacka
  * Select a version, a commit, or a branch (I recommend the most recent release. For example: exact version '1.0.0')
2. Conform / adopt to the `Sized` protocol by providing a packing size property. This is the size that Alpacka will use to arrange your objects. **Your object will also need to conform to Hashable if it doesn't already.** A computed property based on existing properties is ideal so that you can avoid managing additional state.
```swift
// Conforming to `Sized`
var packingSize: Alpacka.Size {
    .init(CGSize(width: width, height: height))
}
```
3. Use the static  `Alpacka.pack` method to attempt to pack objects in the provided size.
```swift
// Packing objects
Alpacka.pack(objects, origin: \.origin, in: .init(w: 400, h: 400))
    .sink { result in
        switch result {
        case let .overFlow(packed, overFlow: overFlow):
            // Do something with packed objects & the objects that didn't fit (if you want)
        case let .packed(items):
            // Do something with packed objects
        }
    }
    .store(in: &cancellables)
```

[See an example app built with SwiftUI here](https://github.com/ejjonny/alpackaVisualizer)
