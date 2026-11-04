//
//  ReferenceDataCache.swift
//  VOILA
//
//  Created by Antony Rudkovsky on 7/15/26.
//

import Foundation

protocol DiskCacheable: Codable {
    static var cacheKey: String { get }
}

final class ReferenceDataCache<T: DiskCacheable> {
    private let url: URL
    
    init(filename: String = T.cacheKey) {
        url = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
    }
    
    func load() -> T? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    func save(_ value: T) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        try? data.write(to: url, options: .atomic)
    }
}
