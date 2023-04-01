//
//  APIManager.swift
//  GalaxySDK
//
//  Created by Adam Barr-Neuwirth on 3/29/23.
//

import Foundation

class APIManager{

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }
    let baseApi = "https://api.galaxysdk.com/api/v1"

    func apiCall(urlPath: String, method: HTTPMethod, parameters: [String: Any]?, publishableKey: String, completion: @escaping (Result<Data, Error>) -> Void) {
        
        let token = UserDefaults.standard.string(forKey: "galaxyToken")
        
        guard let url = URL(string: baseApi + urlPath) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        do{
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            if(parameters != nil){
                let requestBody = try JSONSerialization.data(withJSONObject: parameters!, options: [])
                request.httpBody = requestBody
            }
            
            request.addValue(publishableKey, forHTTPHeaderField: "Publishable-Key")
            
            if(token != nil){
                request.addValue(token!, forHTTPHeaderField: getAuthorizationType(savedToken: token!))
            }
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NSError(domain: "Invalid Response", code: 0, userInfo: nil)))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print(urlPath)
                    completion(.failure(NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: nil)))
                    return
                }
                
                if let data = data {
                    completion(.success(data))
                } else {
                    completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                }
            }
            task.resume()
        } catch {
            print("Error creating request body: \(error.localizedDescription)")
        }
    }

    private func getAuthorizationType(savedToken: String) -> String {
        let parts = savedToken.customSplit(separator: ".")
        if parts.count > 2 {
            var decode = String(parts[1])
            let padLength = 4 - decode.count % 4
            if padLength < 4 {
                decode += String(repeating: "=", count: padLength)
            }
            guard let bytes = Data(base64Encoded: decode),
                  let userInfo = String(data: bytes, encoding: .utf8) else {
                return "Anonymous-Authorization"
            }
            
            if userInfo.contains("anonymous") {
                let anonSeparator = "\"anonymous\":"
                let commaSeparator = ",\""
                let anonymous = userInfo.customSplit(separator: anonSeparator)[1].customSplit(separator: commaSeparator)[0]
                if anonymous != "true" {
                    print("SA")
                    return "Super-Authorization"
                }
            }
        }
        print("AA")
        return "Anonymous-Authorization"
    }
}

extension String {
    func customSplit(separator: String, maxSplits: Int = Int.max, omittingEmptySubsequences: Bool = true) -> [String] {
        return self.components(separatedBy: separator)
    }
}
