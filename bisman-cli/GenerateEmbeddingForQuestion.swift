//
//  GenerateEmbeddingForQuestion.swift
//  bisman-cli
//
//  Created by Bisman Sahni on 4/2/25.
//





import CoreML
import Path
import Models
import Tokenizers

struct MiniLMEmbedderForQuestion {
    static func embed(question: String) async -> [Float]? {
        print("🤖 Embedding question: \(question)")

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
            let tokenList = tokenizer.tokenize(text: question)
            let inputIds = tokenList.map { vocab[$0] ?? vocab["[UNK]"]! }
            let attentionMask = Array(repeating: 1, count: inputIds.count)

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

            if let embeddingArray = prediction.featureValue(for: "pooler_output")?.multiArrayValue {
                let floatArray = (0..<embeddingArray.count).map { Float(truncating: embeddingArray[$0]) }
                print("📏 Question embedding size: \(floatArray.count)")
                return floatArray
            }

        } catch {
            print("❌ Failed to embed question: \(error)")
        }

        return nil
    }
}


