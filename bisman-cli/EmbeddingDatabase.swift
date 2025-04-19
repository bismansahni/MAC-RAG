//
//  EmbeddingDatabase.swift
//  bisman-cli
//
//  Created by Bisman Sahni on 4/18/25.
//

import Foundation
import SQLite

struct ChunkRecord {
    let id: Int64?
    let file: String
    let chunkIndex: Int
    let text: String
    let embedding: [Float]
}

class EmbeddingDatabase {
    static let shared = EmbeddingDatabase()

    private let db: Connection
    private let chunks: Table
    private let id = Expression<Int64>("id")
    private let file = Expression<String>("file")
    private let chunkIndex = Expression<Int>("chunk_index")
    private let text = Expression<String>("text")
    private let embedding = Expression<Blob>("embedding")

    private init() {
        let dbPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("macmuse_embeddings.sqlite").path
        db = try! Connection(dbPath)

        chunks = Table("chunks")
        try! db.run(chunks.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(file)
            t.column(chunkIndex)
            t.column(text)
            t.column(embedding)
        })
    }

    func insertChunk(file: String, chunkIndex: Int, text: String, embedding: [Float]) {
        let data = Data(buffer: UnsafeBufferPointer(start: embedding, count: embedding.count))
        let blob = Blob(bytes: [UInt8](data))
        let insert = chunks.insert(self.file <- file, self.chunkIndex <- chunkIndex, self.text <- text, self.embedding <- blob)
        try? db.run(insert)
    }

    func getAllEmbeddings() -> [ChunkRecord] {
        var results: [ChunkRecord] = []
        for row in try! db.prepare(chunks) {
            let bytes = [UInt8](row[embedding].bytes)
            let floats = bytes.withUnsafeBufferPointer {
                Array(UnsafeBufferPointer<Float>(start: UnsafeRawPointer($0.baseAddress!).assumingMemoryBound(to: Float.self),
                                                 count: bytes.count / MemoryLayout<Float>.size))
            }
            let record = ChunkRecord(id: row[id], file: row[file], chunkIndex: row[chunkIndex], text: row[text], embedding: floats)
            results.append(record)
        }
        return results
    }

    func getChunkTexts(byFilenames filenames: [String]) -> [String: [String]] {
        var result: [String: [String]] = [:]
        for name in filenames {
            let query = chunks.filter(file == name).order(chunkIndex.asc)
            let texts = try? db.prepare(query).map { $0[text] }
            result[name] = texts ?? []
        }
        return result
    }
}
