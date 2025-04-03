//
//  Storage.swift
//  bisman-cli
//
//  Created by Bisman Sahni on 4/2/25.
//

//
//import Foundation
//import CoreML
//
//struct Storage {
//    static let outputFile = "/Users/bismansahni/Documents/embeddingtest/embedding_output.txt"
//
//    static func saveEmbedding(_ embedding: MLMultiArray, for file: String) {
//        var content = "📄 File: \(file)\n🔢 Embedding:\n"
//
//        for i in 0..<embedding.count {
//            content += "\(embedding[i])"
//            content += (i + 1) % 8 == 0 ? "\n" : "\t"
//        }
//        content += "\n----------------------------\n\n"
//
//        do {
//            if FileManager.default.fileExists(atPath: outputFile) {
//                let handle = try FileHandle(forWritingTo: URL(fileURLWithPath: outputFile))
//                handle.seekToEndOfFile()
//                if let data = content.data(using: .utf8) {
//                    handle.write(data)
//                }
//                handle.closeFile()
//            } else {
//                try content.write(toFile: output/Users/bismansahni/Documents/test-cliFile, atomically: true, encoding: .utf8)
//            }
//        } catch {
//            print("❌ Failed to save embedding: \(error)")
//        }
//    }
//}
//
//
//import Foundation
//import CoreML
//
//struct Storage {
//    static func saveEmbedding(_ embedding: MLMultiArray, for filePath: String) {
//        let fileName = URL(fileURLWithPath: filePath).lastPathComponent
//        let savePath = "/Users/bismansahni/Documents/bisman-cli/bisman-cli/embeddingstorage/\(fileName)"
//
//        var lines: [String] = []
//        for i in 0..<embedding.count {
//            lines.append(String(format: "%.6f", embedding[i].floatValue))
//        }
//
//        let content = lines.joined(separator: "\t")
//
//        do {
//            try FileManager.default.createDirectory(
//                atPath: "/Users/bismansahni/Documents/bisman-cli/embeddings",
//                withIntermediateDirectories: true,
//                attributes: nil
//            )
//            try content.write(toFile: savePath, atomically: true, encoding: .utf8)
//            print("💾 Saved embedding to \(savePath)")
//        } catch {
//            print("❌ Failed to save embedding: \(error)")
//        }
//    }
//}

//
//
//import Foundation
//import CoreML
//
//struct Storage {
//    static func saveEmbedding(_ embedding: MLMultiArray, for filePath: String) {
//        let fileName = URL(fileURLWithPath: filePath).lastPathComponent
//        let savePath = "/Users/bismansahni/Documents/bisman-cli/bisman-cli/embeddingstorage/\(fileName)"
//        let folderURL = URL(fileURLWithPath: savePath).deletingLastPathComponent()
//
//        do {
//            // Ensure the folder exists
//            if !FileManager.default.fileExists(atPath: folderURL.path) {
//                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
//            }
//
//            // Flatten MLMultiArray to tab-separated string
//            let floatArray = (0..<embedding.count).map { Float(truncating: embedding[$0]) }
//            let content = floatArray
//                .chunked(into: 8)
//                .map { $0.map { String($0) }.joined(separator: "\t") }
//                .joined(separator: "\n")
//
//            try content.write(toFile: savePath, atomically: true, encoding: .utf8)
//            print("💾 Saved embedding to \(savePath)")
//        } catch {
//            print("❌ Failed to save embedding: \(error)")
//        }
//    }
//}
