//
//  ViewController.swift
//  AppEstados
//
//  Created by Karla Ayala on 23/06/25.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var btnAprender: UIButton!
    @IBOutlet weak var btnPrueba: UIButton!
    
    // Propiedad para almacenar el nombre del usuario
    var nombreUsuario: String?
    
    // Vista del banner de perfil
    private let profileBannerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        imageView.backgroundColor = .systemGray5
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemGray3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.circle.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let changePhotoLabel: UILabel = {
        let label = UILabel()
        label.text = "Toca para cambiar foto"
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
        
        // Configurar el título del NavigationBar con el nombre del usuario
        configurarNavigationBar()
        
        // Configurar el banner de perfil
        setupProfileBanner()
    }
    
    func configurarNavigationBar() {
        // Obtener el nombre del usuario desde Firebase o usar el nombre proporcionado
        if let user = Auth.auth().currentUser {
            let displayName = user.displayName ?? "Usuario"
            self.title = "Hola, \(displayName)"
            userNameLabel.text = displayName
        } else if let nombre = nombreUsuario {
            self.title = "Hola, \(nombre)"
            userNameLabel.text = nombre
        } else {
            self.title = "Hola, Usuario"
            userNameLabel.text = "Usuario"
        }
        
        // Opcional: Agregar botón de cerrar sesión
        let logoutButton = UIBarButtonItem(title: "Salir", style: .plain, target: self, action: #selector(cerrarSesion))
        self.navigationItem.rightBarButtonItem = logoutButton
    }
    
    func setupProfileBanner() {
        // Agregar el banner de perfil a la vista
        view.addSubview(profileBannerView)
        profileBannerView.addSubview(profileImageView)
        profileBannerView.addSubview(userNameLabel)
        profileBannerView.addSubview(changePhotoLabel)
        profileImageView.addSubview(cameraButton)
        
        // Configurar las constraints
        NSLayoutConstraint.activate([
            // Banner view
            profileBannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            profileBannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileBannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            profileBannerView.heightAnchor.constraint(equalToConstant: 100),
            
            // Profile image
            profileImageView.centerYAnchor.constraint(equalTo: profileBannerView.centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: profileBannerView.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Camera button
            cameraButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            cameraButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            cameraButton.widthAnchor.constraint(equalToConstant: 30),
            cameraButton.heightAnchor.constraint(equalToConstant: 30),
            
            // User name label
            userNameLabel.topAnchor.constraint(equalTo: profileBannerView.topAnchor, constant: 28),
            userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            userNameLabel.trailingAnchor.constraint(equalTo: profileBannerView.trailingAnchor, constant: -16),
            
            // Change photo label
            changePhotoLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 4),
            changePhotoLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            changePhotoLabel.trailingAnchor.constraint(equalTo: profileBannerView.trailingAnchor, constant: -16),
        ])
        
        // Agregar tap gesture a la imagen de perfil
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
        
        // Agregar acción al botón de cámara
        cameraButton.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)
    }
    
    @objc func profileImageTapped() {
        let alert = UIAlertController(title: "Cambiar foto de perfil", message: "Selecciona una opción", preferredStyle: .actionSheet)
        
        // Opción para tomar foto
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Tomar foto", style: .default) { [weak self] _ in
                self?.openImagePicker(sourceType: .camera)
            })
        }
        
        // Opción para seleccionar de galería
        alert.addAction(UIAlertAction(title: "Elegir de galería", style: .default) { [weak self] _ in
            self?.openImagePicker(sourceType: .photoLibrary)
        })
        
        // Opción para cancelar
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        // Para iPad
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = profileImageView
            popoverController.sourceRect = profileImageView.bounds
        }
        
        present(alert, animated: true)
    }
    
    func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let editedImage = info[.editedImage] as? UIImage {
            profileImageView.image = editedImage
            profileImageView.contentMode = .scaleAspectFill
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageView.image = originalImage
            profileImageView.contentMode = .scaleAspectFill
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    @objc func cerrarSesion() {
        do {
            try Auth.auth().signOut()
            // Volver al LoginViewController
            self.navigationController?.popToRootViewController(animated: true)
        } catch let error {
            mostrarAlerta(titulo: "Error", mensaje: "No se pudo cerrar sesión: \(error.localizedDescription)")
        }
    }
    
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

  
    @IBAction func btnAprender(_ sender: UIButton) {
//        performSegue(withIdentifier: "IrMapa", sender: self)
        let vc = MapaViewController()
        if let navigationController = self.navigationController {
            navigationController.pushViewController(vc, animated: true)
        } else {
            present(vc, animated: true)
        }
    }
    
    @IBAction func btnPrueba(_ sender: UIButton) {
        //performSegue(withIdentifier: "IrCuestionario", sender: self)
        let vc = CuestionarioViewController()
        if let navigationController = self.navigationController {
            navigationController.pushViewController(vc, animated: true)
        } else {
            present(vc, animated: true)
        }
    }
    
    

    
    
}

