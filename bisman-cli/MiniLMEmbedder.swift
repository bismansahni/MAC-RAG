//
//  MiniLMEmbedder.swift
//  bisman-cli
//
//  Created by Bisman Sahni on 4/2/25.
//


// MiniLMEmbedder.swift
// Handles embedding text using the MiniLM Core ML model





import Foundation
import CoreML

class MiniLMEmbedder {
    private static var sharedModel: MiniLMEmbedder?
    
    private let model: MLModel
    private let chunkSize: Int
    private let chunkOverlap: Int


    private init(model: MLModel, chunkSize: Int = 512, chunkOverlap: Int = 50) {
        self.model = model
        self.chunkSize = chunkSize
        self.chunkOverlap = chunkOverlap
    }
    
    static func initialize(with modelPath: String, chunkSize: Int = 512, chunkOverlap: Int = 50) throws {
        let modelURL = URL(fileURLWithPath: modelPath)
        let compiledURL = try MLModel.compileModel(at: modelURL)
        let mlModel = try MLModel(contentsOf: compiledURL)
        sharedModel = MiniLMEmbedder(model: mlModel, chunkSize: chunkSize, chunkOverlap: chunkOverlap)
    }
    
    static func embedFile(at filePath: String) async {
        guard let embedder = sharedModel else {
            print("❌ MiniLMEmbedder not initialized")
            return
        }
        
        do {
            let content = try String(contentsOfFile: filePath, encoding: .utf8)
            let chunks = embedder.createChunks(from: content)
            
            print("📄 Processing \(filePath) → \(chunks.count) chunks generated")
            
            for (index, chunk) in chunks.enumerated() {
                print("🧩 Chunk \(index+1)/\(chunks.count):")
                print("--------------------")
                print(chunk.prefix(100) + (chunk.count > 100 ? "..." : ""))
                print("--------------------")
                
                let embedding = try embedder.embed(text: chunk)
                print("🧠 Embedded chunk \(index+1) → \(embedding.prefix(5))...")
            }
            
            print("✅ Finished processing \(filePath)")
            // Save embeddings to storage/index if needed
        } catch {
            print("❌ Failed to embed \(filePath): \(error)")
        }
    }
    
    func createChunks(from text: String) -> [String] {
        // For simplicity, we'll chunk by splitting into roughly equal parts based on character count
        // In a production system, you might want to split on sentence boundaries or paragraphs
        
        if text.count <= chunkSize {
            return [text]
        }
        
        var chunks: [String] = []
        var start = text.startIndex
        
        while start < text.endIndex {
            // Calculate end with potential overlap
            let end = text.index(start, offsetBy: chunkSize, limitedBy: text.endIndex) ?? text.endIndex
            
            chunks.append(String(text[start..<end]))
            
            // Move start position for next chunk, accounting for overlap
            if end == text.endIndex {
                break
            }
            
            let newStart = text.index(start, offsetBy: chunkSize - chunkOverlap, limitedBy: text.endIndex) ?? text.endIndex
            start = newStart
        }
        
        return chunks
    }
    
    func embed(text: String) throws -> [Float] {
        let tokens = tokenize(text: text)
        guard !tokens.isEmpty else { return [] }
        
        let inputIDs = try MLMultiArray(Int32Array: tokens)
        let attentionMask = try MLMultiArray(Int32Array: Array(repeating: 1, count: tokens.count))
        
        let inputs = try MLDictionaryFeatureProvider(dictionary: [
            "input_ids": inputIDs,
            "attention_mask": attentionMask
        ])
        
        let prediction = try model.prediction(from: inputs)
        guard let output = prediction.featureValue(for: "last_hidden_state")?.multiArrayValue else {
            throw NSError(domain: "MiniLMEmbedder", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing embedding output"])
        }
        
        return convertToFloatArray(output)
    }
    
    private func tokenize(text: String) -> [Int32] {
        // Dummy tokenizer — replace with real tokenizer if needed
        return [101, 2023, 2003, 1037, 2742, 102]
    }
    
    private func convertToFloatArray(_ array: MLMultiArray) -> [Float] {
        return (0..<array.count).map { Float(truncating: array[$0]) }
    }
}

extension MLMultiArray {
    convenience init(Int32Array values: [Int32]) throws {
        try self.init(shape: [1, NSNumber(value: values.count)], dataType: .float32)
        for (i, v) in values.enumerated() {
            self[i] = NSNumber(value: v)
        }
    }
}






