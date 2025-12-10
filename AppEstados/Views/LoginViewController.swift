//
//  LoginViewController.swift
//  AppEstados
//
//  Created by Jose David on 26/06/25.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var txtUsuario: UITextField!
    @IBOutlet weak var txtPasword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnRegistro: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboardObservers()
        
        // Agregar tap gesture para cerrar el teclado
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        // Scroll para mostrar el campo de texto activo
        if let activeField = findFirstResponder() {
            let rect = activeField.convert(activeField.bounds, to: scrollView)
            scrollView.scrollRectToVisible(rect, animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    func findFirstResponder() -> UIView? {
        let textFields = [txtUsuario, txtPasword]
        return textFields.compactMap { $0 }.first { $0.isFirstResponder }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func loginTapped() {
        guard let email = txtUsuario.text, !email.isEmpty,
              let password = txtPasword.text, !password.isEmpty else {
            mostrarAlerta(titulo: "Error", mensaje: "Por favor completa todos los campos")
            return
        }
        
        // Iniciar sesión con Firebase Authentication
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                // Error al iniciar sesión
                self.mostrarAlerta(titulo: "Error de autenticación", mensaje: error.localizedDescription)
                return
            }
            
            // Verificar si el correo electrónico está verificado
            guard let user = authResult?.user, user.isEmailVerified else {
                // Cerrar sesión si el correo no está verificado
                try? Auth.auth().signOut()
                self.mostrarAlerta(titulo: "Correo no verificado", mensaje: "Por favor verifica tu correo electrónico antes de iniciar sesión. Revisa tu bandeja de entrada y la carpeta de spam.")
                return
            }
            
            // Login exitoso, navegar al siguiente ViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mainVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                // Pasar el nombre del usuario al ViewController
                mainVC.nombreUsuario = authResult?.user.displayName
                self.navigationController?.pushViewController(mainVC, animated: true)
            }
        }
    }
    
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
