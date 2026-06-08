//
//  FaceIDViewController.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/28/26.
//

import UIKit

class FaceIDViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        authenticateWithFaceID()
    }

    private func authenticateWithFaceID() {
        FaceIDService.shared.authenticate { [weak self] success in
            if success {
                self?.moveToMain()
            } else {
                self?.moveToLogin()
            }
        }
    }

    private func moveToMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")

        changeRootViewController(to: mainVC)
    }

    private func moveToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let loginNav = storyboard.instantiateViewController(withIdentifier: "LoginNavigationController")

        changeRootViewController(to: loginNav)
    }

    private func changeRootViewController(to viewController: UIViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate
        else {
            return
        }

        sceneDelegate.window?.rootViewController = viewController
        sceneDelegate.window?.makeKeyAndVisible()
    }
}
