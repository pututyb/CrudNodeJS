//
//  ContentView.swift
//  CrudNodeJS
//
//  Created by Putut Yusri Bahtiar on 26/05/23.
//

import Foundation
import SwiftUI

struct Item: Codable {
    let id: Int
    let name: String
}

func getItems(completion: @escaping ([Item]?) -> Void) {
    guard let url = URL(string: "http://localhost:3000/api/items") else {
        completion(nil)
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        guard let data = data else {
            completion(nil)
            return
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let items = try decoder.decode([Item].self, from: data)
            completion(items)
        } catch {
            print("Error decoding response: \(error.localizedDescription)")
            completion(nil)
        }
    }.resume()
}

func deleteItem(_ item: Item, items: Binding<[Item]>) {
    guard let url = URL(string: "http://localhost:3000/api/items/\(item.id)") else {
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            // Delete successful
            DispatchQueue.main.async {
                items.wrappedValue.removeAll { $0.id == item.id }
            }
        } else {
            print("Error deleting item")
        }
    }.resume()
}

struct ContentView: View {
    @State private var items: [Item] = []
    
    var body: some View {
        List(items, id: \.id) { item in
            Text(item.name)
                .onTapGesture {
                    deleteItem(item, items: $items)
                }
        }
        .onAppear {
            getItems { fetchedItems in
                DispatchQueue.main.async {
                    self.items = fetchedItems ?? []
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
