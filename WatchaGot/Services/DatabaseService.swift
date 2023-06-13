//
//  DatabaseService.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/9/23.
//

import Combine
import Foundation

final class DatabaseService {
    static let shared = DatabaseService()

    private init() { }

    func getData<T: Codable>(get type: T.Type, at url: URL, completion: @escaping ([T]?, Error?) -> Void) {
        let urlRequest = URLRequest(url: url)

        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            self?.handleErrorAndReponse(error: error, response: response) { thrownError in
                guard thrownError == nil,
                      let data else {
                    completion(nil, thrownError)
                    return
                }

                if let decodedData = try? JSONDecoder().decode([T].self, from: data) {
                    completion(decodedData, nil)
                    return
                } else {
                    completion(nil, HttpError.unknown(error: nil))
                    return
                }
            }
        }
        .resume()
    }

    func saveData<T: Codable>(save data: T, at url: URL, completion: @escaping (Error?) -> Void) {
        do {
            let dataAsJson = try JSONEncoder().encode(data)
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = HttpMethod.POST.rawValue
            urlRequest.httpBody = dataAsJson
            urlRequest.addValue(MimeType.json.rawValue, forHTTPHeaderField: HttpHeader.contentType.rawValue)

            URLSession.shared.dataTask(with: urlRequest) { [weak self] _, response, error in
                self?.handleErrorAndReponse(error: error, response: response) { thrownError in
                    guard thrownError == nil else {
                        completion(thrownError)
                        return
                    }
                }
            }
            .resume()

            completion(nil)
        } catch {
            completion(error)
        }
    }

    func handleErrorAndReponse(error: Error?, response: URLResponse?, completion: (Error?) -> Void) {
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            completion(HttpError.badResponse)
            return
        }

        guard error == nil else {
            completion(HttpError.unknown(error: error!))
            return
        }

        completion(nil)
    }
}
