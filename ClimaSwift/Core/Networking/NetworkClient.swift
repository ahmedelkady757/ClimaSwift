//
//  NetworkClient.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//

import Alamofire
import Foundation

protocol NetworkClientProtocol {
    func request<T: Decodable>(_ route: URLRequestConvertible) async throws -> T
}

class NetworkClient: NetworkClientProtocol {
    static let shared = NetworkClient()
    
    private let session: Session
    
    private init() {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30
        session = Session(configuration: configuration)
    }
    
    func request<T: Decodable>(_ route: URLRequestConvertible) async throws -> T {
        return try await session.request(route)
            .serializingDecodable(T.self)
            .value
    }
}

enum WeatherEndpoint: URLRequestConvertible {
    case forecast(lat: Double, lon: Double, days: Int, apiKey: String)
    
    var baseURL: URL {
        return URL(string: "http://api.weatherapi.com/v1")!
    }
    
    var path: String {
        switch self {
        case .forecast:
            return "/forecast.json"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters {
        switch self {
        case let .forecast(lat, lon, days, apiKey):
            return [
                "key": apiKey,
                "q": "\(lat),\(lon)",
                "days": days,
                "aqi": "yes",
                "alerts": "no"
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
