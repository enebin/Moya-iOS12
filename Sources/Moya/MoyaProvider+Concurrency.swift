//
//  MoyaProvider+Concurrency.swift
//  Moya
//
//  Created by Kai Lee on 7/16/24.
//

import Foundation

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension MoyaProvider {
    /// Designated request-making method.
    ///
    /// - Parameters:
    ///   - target: Entity, which provides specifications necessary for a `MoyaProvider`.
    ///   - callbackQueue: Callback queue. If nil - queue from provider initializer will be used.
    /// - Returns: `Response` on success.
    func request(_ target: Target, callbackQueue: DispatchQueue? = nil) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            self.request(target, callbackQueue: callbackQueue, progress: nil) { result in
                switch result {
                case let .success(response):
                    continuation.resume(returning: response)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Designated request-making method with progress.
    func requestWithProgress(_ target: Target, callbackQueue: DispatchQueue? = nil) async throws -> [ProgressResponse] {
        try await withCheckedThrowingContinuation { continuation in
            var progressResponses: [ProgressResponse] = []
            
            let progressBlock: (ProgressResponse) -> Void = { progress in
                progressResponses.append(progress)
            }
            
            self.request(target, callbackQueue: callbackQueue, progress: progressBlock) { result in
                switch result {
                case .success:
                    continuation.resume(returning: progressResponses)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
