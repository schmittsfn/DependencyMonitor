//
// MIT License
//
// Copyright (c) 2022 Stefan Schmitt (https://schmittsfn.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import MachO
import OSLog


private enum DependencyMonitorErrors: Error {
    case unexpected(Int)
}


/// Logs in a thread safe manner on the same serial queue
/// - note: Isolates the already logged strings set and makes it thread safe to use
private actor IsolatedLogger {
    private var alreadyLogged = Set<String>()
    
    /// Logs a given image name
    /// - Parameter imageName: The image name to be logged
    func log(imageName: String) {
        // To avoid double log entries, do not log the imageName if it has already been logged without the framework or library having been removed.
        // e.g. This happens when setting up DependencyMonitor as it iterates over all existing images using _dyld_get_image_name
        // and sets up the callback for loaded images using _dyld_register_func_for_add_image .
        guard !alreadyLogged.contains(imageName) else { return }
        alreadyLogged.insert(imageName)
        
        // Public visibility allows us to read dynamic data (here the imageName) in the mac console
        os_log("%{public}@", type: .debug, "Loaded: \(imageName)")
    }
    
    
    /// Removes an image name from the set of already logged image names
    /// - Parameter imageName: The image name string to be removed
    func remove(imageName: String) {
        alreadyLogged.remove(imageName)
    }
}

private struct DependencyMonitorLogger {

    private static var logger = IsolatedLogger()
    
    /// Retrieves the image name of the given mach header
    /// - Parameter machHeader: The mach header whose image name we want
    /// - Returns: The mach header's image name or nil if no name could be retrieved
    /// - Note: Does not ignore images of type *.app
    static func retrieveImageNameFrom(machHeader: UnsafePointer<mach_header>?) throws -> String {
        guard let ptr = machHeader else {
            throw DependencyMonitorErrors.unexpected(0)
        }
        
        var info = dl_info()
        withUnsafeMutablePointer(to: &info, {
            _ = dladdr(ptr, $0)
        })
        
        guard let dli_fname = info.dli_fname else {
            throw DependencyMonitorErrors.unexpected(1)
        }
        return String(cString: dli_fname)
    }
    
    
    /// Logs a given image name
    /// - Parameter imageName: The image name to be logged
    static func log(imageName: String) {
        Task {
            await logger.log(imageName:imageName)
        }
    }
    
    /// Removes an image name from the set of already logged image names
    /// - Parameter imageName: The image name string to be removed
    static func remove(imageName: String) {
        Task {
            await logger.remove(imageName: imageName)
        }
    }
}




/// Logs binary images that are dynamically loaded into the runtime
public struct DependencyMonitor {
    
    /// Sets up the depdendency monitor to log binary images that are dynamically loaded into the runtime
    public static func setup() {
        let name = String(describing: type(of: self)).components(separatedBy: ".").dropLast().joined()
        os_log("%{public}@", type: .debug, "\(name) loaded")

        logAlreadyLoadedImages()
        logDynamicallyLoadedImages()
    }

    
    /// Logs already loaded images
    private static func logAlreadyLoadedImages() {
        for i in 0..<_dyld_image_count() {
            guard let dyld = _dyld_get_image_name(i) else { continue }
            let imageName = String(cString: dyld)
            DependencyMonitorLogger.log(imageName: imageName)
        }
    }
    
    
    /// Sets up the callbacks for when an image is added or removed
    private static func logDynamicallyLoadedImages() {
        _dyld_register_func_for_add_image({ (machHeader: UnsafePointer<mach_header>?, _) in
            do {
                let imageName = try DependencyMonitorLogger.retrieveImageNameFrom(machHeader: machHeader)
                DependencyMonitorLogger.log(imageName: imageName)
            } catch {
                os_log("%@", type: .error, "Error when trying to log name of dynamically loaded image: \(error.localizedDescription)")
            }
        })
        
        _dyld_register_func_for_remove_image({ (machHeader: UnsafePointer<mach_header>?, _) in
            do {
                let imageName = try DependencyMonitorLogger.retrieveImageNameFrom(machHeader: machHeader)
                DependencyMonitorLogger.remove(imageName: imageName)
            } catch {
                os_log("%@", type: .error, "Error when trying to remove name of dynamically loaded image: \(error.localizedDescription)")
            }
            
        })
    }
}
