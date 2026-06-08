//
//  LoginViewController.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/11/26.
//

import UIKit

class LoginViewController : UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var eyeBtn: UIButton!
    
    private weak var activeTextField: UITextField?
    private var originalViewY: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        originalViewY = view.frame.origin.y
        
        passwordTextField.isSecureTextEntry = true
        eyeBtn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        
        setUpTextField();
        setupTextFieldDelegate()
        setupPasswordRightView()
        setupKeyboardObservers()
        setupTapGesture()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUpTextField() {
        let textFields = [
            emailTextField,
            passwordTextField,
        ]
        
        textFields.forEach { tf in
            tf?.backgroundColor = UIColor(named: "StaticColor") ?? .white
            tf?.layer.cornerRadius = 12
            tf?.layer.borderWidth = 1
            tf?.layer.borderColor = UIColor(named: "LightTextColor")?.cgColor ?? UIColor.systemGray4.cgColor
            tf?.heightAnchor.constraint(equalToConstant: 50).isActive = true
            tf?.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
            tf?.leftViewMode = .always
            
            tf?.layer.shadowColor = UIColor(named: "DarkBackgroundColor")?.cgColor ?? UIColor.black.cgColor
            tf?.layer.shadowOpacity = 0.05
            tf?.layer.shadowOffset = CGSize(width: 0, height: 2)
            tf?.layer.shadowRadius = 4
            
            tf?.text = ""
        }
    }
    
    private func setupTextFieldDelegate() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    private func setupPasswordRightView() {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 50))
        eyeBtn.frame = CGRect(x: 8, y: 0, width: 32, height: 50)
        container.addSubview(eyeBtn)

        passwordTextField.rightView = container
        passwordTextField.rightViewMode = .always
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func showPassword(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()

        if passwordTextField.isSecureTextEntry {
            eyeBtn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            eyeBtn.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        guard let email = emailTextField.text,
              !email.isEmpty else {
            showAlert(message: "이메일을 입력해주세요.")
            return
        }

        guard let password = passwordTextField.text,
              !password.isEmpty else {
            showAlert(message: "비밀번호를 입력해주세요.")
            return
        }
        
        passwordTextField.text = ""

        AuthService.shared.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {

                case .success:
                    self?.fetchUserAndMoveToMain()

                case .failure(let error):
                    let message = FirebaseAuthErrorMessage.convert(error)
                    self?.showAlert(message: message)
                }
            }
        }
    }
    
    private func fetchUserAndMoveToMain() {
        AuthService.shared.fetchCurrentUser { [weak self] result in
            DispatchQueue.main.async {
                switch result {

                case .success:
                    print((UserSession.shared.currentUser?.nickname ?? "") + "님이 로그인 하셨습니다.")
                    self?.moveToMainTabBar()

                case .failure(let error):
                    self?.showAlert(message: error.localizedDescription)
                }
            }
        }
    }

    private func moveToMainTabBar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let tabBarVC = storyboard.instantiateViewController(
            withIdentifier: "MainTabBarController"
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {

            sceneDelegate.window?.rootViewController = tabBarVC
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "알림",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "확인", style: .default))

        present(alert, animated: true)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let activeTextField = activeTextField,
              let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else {
            return
        }

        let textFieldFrame = activeTextField.convert(activeTextField.bounds, to: view)
        let textFieldBottomY = textFieldFrame.maxY

        let keyboardTopY = view.bounds.height - keyboardFrame.height
        let padding: CGFloat = 20

        if textFieldBottomY > keyboardTopY - padding {
            let moveY = textFieldBottomY - keyboardTopY + padding
            view.frame.origin.y = originalViewY - moveY
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = originalViewY
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // ------------------------------------------------------
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if activeTextField == textField {
            activeTextField = nil
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }

        return true
    }
}
