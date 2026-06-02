import Alamofire
import Foundation

enum SearchEndpoint: URLRequestConvertible {
    case search(query: String, apiKey: String)

    var baseURL: URL {
        return URL(string: "https://api.weatherapi.com/v1")!
    }

    var path: String {
        return "/search.json"
    }

    var method: HTTPMethod {
        return .get
    }

    var parameters: Parameters {
        switch self {
        case let .search(query, apiKey):
            return [
                "key": apiKey,
                "q": query
            ]
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method
        return try URLEncoding.default.encode(request, with: parameters)
    }
}
