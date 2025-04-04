//
//  GenerateEmbedding.swift
//  bisman-cli
//
//  Created by Bisman Sahni on 4/2/25.
//
//
//
//
//



//
//
//import CoreML
//import Path
//import Models
//import Tokenizers
//
//struct MiniLMEmbedder {
//    static func embed(text inputText: String, filePath: String) async {
//        print("✅ Starting embedding for file: \(filePath)")
//
//        do {
//            // Load vocab
//            let vocabPath = "/Users/bismansahni/Documents/bisman-cli/bisman-cli/vocab.txt"
//            let vocabContent = try String(contentsOfFile: vocabPath, encoding: .utf8)
//            let tokens = vocabContent.split(separator: "\n").map(String.init)
//            var vocab: [String: Int] = [:]
//            for (i, token) in tokens.enumerated() {
//                vocab[token] = i
//            }
//
//            // Tokenize
//            let tokenizer = BertTokenizer(vocab: vocab, merges: nil)
//            let tokenList = tokenizer.tokenize(text: inputText)
//            let inputIds = tokenList.map { vocab[$0] ?? vocab["[UNK]"]! }
//            let attentionMask = Array(repeating: 1, count: inputIds.count)
//
//            print("🧱 Tokens: \(tokenList)")
//            print("🔢 input_ids: \(inputIds)")
//            print("🎯 attention_mask: \(attentionMask)")
//
//            // Prepare inputs
//            let inputArray = try MLMultiArray(shape: [1, NSNumber(value: inputIds.count)], dataType: .int32)
//            let attentionArray = try MLMultiArray(shape: [1, NSNumber(value: attentionMask.count)], dataType: .int32)
//            for (i, id) in inputIds.enumerated() {
//                inputArray[[0, i] as [NSNumber]] = NSNumber(value: id)
//            }
//            for (i, mask) in attentionMask.enumerated() {
//                attentionArray[[0, i] as [NSNumber]] = NSNumber(value: mask)
//            }
//
//            // Load model
//            let modelURL = URL(fileURLWithPath: "/Users/bismansahni/Documents/embeddingtest/embeddingtest/minilm.mlpackage")
//            let compiledURL = try await MLModel.compileModel(at: modelURL)
//            let model = try MLModel(contentsOf: compiledURL)
//
//            // Predict
//            let inputFeatures = try MLDictionaryFeatureProvider(dictionary: [
//                "input_ids": inputArray,
//                "attention_mask": attentionArray
//            ])
//            let prediction = try await model.prediction(from: inputFeatures)
//
//            print("\n📤 Output keys:")
//            prediction.featureNames.forEach { print(" - \($0)") }
//
//            // Extract "pooler_output" only
//            if let embedding = prediction.featureValue(for: "pooler_output")?.multiArrayValue {
//                
//                print("📏 Embedding size: \(embedding.count)")
//
//                print("\n🧠 Embedding from 'pooler_output' for file: \(filePath)")
//                for i in 0..<min(embedding.count, 32) {
//                    print(embedding[i], terminator: i % 8 == 7 ? "\n" : "\t")
//                }
//                print()
//
//                // Save embedding
//                let filename = URL(fileURLWithPath: filePath).lastPathComponent
//                let savePath = "/Users/bismansahni/Documents/bisman-cli/bisman-cli/embeddingstorage/\(filename)"
//                let folderURL = URL(fileURLWithPath: savePath).deletingLastPathComponent()
//                
//                print("📏 Embedding size just before the save check: \(embedding.count)")
//
//                if !FileManager.default.fileExists(atPath: folderURL.path) {
//                    try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
//                }
//
//                let floatArray = (0..<embedding.count).map { Float(truncating: embedding[$0]) }
//                let formatted = floatArray
//                    .chunked(into: 8)
//                    .map { $0.map { String($0) }.joined(separator: "\t") }
//                    .joined(separator: "\n")
//
//                try formatted.write(toFile: savePath, atomically: true, encoding: .utf8)
//                print("💾 Saved embedding to \(savePath)")
//                
//                
//              
//            }
//
//        } catch {
//            print("❌ Error embedding \(filePath): \(error)")
//        }
//    }
//}
//
//// Helper
//extension Array {
//    func chunked(into size: Int) -> [[Element]] {
//        stride(from: 0, to: count, by: size).map {
//            Array(self[$0..<Swift.min($0 + size, count)])
//        }
//    }
//}
//




