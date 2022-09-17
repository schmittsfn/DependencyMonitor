# ``DependencyMonitor``

Logs the name and path of binary images as they are loaded into the swift runtime.

## Topics

### Installation

Add DependencyMonitor as a Swift package to your project, pointing to `https://github.com/schmittsfn/DependencyMonitor`


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
