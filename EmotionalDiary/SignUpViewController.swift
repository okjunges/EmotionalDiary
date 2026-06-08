//
//  SignUpViewController.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/11/26.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var eyeBtn1: UIButton!
    @IBOutlet weak var eyeBtn2: UIButton!
    
    private weak var activeTextField: UITextField?
    private var originalViewY: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        originalViewY = view.frame.origin.y
        
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        eyeBtn1.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        eyeBtn2.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        
        setUpTextField()
        setupTextFieldDelegate()
        setupPasswordRightViews()
        setupKeyboardObservers()
        setupTapGesture()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUpTextField() {
        let textFields = [
            nicknameTextField,
            emailTextField,
            passwordTextField,
            confirmPasswordTextField,
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
        nicknameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    private func setupPasswordRightViews() {
        let container1 = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 50))
        eyeBtn1.frame = CGRect(x: 8, y: 0, width: 32, height: 50)
        container1.addSubview(eyeBtn1)
        passwordTextField.rightView = container1
        passwordTextField.rightViewMode = .always

        let container2 = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 50))
        eyeBtn2.frame = CGRect(x: 8, y: 0, width: 32, height: 50)
        container2.addSubview(eyeBtn2)
        confirmPasswordTextField.rightView = container2
        confirmPasswordTextField.rightViewMode = .always
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
            eyeBtn1.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            eyeBtn1.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
    
    @IBAction func showPasswordCheck(_ sender: UIButton) {
        confirmPasswordTextField.isSecureTextEntry.toggle()

        if confirmPasswordTextField.isSecureTextEntry {
            eyeBtn2.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            eyeBtn2.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        
        guard let nickname = nicknameTextField.text,
              !nickname.isEmpty else {
            showAlert(message: "닉네임을 입력해주세요.")
            return
        }
        
        guard nickname.count <= 9 else {
            showAlert(message: "닉네임은 9자 이하로 설정하세요.")
            return
        }

        guard let email = emailTextField.text,
              !email.isEmpty else {
            showAlert(message: "이메일을 입력해주세요.")
            return
        }

        guard email.contains("@") else {
            showAlert(message: "올바른 이메일 형식이 아닙니다.")
            return
        }

        guard let password = passwordTextField.text,
              !password.isEmpty else {
            showAlert(message: "비밀번호를 입력해주세요.")
            return
        }

        guard password.count >= 6 else {
            showAlert(message: "비밀번호는 6자 이상이어야 합니다.")
            return
        }

        guard let confirmPassword = confirmPasswordTextField.text,
              !confirmPassword.isEmpty else {
            showAlert(message: "비밀번호 확인을 입력해주세요.")
            return
        }

        guard password == confirmPassword else {
            showAlert(message: "비밀번호가 일치하지 않습니다.")
            return
        }

        AuthService.shared.signUp(
            email: email,
            password: password,
            nickname: nickname
        ) { [weak self] result in

            DispatchQueue.main.async {
                switch result {

                case .success:
                    self?.showSignUpSuccessAlert()

                case .failure(let error):
                    let message = FirebaseAuthErrorMessage.convert(error)
                    self?.showAlert(message: message)
                }
            }
        }
    }
    
    private func showSignUpSuccessAlert() {
        let alert = UIAlertController(
            title: "회원가입 완료",
            message: "회원가입이 완료되었습니다. 로그인 화면으로 이동합니다.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })

        present(alert, animated: true)
        
        nicknameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
        confirmPasswordTextField.text = ""
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
        case nicknameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }

        return true
    }
}
