//
//  MyPageViewController.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/11/26.
//

import UIKit

class MyPageViewController: UIViewController {

    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var myPageView: UIView!
    @IBOutlet weak var profileView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadUserInfo()
    }

    private func setupUI() {
        profileView.layer.cornerRadius = profileView.frame.width / 2
        profileView.layer.cornerCurve = .continuous
        profileView.clipsToBounds = true
        
        myPageView.layer.cornerRadius = 30
        myPageView.layer.cornerCurve = .continuous
        myPageView.clipsToBounds = true
    }

    private func loadUserInfo() {
        if let user = UserSession.shared.currentUser {
            nicknameLabel.text = user.nickname + "님"
            return
        }

        AuthService.shared.fetchCurrentUser { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.nicknameLabel.text = user.nickname + "님"

                case .failure(let error):
                    print("사용자 정보 조회 실패:", error.localizedDescription)
                    self?.nicknameLabel.text = "NotFound"
                }
            }
        }
    }

    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        let result = AuthService.shared.logout()

        switch result {
        case .success:
            moveToLoginViewController()

        case .failure(let error):
            print("로그아웃 실패:", error.localizedDescription)
        }
    }

    private func moveToLoginViewController() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let loginNavigationController = storyboard.instantiateViewController(withIdentifier: "LoginNavigationController")

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {

            sceneDelegate.window?.rootViewController = loginNavigationController
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
}
