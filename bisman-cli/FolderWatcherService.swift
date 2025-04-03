//
//
//
//
//import Foundation
//
//class FolderWatcherService {
//    private static var previousFiles: Set<String> = []
//
//    static func startWatching(at folderPath: String) async {
//        let fileManager = FileManager.default
//        let folderURL = URL(fileURLWithPath: folderPath)
//
//        guard fileManager.fileExists(atPath: folderPath) else {
//            print("❌ Folder does not exist at path: \(folderPath)")
//            return
//        }
//
//        print("✅ Started watching folder: \(folderPath)")
//
//        // Initial snapshot
//        previousFiles = getAllFiles(in: folderURL)
//
//        let fileDescriptor = open(folderPath, O_EVTONLY)
//        let source = DispatchSource.makeFileSystemObjectSource(
//            fileDescriptor: fileDescriptor,
//            eventMask: [.write, .delete, .extend, .attrib, .rename],
//            queue: DispatchQueue.global()
//        )
//
//        source.setEventHandler {
//            let currentFiles = getAllFiles(in: folderURL)
//
//            let added = currentFiles.subtracting(previousFiles)
//            let removed = previousFiles.subtracting(currentFiles)
//            let common = currentFiles.intersection(previousFiles)
//
//            for file in added {
//                print("➕ Added: \(file)")
//                // Trigger embedding
//            }
//
//            for file in removed {
//                print("❌ Removed: \(file)")
//                // Trigger removal from index
//            }
//
//           
//
//            previousFiles = currentFiles
//        }
//
//        source.setCancelHandler {
//            close(fileDescriptor)
//        }
//
//        source.resume()
//
//        // Keep alive
//        while true {
//            try? await Task.sleep(nanoseconds: 1_000_000_000)
//        }
//    }
//
//    private static func getAllFiles(in directory: URL) -> Set<String> {
//        let fileManager = FileManager.default
//        guard let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: nil) else {
//            return []
//        }
//
//        var files = Set<String>()
//        for case let fileURL as URL in enumerator {
//            if fileURL.pathExtension.lowercased() == "pdf" || fileURL.pathExtension.lowercased() == "txt" || fileURL.pathExtension.lowercased() == "md" {
//                files.insert(fileURL.path)
//            }
//        }
//        return files
//    }
//}


//
//
//import Foundation
//
//class FolderWatcherService {
//    private static var previousFiles: Set<String> = []
//
//    static func startWatching(at folderPath: String) async {
//        let fileManager = FileManager.default
//        let folderURL = URL(fileURLWithPath: folderPath)
//
//        guard fileManager.fileExists(atPath: folderPath) else {
//            print("❌ Folder does not exist at path: \(folderPath)")
//            return
//        }
//
//        print("✅ Started watching folder: \(folderPath)")
//
//        // Initial snapshot
//        previousFiles = getAllFiles(in: folderURL)
//
//        let fileDescriptor = open(folderPath, O_EVTONLY)
//        let source = DispatchSource.makeFileSystemObjectSource(
//            fileDescriptor: fileDescriptor,
//            eventMask: [.write, .delete, .extend, .attrib, .rename],
//            queue: DispatchQueue.global()
//        )
//
//        source.setEventHandler {
//            let currentFiles = getAllFiles(in: folderURL)
//
//            let added = currentFiles.subtracting(previousFiles)
//            let removed = previousFiles.subtracting(currentFiles)
//
//            for file in added {
//                print("➕ Added: \(file)")
//                Task {
//                    await MiniLMEmbedder.embedFile(at: file)
//                }
//            }
//
//            for file in removed {
//                print("❌ Removed: \(file)")
//                // TODO: Trigger removal from index if needed
//            }
//
//            previousFiles = currentFiles
//        }
//
//        source.setCancelHandler {
//            close(fileDescriptor)
//        }
//
//        source.resume()
//
//        // Keep alive
//        while true {
//            try? await Task.sleep(nanoseconds: 1_000_000_000)
//        }
//    }
//
//    private static func getAllFiles(in directory: URL) -> Set<String> {
//        let fileManager = FileManager.default
//        guard let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: nil) else {
//            return []
//        }
//
//        var files = Set<String>()
//        for case let fileURL as URL in enumerator {
//            if fileURL.pathExtension.lowercased() == "pdf" || fileURL.pathExtension.lowercased() == "txt" || fileURL.pathExtension.lowercased() == "md" {
//                files.insert(fileURL.path)
//            }
//        }
//        return files
//    }
//}




import Foundation

class FolderWatcherService {
    private static var previousFiles: Set<String> = []

    static func startWatching(at folderPath: String) async {
        let fileManager = FileManager.default
        let folderURL = URL(fileURLWithPath: folderPath)

        guard fileManager.fileExists(atPath: folderPath) else {
            print("❌ Folder does not exist at path: \(folderPath)")
            return
        }

        print("✅ Started watching folder: \(folderPath)")

        // Initial snapshot of all files
        previousFiles = getAllFiles(in: folderURL)

        // Open the folder for monitoring file system events
        let fileDescriptor = open(folderPath, O_EVTONLY)
        guard fileDescriptor != -1 else {
            print("❌ Failed to open folder for monitoring.")
            return
        }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .delete, .extend, .attrib, .rename],
            queue: DispatchQueue.global()
        )

        source.setEventHandler {
            let currentFiles = getAllFiles(in: folderURL)

            let added = currentFiles.subtracting(previousFiles)
            let removed = previousFiles.subtracting(currentFiles)

            // Handle added files (trigger embedding)
            for file in added {
                print("➕ Added: \(file)")
                Task {
                    do {
                        let content = try String(contentsOfFile: file, encoding: .utf8)
                        await MiniLMEmbedder.embed(text: content)
                    } catch {
                        print("❌ Failed to read file: \(file)\nError: \(error)")
                    }
                }}

            // Handle removed files (trigger removal from index if needed)
            for file in removed {
                print("❌ Removed: \(file)")
                // Trigger removal from index if needed
            }

            // Update previous files list
            previousFiles = currentFiles
        }

        source.setCancelHandler {
            close(fileDescriptor)
        }

        source.resume()

        // Keep alive
        while true {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
    }

    // Get all supported files in the folder
    private static func getAllFiles(in directory: URL) -> Set<String> {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: nil) else {
            return []
        }

        var files = Set<String>()
        for case let fileURL as URL in enumerator {
            if fileURL.pathExtension.lowercased() == "pdf" || fileURL.pathExtension.lowercased() == "txt" || fileURL.pathExtension.lowercased() == "md" {
                files.insert(fileURL.path)
            }
        }
        return files
    }
}
