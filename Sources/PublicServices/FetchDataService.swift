//
//  WebService.swift
//  DanceFitme
//
//  Created by Hieu Tran on 14/04/2024.
//
import Foundation

public enum NetworkError: Error {
    case badUrl
    case invalidRequest
    case badResponse
    case badStatus
    case failedToDecodeResponse
}

public enum DateError: Error {
    case invalidDate
}

public class FetchDataService {
    public init() {}
    
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

public func fetchData<T: Codable>(fromURL: String, headers: [String: String]? = nil) async throws -> T? {
    do {
        guard let url = URL(string: fromURL) else { throw NetworkError.badUrl }
        
        var request = URLRequest(url: url)
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
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
        
        // Uncomment this line if you want to use the keyDecodingStrategy
        // decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let decodedResponse = try decoder.decode(T.self, from: data)
            return decodedResponse
        } catch let decodingError as DecodingError {
            switch decodingError {
            case .typeMismatch(let type, let context):
                print("Type mismatch for type \(type) in context \(context)")
            case .valueNotFound(let type, let context):
                print("Value not found for type \(type) in context \(context)")
            case .keyNotFound(let key, let context):
                print("Key '\(key.stringValue)' not found in context \(context)")
            case .dataCorrupted(let context):
                print("Data corrupted in context \(context)")
            @unknown default:
                print("Unknown decoding error: \(decodingError)")
            }
            throw NetworkError.failedToDecodeResponse
        }
    } catch NetworkError.badUrl {
        print("There was an error creating the URL")
        throw NetworkError.badUrl
    } catch NetworkError.badResponse {
        print("Did not get a valid response")
        throw NetworkError.badResponse
    } catch NetworkError.badStatus {
        print("Did not get a 2xx status code from the response")
        throw NetworkError.badStatus
    } catch NetworkError.failedToDecodeResponse {
        print("Failed to decode response into the given type")
        throw NetworkError.failedToDecodeResponse
    } catch {
        print("An error occurred downloading the data: \(error)")
        throw error
    }
    
}
