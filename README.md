# ``DependencyMonitor``

Logs the name and path of binary images as they are loaded into the swift runtime.

## Topics

### Installation

#### Using SPM
Add DependencyMonitor as a Swift package to your project, pointing to `https://github.com/schmittsfn/DependencyMonitor`

#### Manually

Generate the XCFramework:
```
cd DependencyMonitor
make create-xcframework
```
Integrate XCFramework into your project:
- Drag DependencyMonitor.xcframework to the `Frameworks, Libraries and Embedded Content` section of your project target
![Frameworks, Libraries and Embedded Content](Resources/manually_drag_framework_to_settings.png?raw=true "Frameworks, Libraries and Embedded Content")


### Usage

Setup DependencyMonitor anywhere in your project. A good place could be `func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool`

```
import DependencyMonitor

DependencyMonitor.setup()
```

#### Example
```
import UIKit
import DependencyMonitor

@main
public class AppDelegate: UIResponder, UIApplicationDelegate {
    public func application(_ application: UIApplication,
                            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        DependencyMonitor.setup()
        return true
    }
}
```
