//
//  EditarPerfilViewController.swift
//  AppEstados
//
//  Created by Copilot
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class EditarPerfilViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - UI Elements
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Editar Perfil"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 60
        imageView.backgroundColor = .systemGray5
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemGray3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.circle.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.backgroundColor = .white
        button.layer.cornerRadius = 18
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let changePhotoLabel: UILabel = {
        let label = UILabel()
        label.text = "Toca para cambiar foto"
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nombreTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Nombre completo"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        textField.autocapitalizationType = .words
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let nombreLabel: UILabel = {
        let label = UILabel()
        label.text = "Nombre completo"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.isEnabled = false
        textField.backgroundColor = .systemGray6
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email (no se puede cambiar)"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usuarioTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Usuario"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let usuarioLabel: UILabel = {
        let label = UILabel()
        label.text = "Usuario"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let edadTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Edad"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let edadLabel: UILabel = {
        let label = UILabel()
        label.text = "Edad"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let guardarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Guardar Cambios", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Editar Perfil"
        
        setupUI()
        cargarDatosUsuario()
        
        // Agregar gesture recognizer para cerrar el teclado
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(changePhotoLabel)
        profileImageView.addSubview(changePhotoButton)
        contentView.addSubview(nombreLabel)
        contentView.addSubview(nombreTextField)
        contentView.addSubview(emailLabel)
        contentView.addSubview(emailTextField)
        contentView.addSubview(usuarioLabel)
        contentView.addSubview(usuarioTextField)
        contentView.addSubview(edadLabel)
        contentView.addSubview(edadTextField)
        contentView.addSubview(guardarButton)
        contentView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Profile Image View
            profileImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Change Photo Button
            changePhotoButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            changePhotoButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            changePhotoButton.widthAnchor.constraint(equalToConstant: 36),
            changePhotoButton.heightAnchor.constraint(equalToConstant: 36),
            
            // Change Photo Label
            changePhotoLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            changePhotoLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Nombre Label
            nombreLabel.topAnchor.constraint(equalTo: changePhotoLabel.bottomAnchor, constant: 30),
            nombreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nombreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Nombre TextField
            nombreTextField.topAnchor.constraint(equalTo: nombreLabel.bottomAnchor, constant: 8),
            nombreTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nombreTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nombreTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Email Label
            emailLabel.topAnchor.constraint(equalTo: nombreTextField.bottomAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Email TextField
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Usuario Label
            usuarioLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            usuarioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            usuarioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Usuario TextField
            usuarioTextField.topAnchor.constraint(equalTo: usuarioLabel.bottomAnchor, constant: 8),
            usuarioTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            usuarioTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            usuarioTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Edad Label
            edadLabel.topAnchor.constraint(equalTo: usuarioTextField.bottomAnchor, constant: 20),
            edadLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            edadLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Edad TextField
            edadTextField.topAnchor.constraint(equalTo: edadLabel.bottomAnchor, constant: 8),
            edadTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            edadTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            edadTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Guardar Button
            guardarButton.topAnchor.constraint(equalTo: edadTextField.bottomAnchor, constant: 40),
            guardarButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            guardarButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            guardarButton.heightAnchor.constraint(equalToConstant: 50),
            guardarButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: guardarButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: guardarButton.centerYAnchor)
        ])
        
        // Agregar acciones
        guardarButton.addTarget(self, action: #selector(guardarCambios), for: .touchUpInside)
        changePhotoButton.addTarget(self, action: #selector(cambiarFoto), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cambiarFoto))
        profileImageView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Data Loading
    
    private func cargarDatosUsuario() {
        guard let uid = Auth.auth().currentUser?.uid,
              let email = Auth.auth().currentUser?.email else {
            mostrarAlerta(titulo: "Error", mensaje: "No se pudo obtener la información del usuario")
            return
        }
        
        emailTextField.text = email
        
        let db = Firestore.firestore()
        db.collection("usuarios").document(uid).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error al cargar datos: \(error.localizedDescription)")
                self.mostrarAlerta(titulo: "Error", mensaje: "No se pudieron cargar los datos del usuario")
                return
            }
            
            if let document = document, document.exists, let data = document.data() {
                DispatchQueue.main.async {
                    self.nombreTextField.text = data["nombre"] as? String ?? ""
                    self.usuarioTextField.text = data["usuario"] as? String ?? ""
                    
                    if let edad = data["edad"] as? Int {
                        self.edadTextField.text = "\(edad)"
                    }
                    
                    // Cargar imagen de perfil
                    if let imagenURL = data["imagenProfile"] as? String,
                       !imagenURL.isEmpty,
                       let url = URL(string: imagenURL) {
                        self.cargarImagen(desde: url)
                    }
                }
            }
        }
    }
    
    private func cargarImagen(desde url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self.profileImageView.image = image
                self.profileImageView.contentMode = .scaleAspectFill
                self.changePhotoLabel.text = "Toca para cambiar foto"
            }
        }.resume()
    }
    
    // MARK: - Actions
    
    @objc private func cambiarFoto() {
        let alert = UIAlertController(title: "Cambiar foto de perfil", message: "Selecciona una opción", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Tomar foto", style: .default) { [weak self] _ in
                self?.abrirImagePicker(sourceType: .camera)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Elegir de galería", style: .default) { [weak self] _ in
            self?.abrirImagePicker(sourceType: .photoLibrary)
        })
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = profileImageView
            popoverController.sourceRect = profileImageView.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func abrirImagePicker(sourceType: UIImagePickerController.SourceType) {
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
    
    @objc private func guardarCambios() {
        guard let uid = Auth.auth().currentUser?.uid else {
            mostrarAlerta(titulo: "Error", mensaje: "No se pudo obtener la información del usuario")
            return
        }
        
        guard let nombre = nombreTextField.text, !nombre.isEmpty else {
            mostrarAlerta(titulo: "Campo requerido", mensaje: "Por favor ingresa tu nombre completo")
            return
        }
        
        guard let usuario = usuarioTextField.text, !usuario.isEmpty else {
            mostrarAlerta(titulo: "Campo requerido", mensaje: "Por favor ingresa un nombre de usuario")
            return
        }
        
        // Mostrar indicador de carga
        activityIndicator.startAnimating()
        guardarButton.setTitle("", for: .normal)
        guardarButton.isEnabled = false
        
        // Primero subir la imagen si cambió
        if let image = profileImageView.image,
           profileImageView.image != UIImage(systemName: "person.circle.fill") {
            subirImagenPerfil(image, uid: uid, nombre: nombre, usuario: usuario)
        } else {
            actualizarDatosFirestore(uid: uid, nombre: nombre, usuario: usuario, imagenURL: nil)
        }
    }
    
    private func subirImagenPerfil(_ image: UIImage, uid: String, nombre: String, usuario: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            actualizarDatosFirestore(uid: uid, nombre: nombre, usuario: usuario, imagenURL: nil)
            return
        }
        
        let storageRef = Storage.storage().reference()
        let imagenRef = storageRef.child("profile_images/\(uid).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imagenRef.putData(imageData, metadata: metadata) { [weak self] metadata, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error al subir imagen: \(error.localizedDescription)")
                self.actualizarDatosFirestore(uid: uid, nombre: nombre, usuario: usuario, imagenURL: nil)
                return
            }
            
            imagenRef.downloadURL { url, error in
                if let error = error {
                    print("Error al obtener URL: \(error.localizedDescription)")
                    self.actualizarDatosFirestore(uid: uid, nombre: nombre, usuario: usuario, imagenURL: nil)
                } else if let url = url {
                    self.actualizarDatosFirestore(uid: uid, nombre: nombre, usuario: usuario, imagenURL: url.absoluteString)
                }
            }
        }
    }
    
    private func actualizarDatosFirestore(uid: String, nombre: String, usuario: String, imagenURL: String?) {
        let db = Firestore.firestore()
        var datosActualizados: [String: Any] = [
            "nombre": nombre,
            "usuario": usuario,
            "fechaActualizacion": FieldValue.serverTimestamp()
        ]
        
        // Agregar edad si está presente
        if let edadTexto = edadTextField.text, !edadTexto.isEmpty, let edad = Int(edadTexto) {
            datosActualizados["edad"] = edad
        }
        
        // Agregar URL de imagen si está presente
        if let imagenURL = imagenURL {
            datosActualizados["imagenProfile"] = imagenURL
        }
        
        db.collection("usuarios").document(uid).updateData(datosActualizados) { [weak self] error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.guardarButton.setTitle("Guardar Cambios", for: .normal)
                self.guardarButton.isEnabled = true
                
                if let error = error {
                    print("Error al actualizar: \(error.localizedDescription)")
                    self.mostrarAlerta(titulo: "Error", mensaje: "No se pudieron guardar los cambios: \(error.localizedDescription)")
                } else {
                    // Actualizar el displayName en Firebase Auth
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = nombre
                    changeRequest?.commitChanges { error in
                        if let error = error {
                            print("Error al actualizar displayName: \(error.localizedDescription)")
                        }
                    }
                    
                    let alert = UIAlertController(
                        title: "¡Éxito!",
                        message: "Los cambios se guardaron correctamente",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        self.navigationController?.popViewController(animated: true)
                    })
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func mostrarAlerta(titulo: String, mensaje: String) {
        let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
