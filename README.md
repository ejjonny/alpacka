# Alpacka

A lightweight Swift package built for simple 2D bin packing on iOS and macOS.

# Adding & Using this Package:
1. Add Alpacka to your Xcode Project. 
  * File > Swift Packages > Add Package Dependency...
  * Paste repo URL https://github.com/ejjonny/alpacka
  * Select a version, a commit, or a branch (I recommend the most recent release. For example: exact version '3.0.0-beta')
2. Conform / adopt to the `Sized` protocol by simply providing a packing size property. This is the size that Alpacka will use to arrange your objects. **Your object will also need to conform to Hashable if it doesn't already.** A computed property based on existing properties is ideal so that you can avoid managing additional state.
```swift
    var packingSize: CGSize {
        CGSize(width: width, height: height)
    }
```
3. Initialize a `Packer` object & use either the async method or the synchronous `.pack` methods depending on your needs.
```swift
// Async (for bigger operations with more objects)
        Alpacka.Packer().pack(objects, origin: \.origin, in: CGSize(width: 400, height: 400)) { result in
            switch result {
            case let .overFlow(packed, overFlow: overFlow):
              // Do something with packed objects & the objects that didn't fit (if you want)
            case let .success(packed):
              // Do something with packed objects
            }
        }
// Synchronous (only recommended for quick operations with very few objects)
        let result = Alpacka.Packer().pack(objects, origin: \.origin, in: CGSize(width: 400, height: 400))
        switch result {
        case let .overFlow(packed, overFlow: overFlow):
          // Do something with packed objects & the objects that didn't fit (if you want)
        case let .success(packed):
          // Do something with packed objects
        }
```

[See an example app built with SwiftUI here](https://github.com/ejjonny/alpackaVisualizer)
