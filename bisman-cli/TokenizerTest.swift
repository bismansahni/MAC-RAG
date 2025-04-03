//
//  TokenizerTest.swift
//  bisman-cli
//
//  Created by Bisman Sahni on 4/2/25.
//


//
//
//import Tokenizers
//
//func testTokenizer() async throws {
//    let tokenizer = try await AutoTokenizer.from(pretrained: "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B")
//    
//    // Tokenize the string directly
//    let encoded = try await tokenizer.encode(text:"hello this is bisman")
//    
//    // Decode the tokens back to text
//    let decoded = tokenizer.decode(tokens: encoded)
//    
//    // Print the decoded result
//    print(decoded)
//}


//
//
//import Tokenizers
//import Foundation
//
//// Main entry point
//struct Tokenizertrying {
//    static func main() async {
//        let instance = Tokenizertrying() // Create an instance of Tokenizertrying
//        
//        // Call the testTokenizer method on the instance
//        await instance.testTokenizer()
//    }
//
//    // Your async testTokenizer function with do-catch for error handling
//    func testTokenizer() async {
//        do {
//            // Attempt to create the tokenizer
//            let tokenizer = try await AutoTokenizer.from(pretrained: "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B")
//            
//            // Tokenize the string directly
//            let encoded = try await tokenizer.encode(text: "hello this is bisman")
//            
//            // Decode the tokens back to text
//            let decoded = tokenizer.decode(tokens: encoded)
//            
//            // Print the decoded result
//            print(decoded)
//        } catch {
//            // Catch any errors and print them
//            print("Error during tokenization: \(error)")
//        }
//    }
//}



import Foundation
import Tokenizers

// Main entry point
struct Tokenizertrying {
    static func main() async {
        let instance = Tokenizertrying() // Create an instance of Tokenizertrying
        
        // Call the testTokenizer method on the instance
        await instance.testTokenizer()
    }

    // Your async testTokenizer function with do-catch for error handling
    func testTokenizer() async {
        do {
            // Add 'try' before the throwing call and keep 'await' if the function is async
            let tokenizer = try await AutoTokenizer.from(pretrained: "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B")
            
            // Tokenize the string directly - add 'try' if encode can throw
            let encoded =  tokenizer.encode(text: "hello this is bisman")
            print(encoded)
            
            // Decode the tokens back to text - add 'try' if decode can throw
            let decoded =  tokenizer.decode(tokens: encoded)
            
            // Print the decoded result
            print(decoded)
        } catch {
            // Catch any errors and print them
            print("Error during tokenization: \(error)")
        }
    }
}
