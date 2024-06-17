//
//  AuthViewController.swift
//  myToDoList
//
//  Created by 1234 on 17.06.2024.
//

import UIKit
import Firebase
import FirebaseDatabase
import GoogleSignInSwift
import GoogleSignIn

class AuthViewController: UIViewController {
    
    // MARK: - State
    
    private var signUp: Bool = true
    
    // MARK: - Outlets
    
    private lazy var loginView: CustomLoginView = {
        let view = CustomLoginView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "У вас уже есть аккаунт?"
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign in", for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(switchLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var restorePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Восстановить пароль", for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(restorePassword), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var googleSignInButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.style = .wide
        button.colorScheme = .light
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addTarget(self, action: #selector(googleLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        pushProfile()
        setupHierarchy()
        setupLayout()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loginView.setGradientBackground()
    }
    
    // MARK: - Setup
    
    private func setupHierarchy() {
        view.addSubview(loginView)
        view.addSubview(messageLabel)
        view.addSubview(signInButton)
        view.addSubview(restorePasswordButton)
        view.addSubview(googleSignInButton)
        view.addSubview(activityIndicator)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            loginView.topAnchor.constraint(equalTo: view.topAnchor),
            loginView.widthAnchor.constraint(equalToConstant: view.frame.width),
            loginView.leftAnchor.constraint(equalTo: view.leftAnchor),
            loginView.heightAnchor.constraint(equalToConstant: 381),
            
            messageLabel.topAnchor.constraint(equalTo: loginView.bottomAnchor, constant: 30),
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            signInButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            restorePasswordButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
            restorePasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            googleSignInButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor,constant: 70),
            googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    // MARK: - Actions
    
    @objc func switchLogin() {
        signUp.toggle()
        loginView.signInLabel.text = "Вход"
        messageLabel.text = "Забыли пароль?"
        signInButton.isHidden = true
        restorePasswordButton.isHidden = false
        googleSignInButton.isHidden = false
    }
    @objc func googleLogin() {
        self.signInGoogle(vc: self)
    }
    
    @objc func restorePassword() {
        present(PasswordResetViewController(), animated: true)
    }
    
    // MARK: - Methods
    
    func pushProfile() {
        loginView.onCompletion = { [weak self] in
            guard let self = self,
                  let userEmail = self.loginView.emailTextField.text,
                  let password = self.loginView.passwordTextField.text else {
                return
            }
            
            if self.signUp {
                self.registerUser(email: userEmail, password: password, vc: self)
            } else {
                self.signInUser(email: userEmail, password: password, vc: self)
            }
        }
    }
    
    func signInGoogle(vc: UIViewController) {
        let clientID = "314380970987-1be5qpjccemlln4n0imcol4jcdmkom9b.apps.googleusercontent.com"
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: vc) { [weak self] result, error in
            guard error == nil else {
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential){ [weak self] (authResult, error) in
                guard let self = self else {
                    return
                }
                
                if let error = error {
                    print("Ошибка при входе в акк: \(error.localizedDescription)")
                    ShowAlert.shared.alert(
                        view: vc,
                        title: "Error",
                        message: "Error",
                        completion: nil)
                } else {
                    if let result = authResult {
                        print(result.user.uid)
                        vc.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    func registerUser(email: String, password: String, vc: UIViewController) {
        // Создаем экземпляр модели данных для формы регистрации
        let registrationForm = RegistrationForm(email: email, password: password)
        
        // Проверяем валидность данных
        registrationForm.validate(completion: { message in
            guard let message = message else {
                return
            }
            
            ShowAlert.shared.alert(
                view: vc,
                title: "Oops!",
                message: message,
                completion: nil)
        })
        
        // Если данные прошли валидацию, регистрируем пользователя через Firebase
        Auth.auth().createUser(withEmail: email, password: password) {[weak self] authResult, error in
            guard let self = self else {
                return
            }
            
            if let error = error {
                print("Ошибка при создании пользователя: \(error.localizedDescription)")
                ShowAlert.shared.alert(
                    view: vc,
                    title: "Error",
                    message: error.localizedDescription,
                    completion: nil)
            } else {
                if let result = authResult {
                    print(result.user.uid)
                    let ref = Database.database().reference().child("users")
                    ref.child(result.user.uid).updateChildValues(["email" : email])
                    // Пользователь успешно создан
                    // Отправляем письмо с подтверждением email
                    result.user.sendEmailVerification(completion: { error in
                        if let error = error {
                            // Ошибка при отправке письма с подтверждением email
                            print("Ошибка при отправке письма с подтверждением email: \(error.localizedDescription)")
                            ShowAlert.shared.alert(
                                view: vc,
                                title: "Oops!",
                                message: "Ошибка при отправке письма с подтверждением email",
                                completion: nil)
                        } else {
                            ShowAlert.shared.alert(
                                view: vc,
                                title: "",
                                message: "Письмо с подтверждением email успешно отправлено",
                                completion: nil)
                        }
                    })
                }
            }
        }
    }
    
    func signInUser(email: String, password: String, vc: UIViewController) {
        // Создаем экземпляр модели данных для формы регистрации
        let registrationForm = RegistrationForm(email: email, password: password)
        
        // Проверяем валидность данных
        registrationForm.validate(completion: {  message in
            guard let message = message else {
                return
            }
            
            ShowAlert.shared.alert(
                view: vc,
                title: "Oops!",
                message: message,
                completion: nil)
        })
        
        // Если данные прошли валидацию, осуществляем вход
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            guard let self = self else {
                return
            }
                        
            if let error = error {
                print("Ошибка при входе в акк: \(error.localizedDescription)")
                ShowAlert.shared.alert(
                    view: vc,
                    title: "Error",
                    message: "Возможно допущена ошибка в пароле, перепроверьте данные",
                    completion: nil)
            } else {
                vc.dismiss(animated: true)
            }
        }
    }
}

