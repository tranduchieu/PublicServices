//
//  WebService.swift
//  DanceFitme
//
//  Created by Hieu Tran on 14/04/2024.
//
import Foundation
import SwiftData

public enum NetworkError: Error {
    case badUrl
    case invalidRequest
    case badResponse
    case badStatus
    case failedToDecodeResponse
}

public class FetchDataService {
//    @MainActor
//    func updateDataInDatabase(modelContext: ModelContext) async {
//        do {
//            let itemData: [PhotoDTO] = try await fetchData(fromUrl: "https://jsonplaceholder.typicode.com/albums/1/photos")
//            for eachItem in itemData {
//                let itemToStore = PhotoObject(item: eachItem)
//                modelContext.insert(itemToStore)
//            }
//        } catch {
//            print("Error fetching data")
//            print(error.localizedDescription)
//        }
//    }

    public func fetchData<T: Codable>(fromUrl: String) async throws -> [T] {
        guard let downloadedData: [T] = await downloadData(fromURL: fromUrl) else {return []}

        return downloadedData
    }
    
    public enum DateError: String, Error {
        case invalidDate
    }
    
    public func downloadData<T: Codable>(fromURL: String) async -> T? {
        do {
            guard let url = URL(string: fromURL) else { throw NetworkError.badUrl }
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response as? HTTPURLResponse else { throw NetworkError.badResponse }
            guard response.statusCode >= 200 && response.statusCode < 300 else { throw NetworkError.badStatus }
            
            let decoder = JSONDecoder()
            
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
                let container = try decoder.singleValueContainer()
                let dateStr = try container.decode(String.self)

                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
                if let date = formatter.date(from: dateStr) {
                    return date
                }
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
                if let date = formatter.date(from: dateStr) {
                    return date
                }
                throw DateError.invalidDate
            })
            
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            guard let decodedResponse = try? decoder.decode(T.self, from: data) else { throw NetworkError.failedToDecodeResponse }
            
            return decodedResponse
        } catch NetworkError.badUrl {
            print("There was an error creating the URL")
        } catch NetworkError.badResponse {
            print("Did not get a valid response")
        } catch NetworkError.badStatus {
            print("Did not get a 2xx status code from the response")
        } catch NetworkError.failedToDecodeResponse {
            print("Failed to decode response into the given type")
        } catch {
            print("An error occured downloading the data")
        }
        
        return nil
    }
    
}
