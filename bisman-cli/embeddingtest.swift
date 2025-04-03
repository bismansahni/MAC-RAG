//
//  embeddingtest.swift
//  bisman-cli
//
//  Created by Bisman Sahni on 4/2/25.
//
//
//
//import CoreML
//import Foundation
//
//func testMiniLM() {
//    do {
//        let modelURL = URL(fileURLWithPath: "/Users/bismansahni/Documents/bisman-cli/model-place/minilm.mlpackage")
//        let model = try MLModel(contentsOf: modelURL)
//
//        let inputIDs: [Int64] = [101, 2129, 2003, 2115, 2154, 102] // "how is your day"
//        let attentionMask: [Int64] = Array(repeating: 1, count: inputIDs.count)
//
//        let inputs = try MLDictionaryFeatureProvider(dictionary: [
//            "input_ids": MLMultiArray(inputIDs),
//            "attention_mask": MLMultiArray(attentionMask)
//        ])
//
//        let prediction = try model.prediction(from: inputs)
//
//        if let embedding = prediction.featureValue(for: "last_hidden_state")?.multiArrayValue {
//            print("✅ Got embedding! Shape: \(embedding.shape)")
//            print("🔢 First values:", (0..<5).map { embedding[$0] })
//        } else {
//            print("❌ Embedding not found in model output.")
//        }
//
//    } catch {
//        print("❌ Error running MiniLM model:", error)
//    }
//}
//
//extension MLMultiArray {
//    convenience init(_ values: [Int64]) throws {
//        try self.init(shape: [NSNumber(value: values.count)], dataType: .float16)
//        for (i, v) in values.enumerated() {
//            self[i] = v as NSNumber
//        }
//    }
//}





import CoreML
import Foundation

func testMiniLM() {
    do {
        let rawURL = URL(fileURLWithPath: "/Users/bismansahni/Documents/bisman-cli/model-place/minilm.mlpackage")
        let compiledURL = try MLModel.compileModel(at: rawURL)
        let model = try MLModel(contentsOf: compiledURL)

        let inputIDs: [Float32] = [101, 2129, 2003, 2115, 2154, 102]
        let attentionMask: [Float32] = Array(repeating: 1, count: inputIDs.count)

        let inputs = try MLDictionaryFeatureProvider(dictionary: [
            "input_ids": try MLMultiArray(inputIDs, shape: [1, inputIDs.count]),
            "attention_mask": try MLMultiArray(attentionMask, shape: [1, attentionMask.count])
        ])

        let prediction = try model.prediction(from: inputs)

        if let embedding = prediction.featureValue(for: "last_hidden_state")?.multiArrayValue {
            print("✅ Got embedding! Shape: \(embedding.shape)")
            print("🔢 First values:", (0..<5).map { embedding[$0] })
        } else {
            print("❌ Embedding not found in model output.")
        }

    } catch {
        print("❌ Error running MiniLM model:", error)
    }
}

extension MLMultiArray {
    convenience init(_ values: [Float32], shape: [Int]) throws {
        try self.init(shape: shape.map { NSNumber(value: $0) }, dataType: .float32)
        for (i, v) in values.enumerated() {
            self[i] = v as NSNumber
        }
    }
}
