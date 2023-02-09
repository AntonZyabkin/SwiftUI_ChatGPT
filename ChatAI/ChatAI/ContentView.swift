//
//  ContentView.swift
//  ChatAI
//
//  Created by Anton Zyabkin on 09.02.2023.
//

import SwiftUI
import OpenAISwift


final class ViewModel: ObservableObject {
    
    init() {}
    
    
    private var client: OpenAISwift?
    func setup () {
        client = OpenAISwift(authToken: "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")
    }
    
    func send(text: String, complition: @escaping (String) -> Void) {
        client?.sendCompletion(with: text,
                               maxTokens: 500,
                               completionHandler: { result in
            print(result)
            switch result {
            case .success(let model):
                let output = model.choices.first?.text ?? ""
                complition(output)
            case .failure(let error):
                print("ERROR is: \(error)")
                break
            }
        })
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var models = [String]()
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(models, id: \.self) { string in
                Text(string)
            }
            Spacer()
            
            HStack {
                TextField("Type here ... ", text: $text)
                Button("Send") {
                    send()
                }
            }
        }
        .onAppear {
            viewModel.setup()
        }
        .padding()
    }
    
    func send() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        models.append("Me: \(text)")
        viewModel.send(text: text) { response in
            DispatchQueue.main.async {
                self.models.append("ChapGPT: " + response)
                self.text = ""
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
