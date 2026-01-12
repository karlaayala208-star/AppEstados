//
//  ViewController.swift
//  AppEstados
//
//  Created by Karla Ayala on 23/06/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var btnAprender: UIButton!
    @IBOutlet weak var btnPrueba: UIButton!
    
    // Propiedad para almacenar el nombre del usuario
    var nombreUsuario: String?
    
    // Vista del banner de perfil
    private let profileBannerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.85)
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
        imageView.layer.cornerRadius = 30
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
        button.layer.cornerRadius = 12
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
    
    private let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Editar perfil", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Vista de favoritos
    private let favoritosContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.85)
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true  // Oculto por defecto
        return view
    }()
    
    private let favoritosTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "⭐ Mis Estados Favoritos"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let favoritosStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
        
        // Configurar el banner de perfil
        setupProfileBanner()
        
        // Configurar vista de favoritos
        setupFavoritosView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Recargar datos del perfil cada vez que la vista aparece
        configurarNavigationBar()
        cargarImagenPerfil()
        
        // Recargar favoritos
        cargarFavoritos()
    }
    
    func configurarNavigationBar() {
        // Obtener el nombre del usuario desde Firebase Auth
        if let user = Auth.auth().currentUser {
            let displayName = user.displayName ?? "Usuario"
            self.title = "Hola, \(displayName)"
            userNameLabel.text = displayName
            
            // Recargar nombre desde Firestore por si se actualizó
            let uid = user.uid
            let db = Firestore.firestore()
            db.collection("usuarios").document(uid).getDocument { [weak self] document, error in
                guard let self = self,
                      let document = document,
                      document.exists,
                      let data = document.data() else { return }
                
                if let nombre = data["nombre"] as? String {
                    DispatchQueue.main.async {
                        self.title = "Hola, \(nombre)"
                        self.userNameLabel.text = nombre
                        
                        // Actualizar displayName en Firebase Auth si es diferente
                        if nombre != user.displayName {
                            let changeRequest = user.createProfileChangeRequest()
                            changeRequest.displayName = nombre
                            changeRequest.commitChanges { error in
                                if let error = error {
                                    print("Error al actualizar displayName: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                }
            }
        } else if let nombre = nombreUsuario {
            self.title = "Hola, \(nombre)"
            userNameLabel.text = nombre
        } else {
            self.title = "Hola, Usuario"
            userNameLabel.text = "Usuario"
        }
        
        // Agregar botón de cerrar sesión
        let logoutButton = UIBarButtonItem(title: "Salir", style: .plain, target: self, action: #selector(cerrarSesion))
        self.navigationItem.rightBarButtonItem = logoutButton
    }
    
    func setupProfileBanner() {
        // Agregar el banner de perfil a la vista
        view.addSubview(profileBannerView)
        profileBannerView.addSubview(profileImageView)
        profileBannerView.addSubview(userNameLabel)
        profileBannerView.addSubview(changePhotoLabel)
        profileBannerView.addSubview(editProfileButton)
        profileImageView.addSubview(cameraButton)
        
        // Configurar las constraints
        NSLayoutConstraint.activate([
            // Banner view - posicionado más cerca del top con menos altura
            profileBannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            profileBannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileBannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            profileBannerView.heightAnchor.constraint(equalToConstant: 80),
            
            // Profile image - más pequeña
            profileImageView.centerYAnchor.constraint(equalTo: profileBannerView.centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: profileBannerView.leadingAnchor, constant: 12),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // Camera button - más pequeño
            cameraButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            cameraButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            cameraButton.widthAnchor.constraint(equalToConstant: 24),
            cameraButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Edit profile button - a la derecha
            editProfileButton.centerYAnchor.constraint(equalTo: profileBannerView.centerYAnchor),
            editProfileButton.trailingAnchor.constraint(equalTo: profileBannerView.trailingAnchor, constant: -12),
            editProfileButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 90),
            
            // User name label
            userNameLabel.topAnchor.constraint(equalTo: profileBannerView.topAnchor, constant: 20),
            userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            userNameLabel.trailingAnchor.constraint(equalTo: editProfileButton.leadingAnchor, constant: -8),
            
            // Change photo label
            changePhotoLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 2),
            changePhotoLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            changePhotoLabel.trailingAnchor.constraint(equalTo: editProfileButton.leadingAnchor, constant: -8),
        ])
        
        // Agregar tap gesture a la imagen de perfil
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
        
        // Agregar acción al botón de cámara
        cameraButton.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)
        
        // Agregar acción al botón de editar perfil
        editProfileButton.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
    }
    
    func setupFavoritosView() {
        // Agregar la vista de favoritos
        view.addSubview(favoritosContainerView)
        favoritosContainerView.addSubview(favoritosTitleLabel)
        favoritosContainerView.addSubview(favoritosStackView)
        
        NSLayoutConstraint.activate([
            // Container de favoritos - debajo del banner de perfil
            favoritosContainerView.topAnchor.constraint(equalTo: profileBannerView.bottomAnchor, constant: 12),
            favoritosContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            favoritosContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Título
            favoritosTitleLabel.topAnchor.constraint(equalTo: favoritosContainerView.topAnchor, constant: 12),
            favoritosTitleLabel.leadingAnchor.constraint(equalTo: favoritosContainerView.leadingAnchor, constant: 12),
            favoritosTitleLabel.trailingAnchor.constraint(equalTo: favoritosContainerView.trailingAnchor, constant: -12),
            
            // Stack view
            favoritosStackView.topAnchor.constraint(equalTo: favoritosTitleLabel.bottomAnchor, constant: 8),
            favoritosStackView.leadingAnchor.constraint(equalTo: favoritosContainerView.leadingAnchor, constant: 12),
            favoritosStackView.trailingAnchor.constraint(equalTo: favoritosContainerView.trailingAnchor, constant: -12),
            favoritosStackView.bottomAnchor.constraint(equalTo: favoritosContainerView.bottomAnchor, constant: -12)
        ])
    }
    
    func cargarFavoritos() {
        // Limpiar stack view
        favoritosStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Obtener favoritos
        let favoritos = CoreDataManager.shared.obtenerFavoritos()
        
        if favoritos.isEmpty {
            favoritosContainerView.isHidden = true
        } else {
            favoritosContainerView.isHidden = false
            
            // Limitar a 5 favoritos mostrados
            let favoritosAMostrar = Array(favoritos.prefix(5))
            
            for favorito in favoritosAMostrar {
                let button = crearBotonFavorito(nombreEstado: favorito.nombreEstado ?? "")
                favoritosStackView.addArrangedSubview(button)
            }
            
            // Si hay más de 5, agregar indicador
            if favoritos.count > 5 {
                let label = UILabel()
                label.text = "y \(favoritos.count - 5) más..."
                label.font = .systemFont(ofSize: 12, weight: .regular)
                label.textColor = .systemGray
                label.textAlignment = .center
                favoritosStackView.addArrangedSubview(label)
            }
        }
    }
    
    func crearBotonFavorito(nombreEstado: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("• \(nombreEstado)", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.contentHorizontalAlignment = .leading
        button.addTarget(self, action: #selector(favoritoTapped), for: .touchUpInside)
        button.accessibilityLabel = nombreEstado
        return button
    }
    
    @objc func favoritoTapped(_ sender: UIButton) {
        guard let nombreEstado = sender.accessibilityLabel else { return }
        
        // Navegar a EstadoDetalleViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detalleVC = storyboard.instantiateViewController(withIdentifier: "EstadoDetalleViewController") as? EstadoDetalleViewController {
            detalleVC.estadoNombre = nombreEstado
            navigationController?.pushViewController(detalleVC, animated: true)
        }
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
            // Subir imagen a Firebase Storage
            subirImagenPerfil(editedImage)
            // Actualizar el texto debajo del perfil
            actualizarTextoDebajoPerfil(tieneImagen: true)
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageView.image = originalImage
            profileImageView.contentMode = .scaleAspectFill
            // Subir imagen a Firebase Storage
            subirImagenPerfil(originalImage)
            // Actualizar el texto debajo del perfil
            actualizarTextoDebajoPerfil(tieneImagen: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // MARK: - Firebase Storage & Firestore
    
    func actualizarTextoDebajoPerfil(tieneImagen: Bool) {
        if tieneImagen {
            // Si tiene imagen, mostrar el email
            if let email = Auth.auth().currentUser?.email {
                changePhotoLabel.text = email
            }
        } else {
            // Si no tiene imagen, mostrar el texto por defecto
            changePhotoLabel.text = "Toca para cambiar foto"
        }
    }
    
    func cargarImagenPerfil() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("usuarios").document(uid).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error al cargar datos del usuario: \(error.localizedDescription)")
                self.actualizarTextoDebajoPerfil(tieneImagen: false)
                return
            }
            
            if let document = document, document.exists,
               let data = document.data(),
               let imagenURL = data["imagenProfile"] as? String,
               !imagenURL.isEmpty,
               let url = URL(string: imagenURL) {
                
                // Descargar imagen desde URL
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        print("Error al descargar imagen: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.actualizarTextoDebajoPerfil(tieneImagen: false)
                        }
                        return
                    }
                    
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.profileImageView.image = image
                            self.profileImageView.contentMode = .scaleAspectFill
                            self.actualizarTextoDebajoPerfil(tieneImagen: true)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.actualizarTextoDebajoPerfil(tieneImagen: false)
                        }
                    }
                }.resume()
            } else {
                DispatchQueue.main.async {
                    self.actualizarTextoDebajoPerfil(tieneImagen: false)
                }
            }
        }
    }
    
    func subirImagenPerfil(_ image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else {
            mostrarAlerta(titulo: "Error", mensaje: "No se pudo obtener el ID del usuario")
            return
        }
        
        // Redimensionar la imagen para que sea más pequeña
        let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 800, height: 800))
        
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.7) else {
            mostrarAlerta(titulo: "Error", mensaje: "No se pudo procesar la imagen")
            return
        }
        
        // Mostrar indicador de carga
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        // Crear referencia en Firebase Storage
        let storageRef = Storage.storage().reference()
        let profileImageRef = storageRef.child("profile_images/\(uid).jpg")
        
        // Metadatos de la imagen
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Subir imagen a Firebase Storage
        profileImageRef.putData(imageData, metadata: metadata) { [weak self] metadata, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    activityIndicator.removeFromSuperview()
                    self.mostrarAlerta(titulo: "Error", mensaje: "No se pudo subir la imagen: \(error.localizedDescription)")
                }
                return
            }
            
            // Obtener URL de descarga
            profileImageRef.downloadURL { url, error in
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    activityIndicator.removeFromSuperview()
                }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.mostrarAlerta(titulo: "Error", mensaje: "No se pudo obtener la URL de la imagen: \(error.localizedDescription)")
                    }
                    return
                }
                
                if let downloadURL = url {
                    // Guardar URL en Firestore
                    self.actualizarImagenEnFirestore(url: downloadURL.absoluteString)
                }
            }
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        let rect = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
    
    func actualizarImagenEnFirestore(url: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("usuarios").document(uid).updateData([
            "imagenProfile": url,
            "fechaActualizacionImagen": FieldValue.serverTimestamp()
        ]) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.mostrarAlerta(titulo: "Advertencia", mensaje: "Imagen subida pero no se actualizó en Firestore: \(error.localizedDescription)")
                }
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "¡Éxito!", message: "Imagen de perfil actualizada correctamente", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc func cerrarSesion() {
        do {
            try Auth.auth().signOut()
            
            // Obtener el storyboard y crear el navigation controller inicial
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let initialNavController = storyboard.instantiateInitialViewController() as? UINavigationController {
                // Reemplazar la ventana completa
                if let window = view.window {
                    window.rootViewController = initialNavController
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
                }
            }
        } catch let error {
            mostrarAlerta(titulo: "Error", mensaje: "No se pudo cerrar sesión: \(error.localizedDescription)")
        }
    }
    
    @objc func editProfileTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editarPerfilVC = storyboard.instantiateViewController(withIdentifier: "EditarPerfilViewController") as? EditarPerfilViewController {
            navigationController?.pushViewController(editarPerfilVC, animated: true)
        }
    }
    
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @IBAction func btnAprender(_ sender: UIButton) {
        // Mostrar opciones de aprendizaje
        let alert = UIAlertController(title: "¿Cómo quieres aprender?", message: "Elige una opción", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "🗺️ Explorar Mapa Interactivo", style: .default) { [weak self] _ in
            let vc = MapaViewController()
            if let navigationController = self?.navigationController {
                navigationController.pushViewController(vc, animated: true)
            } else {
                self?.present(vc, animated: true)
            }
        })
        
        alert.addAction(UIAlertAction(title: "🎮 Jugar Memorama", style: .default) { [weak self] _ in
            let vc = MemoramaViewController()
            if let navigationController = self?.navigationController {
                navigationController.pushViewController(vc, animated: true)
            } else {
                self?.present(vc, animated: true)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        // Para iPad
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(alert, animated: true)
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

