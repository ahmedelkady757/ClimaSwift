//
//  DependencyContainer.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//

import Swinject

class DependencyContainer {
    static let shared = DependencyContainer()
    let container = Container()
    
    private init() {
        registerDependencies()
    }
    
    private func registerDependencies() {
        container.register(DynamicThemeEngine.self) { _ in
            DynamicThemeEngine()
        }.inObjectScope(.container)
        
    }
}
