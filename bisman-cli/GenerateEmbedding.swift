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
//import CoreML
//import Path
//import Models
//import Tokenizers
//
//struct Caller {
//    static func main() async {
//        print("✅ Starting local tokenizer + model test...")
//
//        do {
//            // Load vocab.txt
//            let vocabPath = "/Users/bismansahni/Documents/embeddingtest/embeddingtest/vocab.txt"
////            let vocabContent = try String(contentsOfFile: vocabPath)
//            let vocabContent = try String(contentsOfFile: vocabPath, encoding: .utf8)
//
//            let tokens = vocabContent.split(separator: "\n").map(String.init)
//            var vocab: [String: Int] = [:]
//            for (i, token) in tokens.enumerated() {
//                vocab[token] = i
//            }
//
//            // Initialize tokenizer
////            let tokenizer = BertTokenizer()
//            let tokenizer = BertTokenizer(vocab: vocab, merges: nil)
//
//
//            // Tokenize using the public method
//            let inputText = "Transfer learning applies existing knowledge to new tasks."
//            let tokenList = tokenizer.tokenize(text: inputText)
//
//            // Manually convert tokens to IDs using vocab
//            let inputIds = tokenList.map { vocab[$0] ?? vocab["[UNK]"]! }
//            let attentionMask = Array(repeating: 1, count: inputIds.count)
//
//            print("🧱 Tokens: \(tokenList)")
//            print("🔢 input_ids: \(inputIds)")
//            print("🎯 attention_mask: \(attentionMask)")
//
//            // Convert to MLMultiArray
////            let inputArray = try MLMultiArray(shape: [NSNumber(value: inputIds.count)], dataType: .int32)
//            
//            let inputArray = try MLMultiArray(shape: [1, NSNumber(value: inputIds.count)], dataType: .int32)
//
////            let attentionArray = try MLMultiArray(shape: [NSNumber(value: attentionMask.count)], dataType: .int32)
//            
//            
//            let attentionArray = try MLMultiArray(shape: [1, NSNumber(value: attentionMask.count)], dataType: .int32)
//
//
//            for (i, id) in inputIds.enumerated() {
//                inputArray[i] = NSNumber(value: id)
//            }
//
//            for (i, mask) in attentionMask.enumerated() {
//                attentionArray[i] = NSNumber(value: mask)
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
//            for key in prediction.featureNames {
//                print(" - \(key)")
//            }
//
//            for key in prediction.featureNames {
//                if let embedding = prediction.featureValue(for: key)?.multiArrayValue {
//                    print("\n🧠 Embedding from '\(key)':")
//                    for i in 0..<min(embedding.count, 32) {
//                        print(embedding[i], terminator: i % 8 == 7 ? "\n" : "\t")
//                    }
//                    print()
//                    break
//                }
//            }
//
//        } catch {
//            print("❌ Error: \(error)")
//        }
//    }
//}



import CoreML
import Path
import Models
import Tokenizers

struct MiniLMEmbedder {
    static func embed(text inputText: String) async {
        print("✅ Starting embedding...")

        do {
            // Load vocab
            let vocabPath = "/Users/bismansahni/Documents/embeddingtest/embeddingtest/vocab.txt"
            let vocabContent = try String(contentsOfFile: vocabPath, encoding: .utf8)
            let tokens = vocabContent.split(separator: "\n").map(String.init)
            var vocab: [String: Int] = [:]
            for (i, token) in tokens.enumerated() {
                vocab[token] = i
            }

            // Tokenizer
            let tokenizer = BertTokenizer(vocab: vocab, merges: nil)
            let tokenList = tokenizer.tokenize(text: inputText)
            let inputIds = tokenList.map { vocab[$0] ?? vocab["[UNK]"]! }
            let attentionMask = Array(repeating: 1, count: inputIds.count)

            print("🧱 Tokens: \(tokenList)")
            print("🔢 input_ids: \(inputIds)")
            print("🎯 attention_mask: \(attentionMask)")

            // Convert to MLMultiArray
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
            for key in prediction.featureNames {
                print(" - \(key)")
            }

            for key in prediction.featureNames {
                if let embedding = prediction.featureValue(for: key)?.multiArrayValue {
                    print("\n🧠 Embedding from '\(key)':")
                    for i in 0..<min(embedding.count, 32) {
                        print(embedding[i], terminator: i % 8 == 7 ? "\n" : "\t")
                    }
                    print()
                    break
                }
            }

        } catch {
            print("❌ Error: \(error)")
        }
    }
}
