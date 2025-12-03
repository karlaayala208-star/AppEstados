//
//  RegisterViewController.swift
//  AppEstados
//
//  Created by Jose David on 02/12/25.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtUsuario: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnRegistrar: UIButton!

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
        let textFields = [txtNombre, txtEmail, txtUsuario, txtPassword, txtConfirmPassword]
        return textFields.compactMap { $0 }.first { $0.isFirstResponder }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func registrarTapped() {
        // Validar campos vacíos
        guard let nombre = txtNombre.text, !nombre.isEmpty,
              let email = txtEmail.text, !email.isEmpty,
              let usuario = txtUsuario.text, !usuario.isEmpty,
              let password = txtPassword.text, !password.isEmpty,
              let confirmPassword = txtConfirmPassword.text, !confirmPassword.isEmpty else {
            mostrarAlerta(titulo: "Error", mensaje: "Por favor completa todos los campos")
            return
        }
        
        // Validar email
        if !isValidEmail(email) {
            mostrarAlerta(titulo: "Error", mensaje: "Por favor ingresa un email válido")
            return
        }
        
        // Validar que las contraseñas coincidan
        if password != confirmPassword {
            mostrarAlerta(titulo: "Error", mensaje: "Las contraseñas no coinciden")
            return
        }
        
        // Validar longitud de contraseña
        if password.count < 6 {
            mostrarAlerta(titulo: "Error", mensaje: "La contraseña debe tener al menos 6 caracteres")
            return
        }
        
        // Registrar usuario en Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                // Error al registrar
                self.mostrarAlerta(titulo: "Error de registro", mensaje: error.localizedDescription)
                return
            }
            
            // Registro exitoso, actualizar el perfil con el nombre
            if let user = authResult?.user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = nombre
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("Error al actualizar perfil: \(error.localizedDescription)")
                    }
                }
            }
            
            // Mostrar mensaje de éxito y regresar al login
            let alert = UIAlertController(title: "¡Éxito!", message: "Usuario registrado correctamente en Firebase", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            })
            self.present(alert, animated: true)
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
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
