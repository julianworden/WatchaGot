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

    func saveData<T: Codable>(_ data: T, completion: @escaping (Error?) -> Void) {
        do {
            let dataAsJson = try JSONEncoder().encode(data)
            var urlRequest = URLRequest(url: Constants.apiItemsUrl)
            urlRequest.httpMethod = HttpMethod.POST.rawValue
            urlRequest.httpBody = dataAsJson
            urlRequest.addValue(MimeType.json.rawValue, forHTTPHeaderField: HttpHeader.contentType.rawValue)

            URLSession.shared.dataTask(with: urlRequest) { _, response, error in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    completion(HttpError.badResponse)
                    return
                }

                guard error == nil else {
                    completion(HttpError.unknown(error: error!))
                    return
                }
            }
            .resume()

            completion(nil)
        } catch {
            completion(error)
        }
    }
}
