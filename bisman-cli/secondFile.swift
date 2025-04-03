//
//  secondFile.swift
//  bisman-cli
//
//  Created by Bisman Sahni on 4/2/25.
//





//
//
//import Foundation
//import Generation
//
//
//struct MacMuseCLI {
//    static func main() async {
//        await MacMuse.run()
//    }
//}
//
//struct MacMuse {
//    static func run() async {
//        print("""
//        ┌────────────────────────────────────────────┐
//        │                                            │
//        │   👋 Welcome to MacMuse                    │
//        │   Your Private On-Device RAG System 🧠     │
//        │                                            │
//        └────────────────────────────────────────────┘
//        """)
//
//        do {
//            let modelPath = URL(fileURLWithPath: "/Users/bismansahni/Documents/bisman-cli/model-place/StatefulMistral7BInstructInt4.mlpackage")
//            let model = try await ModelLoader.load(url: modelPath)
//
//            let prompt = "Best recommendations for a place to visit in Paris in August 2024:"
//            let config = GenerationConfig(maxNewTokens: 128)
//            let output = try await model.generate(config: config, prompt: prompt)
//
//            print("\n💬 MacMuse says:\n\(output)\n")
//        } catch {
//            print("❌ Error: \(error)")
//        }
//    }
//}




import Foundation


struct MacMuseCLI {
    static func main() async {
        print("""
        ┌────────────────────────────────────────────┐
        │                                            │
        │   👋 Welcome to MacMuse                    │
        │   Your Private On-Device RAG System 🧠     │
        │                                            │
        └────────────────────────────────────────────┘
        """)

        print("📂 Please enter the path to the folder you'd like to track:")
        if let path = readLine(), !path.isEmpty {
            print("👀 Watching folder: \(path)")
            // Call folder watching setup here
            await FolderWatcherService.startWatching(at: path)
        } else {
            print("⚠️ No path provided. Exiting.")
        }
    }
}
