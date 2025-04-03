//
//  ModelLoader.swift
//  bisman-cli
//
//  Created by Bisman Sahni on 4/2/25.
//

//
//
//import Foundation
//import CoreML
//import Path
//import Models
//
//class ModelLoader {
//    static let models = Path.applicationSupport / "hf-compiled-transformers"
//    static let lastCompiledModel = models / "last-model.mlmodelc"
//
//    static func load(localPath: String) async throws -> LanguageModel {
//        let compiledModel = try await MLModel.compileModel(at: URL(fileURLWithPath: localPath))
//        let mlModel = try MLModel(contentsOf: compiledModel)
//        return try LanguageModel(underlyingModel: mlModel)
//    }
//}

import CoreML
import Path
import Models
import Combine

class ModelLoader {
    static let models = Path.applicationSupport / "hf-compiled-transformers"
    static let lastCompiledModel = models / "last-model.mlmodelc"
    
//    print("hereeee")
    
    static func load(url: URL?) async throws -> LanguageModel {
        guard let url = url else {
            throw NSError(domain: "ModelLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        func clearModels() throws {
            try models.delete()
            try ModelLoader.models.mkdir(.p)
        }
        
        let compiledPath = models / url.deletingPathExtension().appendingPathExtension("mlmodelc").lastPathComponent
        
        if url.pathExtension == "mlmodelc" {
            try clearModels()
            try Path(url: url)?.copy(to: compiledPath, overwrite: true)
        } else {
            print("🛠 Compiling model: \(url.lastPathComponent)")
            let compiledURL = try await MLModel.compileModel(at: url)
            try clearModels()
            try Path(url: compiledURL)?.move(to: compiledPath, overwrite: true)
        }
        
        try compiledPath.symlink(as: lastCompiledModel)
        
        let lastURL = try lastCompiledModel.readlink().url
        return try LanguageModel.loadCompiled(url: lastURL, computeUnits: .cpuAndGPU)
    }
    
}
