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

import UIKit
import Data

protocol RootModuleInteracting: AnyObject {
    var introductionWasShown: Bool { get }
    var isAuthenticationRequired: Bool { get }
    var storageError: ((String) -> Void)? { get set }
    
    func initializeApp()
    func applicationWillResignActive()
    func applicationWillEnterForeground()
    func applicationDidBecomeActive()
    func applicationWillTerminate()
    
    func markIntroAsShown()
    func lockApplicationIfNeeded(presentLoginImmediately: @escaping () -> Void)
    
    func shouldHandleURL(url: URL) -> Bool

    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data)
    func didFailToRegisterForRemoteNotifications(with error: Error)
    func didReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    )
}

final class RootModuleInteractor {
    var storageError: ((String) -> Void)?
    
    private let rootInteractor: RootInteracting
    private let linkInteractor: LinkInteracting
    private let fileInteractor: FileInteracting
    private let registerDeviceInteractor: RegisterDeviceInteracting
    
    init(
        rootInteractor: RootInteracting,
        linkInteractor: LinkInteracting,
        fileInteractor: FileInteracting,
        registerDeviceInteractor: RegisterDeviceInteracting
    ) {
        self.rootInteractor = rootInteractor
        self.linkInteractor = linkInteractor
        self.fileInteractor = fileInteractor
        self.registerDeviceInteractor = registerDeviceInteractor
        
        rootInteractor.storageError = { [weak self] error in
            self?.storageError?(error)
        }
    }
}

extension RootModuleInteractor: RootModuleInteracting {
    var introductionWasShown: Bool {
        rootInteractor.introductionWasShown
    }
    
    var isAuthenticationRequired: Bool {
        rootInteractor.isAuthenticationRequired
    }
    
    func initializeApp() {
        rootInteractor.initializeApp()
        registerDeviceInteractor.initialize()
    }
    
    func markIntroAsShown() {
        rootInteractor.markIntroAsShown()
    }
    
    func lockApplicationIfNeeded(presentLoginImmediately: @escaping () -> Void) {
        rootInteractor.lockApplicationIfNeeded(
            presentLoginImmediately: presentLoginImmediately
        )
    }
    
    func applicationWillResignActive() {
        rootInteractor.applicationWillResignActive()
    }
    
    func applicationWillEnterForeground() {
        rootInteractor.applicationWillEnterForeground()
    }
    
    func applicationWillTerminate() {
        rootInteractor.applicationWillTerminate()
    }
    
    func applicationDidBecomeActive() {
        rootInteractor.applicationDidBecomeActive()
    }
    
    func shouldHandleURL(url: URL) -> Bool {
        linkInteractor.shouldHandleURL(url: url) || fileInteractor.shouldHandleURL(url: url)
    }
    
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        rootInteractor.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    func didFailToRegisterForRemoteNotifications(with error: Error) {
        rootInteractor.didFailToRegisterForRemoteNotifications(with: error)
    }
    
    func didReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        rootInteractor.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
}
