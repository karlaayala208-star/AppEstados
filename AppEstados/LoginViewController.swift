//
//  LoginViewController.swift
//  AppEstados
//
//  Created by Jose David on 26/06/25.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var txtUsuario: UITextField!
    @IBOutlet weak var txtPasword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        txtUsuario.placeholder = "Username"
        txtUsuario.borderStyle = .roundedRect
        txtUsuario.translatesAutoresizingMaskIntoConstraints = false

        txtPasword.placeholder = "Password"
        txtPasword.borderStyle = .roundedRect
        txtPasword.isSecureTextEntry = true
        txtPasword.translatesAutoresizingMaskIntoConstraints = false

        btnLogin.setTitle("Login", for: .normal)
        btnLogin.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        btnLogin.translatesAutoresizingMaskIntoConstraints = false
    }

    @objc func loginTapped() {
        let user = txtUsuario.text ?? ""
        let pass = txtPasword.text ?? ""
        if user == "admin" && pass == "1234" {
            // Navegar al siguiente ViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mainVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                navigationController?.pushViewController(mainVC, animated: true)
            }
        } else {
            //muestra alerta de error, credenciales invalidas
            let alert = UIAlertController(title: "Error", message: "Credenciales Invalidas", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
