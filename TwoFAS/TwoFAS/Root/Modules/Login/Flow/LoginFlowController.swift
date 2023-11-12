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
import Common

protocol LoginFlowControllerParent: AnyObject {
    func loginClose()
    func loginLoggedIn()
}

protocol LoginFlowControlling: AnyObject {
    func toClose()
    func toLoggedIn()
    func toAppReset()
}

final class LoginFlowController: FlowController {
    private weak var parent: LoginFlowControllerParent?
    
    static func setAsCover(
        in window: UIWindow,
        parent: LoginFlowControllerParent
    ) -> (view: UIView, viewWillAppear: Callback, viewDidAppear: Callback) {
        let view = LoginView()
        let flowController = LoginFlowController(viewController: UIViewController())
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.loginModuleInteractor()
        let presenter = LoginPresenter(
            loginType: .login,
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        
        window.addSubview(view)
        view.pinToParent()
        
        let viewWillAppear: Callback = { [weak view] in
            view?.presenter.viewWillAppear()
        }
        
        let viewDidAppear: Callback = { [weak view] in
            view?.presenter.viewDidAppear()
        }
        
        return (view: view, viewWillAppear: viewWillAppear, viewDidAppear: viewDidAppear)
    }
    
    static func present(
        on viewController: UIViewController,
        parent: LoginFlowControllerParent
    ) {
//        let view = LoginViewController()
//        let flowController = LoginFlowController(viewController: view)
//        flowController.parent = parent
//        let interactor = ModuleInteractorFactory.shared.loginModuleInteractor()
//        let presenter = LoginPresenter(
//            loginType: .verify,
//            flowController: flowController,
//            interactor: interactor
//        )
//        presenter.view = view
//        view.presenter = presenter
//        view.configureAsModal()
//        
//        viewController.present(view, animated: true, completion: nil)
    }
}

extension LoginFlowController: LoginFlowControlling {
    func toClose() {
        parent?.loginClose()
    }
    
    func toLoggedIn() {
        parent?.loginLoggedIn()
    }
    
    func toAppReset() {
//        let contentMiddle = MainContainerMiddleContentGenerator(placement: .centerHorizontallyLimitWidth, elements: [
//            .image(name: "ResetShield", size: CGSize(width: 100, height: 100)),
//            .extraSpacing,
//            .text(text: T.Restore.applicationRestoration, style: MainContainerTextStyling.title),
//            .text(text: T.Restore.resetPinTitle, style: MainContainerTextStyling.content),
//            .extraSpacing,
//            .image(name: "WarningIconLarge", size: CGSize(width: 100, height: 100)),
//            .extraSpacing,
//            .text(text: T.Restore.backupAdvice, style: MainContainerTextStyling.content),
//            .text(text: T.Restore.backupTitle, style: MainContainerTextStyling.content)
//        ])
//        
//        let contentBottom = MainContainerBottomContentGenerator(elements: [
//            .extraSpacing(),
//            .filledButton(text: T.Commons.dismiss, callback: { [weak self] in
//                self?.viewController.dismiss(animated: true)
//            })
//        ])
//        
//        let config = MainContainerViewController.Configuration(
//            barConfiguration: MainContainerBarConfiguration.empty,
//            contentTop: nil,
//            contentMiddle: contentMiddle,
//            contentBottom: contentBottom,
//            generalConfiguration: nil
//        )
//        
//        let vc = MainContainerViewController()
//        vc.configure(with: config)
//        vc.isModalInPresentation = true
//        viewController.present(vc, animated: true, completion: nil)
    }
}
