//
//  main.swift
//  bisman-cli
//
//  Created by Bisman Sahni on 4/2/25.
//
//


//import Foundation
//
//await MacMuseCLI.main()
//




import Foundation

// Initialize the MiniLM model
do {
    try await MiniLMEmbedder.initialize(with: "/Users/bismansahni/Documents/bisman-cli/model-place/minilm.mlpackage")
    print("✅ MiniLM model initialized successfully")
} catch {
    print("❌ Failed to initialize MiniLM model: \(error)")
    exit(1)
}



await MacMuseCLI.main()