import CoreML
import Path
import Models
import Tokenizers
import Foundation

struct MiniLMEmbedder {
    static func embed(text inputText: String, filePath: String) async {
        print("✅ Starting embedding for file: \(filePath)")

        do {
            // Load vocab
            let vocabPath = "/Users/bismansahni/Documents/bisman-cli/bisman-cli/vocab.txt"
            let vocabContent = try String(contentsOfFile: vocabPath, encoding: .utf8)
            let tokens = vocabContent.split(separator: "\n").map(String.init)
            var vocab: [String: Int] = [:]
            for (i, token) in tokens.enumerated() {
                vocab[token] = i
            }

            // Tokenize
            let tokenizer = BertTokenizer(vocab: vocab, merges: nil)
            let tokenList = tokenizer.tokenize(text: inputText)
            let inputIds = tokenList.map { vocab[$0] ?? vocab["[UNK]"]! }
            let attentionMask = Array(repeating: 1, count: inputIds.count)

            print("🧱 Tokens: \(tokenList)")
            print("🔢 input_ids: \(inputIds)")
            print("🎯 attention_mask: \(attentionMask)")

            // Prepare inputs
            let inputArray = try MLMultiArray(shape: [1, NSNumber(value: inputIds.count)], dataType: .int32)
            let attentionArray = try MLMultiArray(shape: [1, NSNumber(value: attentionMask.count)], dataType: .int32)
            for (i, id) in inputIds.enumerated() {
                inputArray[[0, i] as [NSNumber]] = NSNumber(value: id)
            }
            for (i, mask) in attentionMask.enumerated() {
                attentionArray[[0, i] as [NSNumber]] = NSNumber(value: mask)
            }

            // Load model
            let modelURL = URL(fileURLWithPath: "/Users/bismansahni/Documents/embeddingtest/embeddingtest/minilm.mlpackage")
            let compiledURL = try await MLModel.compileModel(at: modelURL)
            let model = try MLModel(contentsOf: compiledURL)

            // Predict
            let inputFeatures = try MLDictionaryFeatureProvider(dictionary: [
                "input_ids": inputArray,
                "attention_mask": attentionArray
            ])
            let prediction = try await model.prediction(from: inputFeatures)

            print("\n📤 Output keys:")
            prediction.featureNames.forEach { print(" - \($0)") }

            if let embedding = prediction.featureValue(for: "pooler_output")?.multiArrayValue {
                print("📏 Embedding size: \(embedding.count)")
                for i in 0..<min(embedding.count, 32) {
                    print(embedding[i], terminator: i % 8 == 7 ? "\n" : "\t")
                }
                print()

                let floatArray = (0..<embedding.count).map { Float(truncating: embedding[$0]) }

                // Save to JSONL
                let folderPath = "/Users/bismansahni/Documents/bisman-cli/bisman-cli/embeddingstorage"
                let outputPath = folderPath + "/embeddings.jsonl"
                let folderURL = URL(fileURLWithPath: folderPath)
                let fileURL = URL(fileURLWithPath: outputPath)

                if !FileManager.default.fileExists(atPath: folderURL.path) {
                    try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
                }

                let jsonLine: [String: Any] = [
                    "file": filePath,
                    "text": inputText,
                    "embedding": floatArray
                ]
                let jsonData = try JSONSerialization.data(withJSONObject: jsonLine, options: [])
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    if FileManager.default.fileExists(atPath: outputPath) {
                        let fileHandle = try FileHandle(forWritingTo: fileURL)
                        fileHandle.seekToEndOfFile()
                        fileHandle.write("\n".data(using: .utf8)!)
                        fileHandle.write(jsonString.data(using: .utf8)!)
                        fileHandle.closeFile()
                    } else {
                        try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
                    }
                    print("💾 Saved embedding to JSONL at \(outputPath)")
                }
            }

        } catch {
            print("❌ Error embedding \(filePath): \(error)")
        }
    }
}

// Helper
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
