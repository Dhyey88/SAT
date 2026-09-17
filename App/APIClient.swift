import Foundation

/// Standard API Error Definitions
enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case parsingError
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid request URL."
        case .networkError(let error):
            return error.localizedDescription
        case .invalidResponse:
            return "Invalid server response received."
        case .parsingError:
            return "Failed to parse server data."
        case .serverError(let message):
            return message
        }
    }
}

/// Centralized, high-performance HTTP client for the SAT iOS application.
/// Provides RFC 3986 compliant form-urlencoded encoding, standard 15-second timeouts,
/// automatic header injection, and main-queue completion dispatch.
final class APIClient {

    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15.0
        config.timeoutIntervalForResource = 30.0
        config.waitsForConnectivity = true
        return URLSession(configuration: config)
    }()

    /// Strict RFC 3986 compliant character set for application/x-www-form-urlencoded bodies.
    /// Preserves alphanumerics, '-', '.', '_', '~', and percent-encodes all others (including +, &, =, #, space).
    private static let formUrlAllowedCharacters: CharacterSet = {
        var set = CharacterSet.alphanumerics
        set.insert(charactersIn: "-._~")
        return set
    }()

    /// Encodes a dictionary of parameters into an RFC 3986 compliant application/x-www-form-urlencoded string.
    static func encodeFormParameters(_ parameters: [String: Any]) -> String {
        return parameters.map { key, value in
            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: formUrlAllowedCharacters) ?? key
            let stringVal = "\(value)"
            let encodedValue = stringVal.addingPercentEncoding(withAllowedCharacters: formUrlAllowedCharacters) ?? stringVal
            return "\(encodedKey)=\(encodedValue)"
        }.joined(separator: "&")
    }

    /// Performs an asynchronous POST request with form-urlencoded parameters.
    static func post(
        endpoint: String,
        parameters: [String: Any] = [:],
        customHeaders: [String: String] = [:],
        completion: @escaping (Result<[String: Any], APIError>) -> Void
    ) {
        guard let url = URL(string: endpoint) else {
            DispatchQueue.main.async { completion(.failure(.invalidURL)) }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(AppConfig.apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("SATApp-iOS/\(AppConfig.appVersion)", forHTTPHeaderField: "User-Agent")

        for (k, v) in customHeaders {
            request.setValue(v, forHTTPHeaderField: k)
        }

        let bodyString = encodeFormParameters(parameters)
        request.httpBody = bodyString.data(using: .utf8)

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(.networkError(error))) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.invalidResponse)) }
                return
            }

            guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
                DispatchQueue.main.async { completion(.failure(.parsingError)) }
                return
            }

            DispatchQueue.main.async { completion(.success(json)) }
        }.resume()
    }

    /// Performs an asynchronous GET request.
    static func get(
        endpoint: String,
        completion: @escaping (Result<[String: Any], APIError>) -> Void
    ) {
        guard let url = URL(string: endpoint) else {
            DispatchQueue.main.async { completion(.failure(.invalidURL)) }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(AppConfig.apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("SATApp-iOS/\(AppConfig.appVersion)", forHTTPHeaderField: "User-Agent")

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(.networkError(error))) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.invalidResponse)) }
                return
            }

            guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
                DispatchQueue.main.async { completion(.failure(.parsingError)) }
                return
            }

            DispatchQueue.main.async { completion(.success(json)) }
        }.resume()
    }
}
