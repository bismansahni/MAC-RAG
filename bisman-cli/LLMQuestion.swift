//
//  LLMQuestion.swift
//  bisman-cli
//
//  Created by Bisman Sahni on 4/2/25.
//


//
//import Foundation
//import CoreML
//import Models
//import Generation
//
//struct LLMQuestion {
//    static func run() async {
//        print("\n🧠 Ask a question based on your documents:")
//        guard let question = readLine(), !question.isEmpty else {
//            print("❌ No question entered.")
//            return
//        }
//
//        // 1. Get question embedding
//        guard let queryEmbedding = await MiniLMEmbedderForQuestion.embed(question: question) else {
//            print("❌ Failed to embed question.")
//            return
//        }
//
//        // 2. Find relevant documents
//        let matches = SimilarityEngine.findTopKMatches(
//            for: queryEmbedding,
//            in: "/Users/bismansahni/Documents/embeddingtest/embeddings"
//        )
//
//        // 3. Build prompt
//        var context = ""
//        for (path, _) in matches {
//            if let content = try? String(contentsOfFile: path, encoding: .utf8){
//                context += "\n--- From: \(path)\n\(content)\n"
//            }
//        }
//
//        let prompt = """
//        You are a helpful assistant. Use the context below to answer the question.
//
//        Context:
//        \(context)
//
//        Question:
//        \(question)
//
//        Answer:
//        """
//
//        print("📨 Prompt ready. Running through Mistral...")
//        
//        let config = GenerationConfig(
//            maxNewTokens: 200,
//            temperature: 0.7,
//            topK: 50,
//            topP: 0.95
//            
//        )
//
//        // 4. Load Mistral
//        let mistralURL = URL(fileURLWithPath: "/Users/bismansahni/Documents/mistral.mlpackage")
//        let model = try? await ModelLoader.load(url: mistralURL)
//
//        // 5. Generate output
//        if let output = try? await model?.generate(config:config,prompt:prompt) {
//            print("\n🗣️ Response:\n\(output)")
//        } else {
//            print("❌ LLM failed to respond.")
//        }
//    }
//}

//
//
//import Foundation
//import CoreML
//import Models
//import Generation
//
//struct LLMQuestion {
//    static func run(with question: String) async {
//        // 1. Get question embedding
//        guard let queryEmbedding = await MiniLMEmbedderForQuestion.embed(question: question) else {
//            print("❌ Failed to embed question.")
//            return
//        }
//
//        // 2. Find relevant documents
//        let matches = SimilarityEngine.findTopKMatches(
//            for: queryEmbedding,
//            in: "/Users/bismansahni/Documents/bisman-cli/bisman-cli/embeddingstorage"
//        )
//
//        // 3. Build prompt
//        var context = ""
//        for (path, _) in matches {
//            if let content = try? String(contentsOfFile: path, encoding: .utf8) {
//                context += "\n--- From: \(path)\n\(content)\n"
//            }
//        }
//
//        let prompt = """
//        You are a helpful assistant. Use the context below to answer the question.
//
//        Context:
//        \(context)
//
//        Question:
//        \(question)
//
//        Answer:
//        """
//        
//        
//        
//        print("📝 Prompt content:\n\(prompt)")
//        print("📝 Prompt length (chars): \(prompt.count)")
//        let tokenCount = prompt.split { $0.isWhitespace || $0.isNewline }.count
//        print("🔢 Estimated token count: \(tokenCount)")
//
//
//        print("📨 Prompt ready. Running through Mistral...")
//
//        let config = GenerationConfig(
//            maxNewTokens: 200,
//            temperature: 0.7,
//            topK: 50,
//            topP: 0.95
//        )
//
//        let mistralURL = URL(fileURLWithPath: "/Users/bismansahni/Documents/bisman-cli/model-place/StatefulMistral7BInstructInt4.mlpackage")
//        guard let model = try? await ModelLoader.load(url: mistralURL) else {
//            print("❌ Failed to load Mistral model.")
//            return
//        }
//
//        if let output = try? await model.generate(config: config, prompt: prompt) {
//            print("\n🗣️ Response:\n\(output)")
//        } else {
//            print("❌ LLM failed to respond.")
//        }
//    }
//}




import Foundation
import CoreML
import Models
import Generation

struct LLMQuestion {
    static func run(with question: String) async {
        // 1. Get question embedding
        guard let queryEmbedding = await MiniLMEmbedderForQuestion.embed(question: question) else {
            print("❌ Failed to embed question.")
            return
        }

        // 2. Find relevant documents
        let matches = SimilarityEngine.findTopKMatches(
            for: queryEmbedding,
            in: "/Users/bismansahni/Documents/bisman-cli/bisman-cli/embeddingstorage/embeddings.jsonl"
        )

        // 3. Build context from JSONL entries
        let embeddingFile = "/Users/bismansahni/Documents/bisman-cli/bisman-cli/embeddingstorage/embeddings.jsonl"
        guard let lines = try? String(contentsOfFile: embeddingFile).split(separator: "\n") else {
            print("❌ Failed to read embeddings.jsonl")
            return
        }

        var context = ""
        for (path, _) in matches {
            let filename = URL(fileURLWithPath: path).lastPathComponent
            if let line = lines.first(where: { $0.contains(filename) }) {
                if let data = line.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let chunkText = json["text"] as? String {
                    context += "\n--- From: \(filename)\n\(chunkText)\n"
                } else {
                    print("⚠️ Failed to parse context for: \(filename)")
                }
            } else {
                print("⚠️ No matching entry found in JSONL for: \(filename)")
            }
        }

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
            maxNewTokens: 200,
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
