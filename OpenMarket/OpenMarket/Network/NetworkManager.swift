//
//  NetworkManager.swift
//  OpenMarket
//
//  Created by Kyo, LJ on 2022/11/15.
//

import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func checkHealth(to url: URL) {
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.GET
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(NetworkError.networking.description)
                return
            }
            
            guard let safeData = data else {
                print(NetworkError.data.description)
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                  200 == response.statusCode else {
                print(NetworkError.networking.description)
                return
            }
            
            print(String(decoding: safeData, as: UTF8.self))
        }.resume()
    }
    
    func fetchData<T: Decodable>(to url: URL,
                                 dataType: T.Type,
                                 completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        let decodeManager = DecodeManager<T>()
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.GET
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(.networking))
                return
            }
            
            guard let safeData = data else {
                completion(.failure(.data))
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                  (200 ..< 299) ~= response.statusCode else {
                completion(.failure(.networking))
                return
            }
            
            let productData = decodeManager.decodeData(data: safeData)
            
            switch productData {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }.resume()
    }
}
