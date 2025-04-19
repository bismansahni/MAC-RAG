//
//  LLMQuestion.swift
//  bisman-cli
//
//  Created by Bisman Sahni on 4/2/25.
//






import Foundation
import CoreML
import Models
import Generation
import SQLite  // ✅ Needed for DB access

struct LLMQuestion {
    static func run(with question: String) async {
        // 1. Get question embedding
        guard let queryEmbedding = await MiniLMEmbedderForQuestion.embed(question: question) else {
            print("❌ Failed to embed question.")
            return
        }

        // 2. Find top matches using vector similarity
        let matches = SimilarityEngine.findTopKMatches(for: queryEmbedding)

  
        
        // 3. Build context only from matched chunks
        var context = ""
        var seenChunks = Set<String>()
        var sourceFiles = Set<String>()

//        for (filename, _) in matches {
//            let shortName = URL(fileURLWithPath: filename).lastPathComponent
//            sourceFiles.insert(shortName)
//
//            let allChunks = EmbeddingDatabase.shared.getChunkTexts(byFilenames: [filename])
//            if let chunks = allChunks[filename] {
//                for chunk in chunks {
//                    // Optional: avoid duplicate chunks
//                    if seenChunks.insert(chunk).inserted {
//                        context += "\n--- From: \(shortName)\n\(chunk)\n"
//                    }
//                }
//            }
//        }
        
        
        for (chunk, _) in matches {
            let shortName = URL(fileURLWithPath: chunk.file).lastPathComponent
            sourceFiles.insert(shortName)

            if seenChunks.insert(chunk.text).inserted {
                context += "\n--- From: \(shortName)\n\(chunk.text)\n"
            }
        }


        print("🧾 Answer was built using context from files: \(sourceFiles.joined(separator: ", "))")


        let prompt = """
        You are a helpful assistant. Use the context below to answer the question.

        Context:
        \(context)

        Question:
        \(question)

        Answer:
        """

        print("📝 Prompt content:\n\(prompt)")
        print("📝 Prompt length (chars): \(prompt.count)")
        let tokenCount = prompt.split { $0.isWhitespace || $0.isNewline }.count
        print("🔢 Estimated token count: \(tokenCount)")

        print("📨 Prompt ready. Running through Mistral...")

        let config = GenerationConfig(
            maxNewTokens: 400,
            temperature: 0.7,
            topK: 50,
            topP: 0.95
        )

        let mistralURL = URL(fileURLWithPath: "/Users/bismansahni/Documents/bisman-cli/model-place/StatefulMistral7BInstructInt4.mlpackage")
        guard let model = try? await ModelLoader.load(url: mistralURL) else {
            print("❌ Failed to load Mistral model.")
            return
        }

        if let output = try? await model.generate(config: config, prompt: prompt) {
            print("\n🗣️ Response:\n\(output)")
        } else {
            print("❌ LLM failed to respond.")
        }
    }
}
