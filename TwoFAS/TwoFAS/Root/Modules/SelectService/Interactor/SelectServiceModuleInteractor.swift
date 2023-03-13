//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2023 Two Factor Authentication Service, Inc.
//  Contributed by Zbigniew Cisiński. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <https://www.gnu.org/licenses/>
//

import Foundation
import Storage
import Common

protocol SelectServiceModuleInteracting: AnyObject {
    func listServices(filter: String?, for domain: String) -> (bestMatch: [ServiceData], complete: [CategoryData])
    func browserName(for extensionID: ExtensionID) -> String
}

final class SelectServiceModuleInteractor {
    private let listingInteractor: ServiceListingInteracting
    private let serviceDefinitionInteractor: ServiceDefinitionInteracting
    private let sortInteractor: SortInteracting
    private let pairedBrowsers: PairingWebExtensionInteracting
    
    private var bestServiceTypes: [ServiceTypeID]?
    
    init(
        listingInteractor: ServiceListingInteracting,
        serviceDefinitionInteractor: ServiceDefinitionInteracting,
        sortInteractor: SortInteracting,
        pairedBrowsers: PairingWebExtensionInteracting
    ) {
        self.listingInteractor = listingInteractor
        self.serviceDefinitionInteractor = serviceDefinitionInteractor
        self.sortInteractor = sortInteractor
        self.pairedBrowsers = pairedBrowsers
    }
}

extension SelectServiceModuleInteractor: SelectServiceModuleInteracting {
    func listServices(filter: String?, for domain: String) -> (bestMatch: [ServiceData], complete: [CategoryData]) {
        let currentSort = sortInteractor.currentSort
        let tags: [ServiceTypeID] = {
            guard let filter else { return [] }
            return serviceDefinitionInteractor.findServices(byTag: filter)
                .map({ $0.serviceTypeID })
        }()
        var list = listingInteractor
            .listAllWithingCategories(for: filter, sorting: currentSort, tags: tags)
            .filter({ !$0.services.isEmpty })
        
        var bestMatch: [ServiceData] = []
        
        if bestServiceTypes == nil {
            bestServiceTypes = serviceDefinitionInteractor.findServices(domain: domain)
                .map({ $0.serviceTypeID })
        }
        
        if let bestServiceTypes {
            list.forEach { category in
                category.services.forEach { service in
                    if domain.uppercased().contains(service.name.uppercased()) {
                        bestMatch.append(service)
                    } else if let typeID = service.serviceTypeID, bestServiceTypes.contains(typeID) {
                        bestMatch.append(service)
                    }
                }
            }
        }
        
        return (bestMatch: bestMatch, complete: list)
    }
    
    func browserName(for extensionID: ExtensionID) -> String {
        pairedBrowsers.listAll().first(where: { $0.extensionID == extensionID })?.name ?? T.Browser.unkownName
    }
}
