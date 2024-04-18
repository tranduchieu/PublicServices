//
//  PreviewContainer.swift
//  DanceFitme
//
//  Created by Hieu Tran on 14/04/2024.
//

import SwiftData

public struct PreviewContainer {
    
    public let container: ModelContainer!
    
    public init(_ types: [any PersistentModel.Type]) {
        let schema = Schema(types)
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        self.container = try! ModelContainer(for: schema, configurations: [configuration])
    }
    
    public func add(items: [any PersistentModel]) {
        Task { @MainActor in
            items.forEach { container.mainContext.insert($0) }
        }
    }
}
