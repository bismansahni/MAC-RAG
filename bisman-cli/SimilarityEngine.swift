//
//  SimilarityEngine.swift
//  bisman-cli
//
//  Created by Bisman Sahni on 4/2/25.
//

//



//
//
//import Foundation
//import SwiftFaiss
//
//struct SimilarityEngine {
//    static func findTopKMatches(
//        for queryEmbedding: [Float],
//        in jsonlPath: String,
//        topK: Int = 3
//    ) -> [(filename: String, score: Float)] {
//        guard let lines = try? String(contentsOfFile: jsonlPath).split(separator: "\n") else {
//            print("❌ Could not read \(jsonlPath)")
//            return []
//        }
//
//        var embeddings: [[Float]] = []
//        var filenames: [String] = []
//
//        for line in lines {
//            guard let data = line.data(using: .utf8),
//                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//                  let embeddingArray = json["embedding"] as? [Double],
////                  let filename = json["filename"] as? String else {
//                  let filename = json["file"] as? String else{
//
//                continue
//            }
//
//            let floatEmbedding = embeddingArray.map { Float($0) }
//            if floatEmbedding.count == queryEmbedding.count {
//                embeddings.append(floatEmbedding)
//                filenames.append(filename)
//            } else {
//                print("⚠️ Skipping \(filename) due to dimension mismatch")
//            }
//        }
//
//        guard !embeddings.isEmpty else {
//            print("❌ No valid embeddings to compare")
//            return []
//        }
//
//        do {
//            let d = queryEmbedding.count
//            let index = try FlatIndex(d: d, metricType: .l2)
//            try index.add(embeddings)
//            let result = try index.search([queryEmbedding], k: topK)
//
//            return zip(result.labels[0], result.distances[0]).compactMap { (label, distance) in
//                guard label >= 0 && label < filenames.count else { return nil }
//                return (filenames[Int(label)], distance)
//            }
//
//        } catch {
//            print("❌ Faiss error: \(error)")
//            return []
//        }
//    }
//}
//





import Foundation
import SwiftFaiss
import SQLite



struct SimilarityEngine {
    static func findTopKMatches(for queryEmbedding: [Float], topK: Int = 3) -> [(filename: String, score: Float)] {
        let records = EmbeddingDatabase.shared.getAllEmbeddings()

        var embeddings: [[Float]] = []
        var filenames: [String] = []

        for record in records {
            if record.embedding.count == queryEmbedding.count {
                embeddings.append(record.embedding)
                filenames.append(record.file)
            } else {
                print("⚠️ Skipping \(record.file) due to dimension mismatch")
            }
        }

        guard !embeddings.isEmpty else {
            print("❌ No valid embeddings in DB")
            return []
        }

        do {
            let d = queryEmbedding.count
            let index = try FlatIndex(d: d, metricType: .l2)
            try index.add(embeddings)
            let result = try index.search([queryEmbedding], k: topK)

            return zip(result.labels[0], result.distances[0]).compactMap { (label, distance) in
                guard label >= 0 && label < filenames.count else { return nil }
                return (filenames[Int(label)], distance)
            }
        } catch {
            print("❌ Faiss error: \(error)")
            return []
        }
    }
}
