//
//  TutorialViewController.swift
//  AppEstados
//
//  Created by Jose David on 09/12/25.
//

import UIKit
import AVKit
import AVFoundation
import FirebaseAuth
import FirebaseStorage

class TutorialViewController: UIViewController {
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var isDownloading = false
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let downloadLabel: UILabel = {
        let label = UILabel()
        label.text = "Cargando video..."
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "¡Bienvenido!"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Te mostramos cómo usar la aplicación"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Omitir", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continuar", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // Ocultar botón de regreso
        navigationItem.hidesBackButton = true
        
        // Deshabilitar el gesto de swipe para regresar
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        setupUI()
        setupVideo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
    }
    
    func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(videoContainerView)
        view.addSubview(skipButton)
        view.addSubview(continueButton)
        
        // Agregar indicador de carga al contenedor del video
        videoContainerView.addSubview(activityIndicator)
        videoContainerView.addSubview(downloadLabel)
        
        NSLayoutConstraint.activate([
            // Title label
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Subtitle label
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Skip button
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Video container
            videoContainerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            videoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            videoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            videoContainerView.heightAnchor.constraint(equalTo: videoContainerView.widthAnchor, multiplier: 16.0/9.0),
            
            // Activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: videoContainerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: videoContainerView.centerYAnchor),
            
            // Download label
            downloadLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16),
            downloadLabel.centerXAnchor.constraint(equalTo: videoContainerView.centerXAnchor),
            
            // Continue button
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
    }
    
    func setupVideo() {
        // Mostrar indicador de carga
        activityIndicator.startAnimating()
        downloadLabel.isHidden = false
        isDownloading = true
        
        // Primero intentar cargar el video desde el cache local
        if let cachedVideoURL = getCachedVideoURL() {
            playVideo(from: cachedVideoURL)
            return
        }
        
        // Si no existe en cache, descargar desde Firebase Storage
        downloadVideoFromFirebase()
    }
    
    func getCachedVideoURL() -> URL? {
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let videoURL = documentsPath.appendingPathComponent("tutorial.mp4")
        
        if fileManager.fileExists(atPath: videoURL.path) {
            print("Video encontrado en cache")
            return videoURL
        }
        
        return nil
    }
    
    func downloadVideoFromFirebase() {
        let storageRef = Storage.storage().reference()
        let videoRef = storageRef.child("tutorial/tutorial.mp4")
        
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            showError("No se pudo acceder al almacenamiento local")
            return
        }
        
        let localURL = documentsPath.appendingPathComponent("tutorial.mp4")
        
        // Descargar el archivo
        let downloadTask = videoRef.write(toFile: localURL) { [weak self] url, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.downloadLabel.isHidden = true
                self.isDownloading = false
                
                if let error = error {
                    print("Error al descargar video: \(error.localizedDescription)")
                    self.showError("No se pudo cargar el video. Por favor intenta de nuevo.")
                    return
                }
                
                if let url = url {
                    print("Video descargado exitosamente")
                    self.playVideo(from: url)
                }
            }
        }
        
        // Opcional: Observar el progreso de descarga
        downloadTask.observe(.progress) { [weak self] snapshot in
            guard let progress = snapshot.progress else { return }
            let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            
            DispatchQueue.main.async {
                self?.downloadLabel.text = String(format: "Descargando... %.0f%%", percentComplete)
            }
        }
    }
    
    func playVideo(from url: URL) {
        player = AVPlayer(url: url)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        playerLayer?.frame = videoContainerView.bounds
        
        if let playerLayer = playerLayer {
            videoContainerView.layer.addSublayer(playerLayer)
        }
        
        // Reproducir automáticamente
        player?.play()
        
        // Notificación cuando el video termina
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continuar sin video", style: .default) { [weak self] _ in
            self?.finalizarTutorial()
        })
        present(alert, animated: true)
    }
    
    @objc func videoDidEnd() {
        // Reiniciar el video para que se pueda ver de nuevo
        player?.seek(to: .zero)
        player?.play()
    }
    
    @objc func skipTapped() {
        finalizarTutorial()
    }
    
    @objc func continueTapped() {
        finalizarTutorial()
    }
    
    func finalizarTutorial() {
        // Marcar que este usuario ya vio el tutorial
        if let uid = Auth.auth().currentUser?.uid {
            let hasSeenTutorialKey = "hasSeenTutorial_\(uid)"
            UserDefaults.standard.set(true, forKey: hasSeenTutorialKey)
        }
        
        // Navegar al ViewController principal
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            mainVC.nombreUsuario = Auth.auth().currentUser?.displayName
            navigationController?.setViewControllers([mainVC], animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        player?.pause()
        player = nil
    }
}
