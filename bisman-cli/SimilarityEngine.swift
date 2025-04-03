//
//  SimilarityEngine.swift
//  bisman-cli
//
//  Created by Bisman Sahni on 4/2/25.
//


import Foundation
import Accelerate

struct SimilarityEngine {
    static func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        precondition(a.count == b.count, "Vectors must be the same length")

        var dotProduct: Float = 0
        var normA: Float = 0
        var normB: Float = 0

        for i in 0..<a.count {
            dotProduct += a[i] * b[i]
            normA += a[i] * a[i]
            normB += b[i] * b[i]
        }

        return dotProduct / (sqrt(normA) * sqrt(normB) + 1e-9)
    }

    static func loadEmbeddings(from folderPath: String) -> [(path: String, vector: [Float])]? {
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(atPath: folderPath) else { return nil }

        var results: [(String, [Float])] = []

        for file in files where file.hasSuffix(".txt") {
            let fullPath = folderPath + "/" + file
            if let content = try? String(contentsOfFile: fullPath),
               let floats = parseEmbedding(from: content) {
                results.append((fullPath, floats))
            }
        }

        return results
    }

    private static func parseEmbedding(from text: String) -> [Float]? {
        let lines = text.split(separator: "\n")
        let allValues = lines.flatMap { $0.split(separator: "\t").compactMap { Float($0) } }
        return allValues.isEmpty ? nil : allValues
    }
    
//    private static func parseEmbedding(from text: String) -> [Float]? {
//        let firstLine = text.split(separator: "\n").first ?? ""
//        let values = firstLine.split(separator: "\t").compactMap { Float($0) }
//        return values.isEmpty ? nil : values
//    }
//

    static func findTopKMatches(for queryEmbedding: [Float], in folderPath: String, topK: Int = 3) -> [(path: String, score: Float)] {
        guard let storedEmbeddings = loadEmbeddings(from: folderPath) else { return [] }
            
        
       

        let scored = storedEmbeddings.map { (path, vector) in
            print("📏 Query size: \(queryEmbedding.count), Stored size: \(vector.count)")
            let sim = cosineSimilarity(queryEmbedding, vector)
            return (path, sim)
        }

//        return scored.sorted(by: { $0.score > $1.score }).prefix(topK).map { $0 }
        
        return Array(scored.sorted(by: { $0.1 > $1.1 }).prefix(topK))


    }
}
