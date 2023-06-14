//
//  Constants.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/9/23.
//

import Foundation

enum Constants {
    static let apiUrl = URL(string: "https://watchagot.herokuapp.com")!
    static var apiItemsUrl: URL {
        return apiUrl.appending(path: ApiEndpoint.items)
    }

    static func getApiUrl(for item: Item) throws -> URL {
        guard let itemId = item.id else { throw HttpError.unexpectedNilValue }

        return apiItemsUrl.appending(path: itemId.uuidString)
    }
}
