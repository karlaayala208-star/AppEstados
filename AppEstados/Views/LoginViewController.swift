//
//  LoginViewController.swift
//  AppEstados
//
//  Created by Jose David on 26/06/25.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var txtUsuario: UITextField!
    @IBOutlet weak var txtPasword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnRegistro: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        txtUsuario.placeholder = "Email"
        txtUsuario.borderStyle = .roundedRect
        txtUsuario.keyboardType = .emailAddress
        txtUsuario.autocapitalizationType = .none
        txtUsuario.translatesAutoresizingMaskIntoConstraints = false
        
        txtPasword.placeholder = "Password"
        txtPasword.borderStyle = .roundedRect
        txtPasword.isSecureTextEntry = true
        txtPasword.translatesAutoresizingMaskIntoConstraints = false
        
        // Configuración del botón de login
        btnLogin.setTitle("Login", for: .normal)
        btnLogin.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        btnLogin.translatesAutoresizingMaskIntoConstraints = false
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
            
            // Login exitoso, navegar al siguiente ViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mainVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                self.navigationController?.pushViewController(mainVC, animated: true)
            }
        }
    }
    
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
