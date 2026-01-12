//
//  MemoramaViewController.swift
//  AppEstados
//
//  Created by Assistant on 12/01/26.
//

import UIKit

class MemoramaViewController: UIViewController {
    
    // MARK: - Estructuras de datos
    
    struct CartaMemorama {
        let id: Int
        let tipo: TipoCarta
        let valor: String
        let estado: String
        var estaVolteada: Bool = false
        var estaEmparejada: Bool = false
    }
    
    enum TipoCarta {
        case estado
        case caracteristica
    }
    
    enum ModoJuego: String {
        case comida = "Comida Típica"
        case capital = "Capital"
        case lugarTuristico = "Lugar Turístico"
    }
    
    // MARK: - Propiedades
    
    private var cartas: [CartaMemorama] = []
    private var cartasVolteadas: [IndexPath] = []
    private var modoActual: ModoJuego = .comida
    private var paresEncontrados = 0
    private var intentos = 0
    private var tiempoInicio: Date?
    private var timer: Timer?
    private var segundosTranscurridos = 0
    
    // MARK: - UI Components
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let modoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .systemOrange
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let paresLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let intentosLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tiempoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cambiarModoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cambiar Modo", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let reiniciarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reiniciar", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Datos
    
    let estadosCapitales: [String: String] = [
        "Aguascalientes": "Aguascalientes",
        "Baja California": "Mexicali",
        "Baja California Sur": "La Paz",
        "Campeche": "San Francisco de Campeche",
        "Chiapas": "Tuxtla Gutiérrez",
        "Chihuahua": "Chihuahua",
        "Ciudad de México": "Ciudad de México",
        "Coahuila": "Saltillo",
        "Colima": "Colima",
        "Durango": "Victoria de Durango",
        "Guanajuato": "Guanajuato",
        "Guerrero": "Chilpancingo",
        "Hidalgo": "Pachuca",
        "Jalisco": "Guadalajara",
        "México": "Toluca",
        "Michoacán": "Morelia",
        "Morelos": "Cuernavaca",
        "Nayarit": "Tepic",
        "Nuevo León": "Monterrey",
        "Oaxaca": "Oaxaca de Juárez",
        "Puebla": "Puebla de Zaragoza",
        "Querétaro": "Santiago de Querétaro",
        "Quintana Roo": "Chetumal",
        "San Luis Potosí": "San Luis Potosí",
        "Sinaloa": "Culiacán",
        "Sonora": "Hermosillo",
        "Tabasco": "Villahermosa",
        "Tamaulipas": "Ciudad Victoria",
        "Tlaxcala": "Tlaxcala",
        "Veracruz": "Xalapa",
        "Yucatán": "Mérida",
        "Zacatecas": "Zacatecas"
    ]
    
    let estadosComida: [String: String] = [
        "Aguascalientes": "Enchiladas Aguascalentenses",
        "Baja California": "Tacos de Pescado",
        "Baja California Sur": "Ceviche de camarón",
        "Campeche": "Pan de cazón",
        "Chiapas": "Tamales de chipilín",
        "Chihuahua": "Machaca con huevo",
        "Ciudad de México": "Tacos al pastor",
        "Coahuila": "Discada",
        "Colima": "Sopitos",
        "Durango": "Caldillo durangueño",
        "Guanajuato": "Enchiladas Mineras",
        "Guerrero": "Pozole verde",
        "Hidalgo": "Pastes",
        "Jalisco": "Tortas ahogadas",
        "México": "Barbacoa de borrego",
        "Michoacán": "Carnitas",
        "Morelos": "Cecina de Yecapixtla",
        "Nayarit": "Pescado Zarandeado",
        "Nuevo León": "Cabrito asado",
        "Oaxaca": "Mole negro oaxaqueño",
        "Puebla": "Chiles en nogada",
        "Querétaro": "Nopal en Penca",
        "Quintana Roo": "Tikin Xic",
        "San Luis Potosí": "Enchiladas potosinas",
        "Sinaloa": "Aguachile",
        "Sonora": "Carne asada",
        "Tabasco": "Puchero Tabasqueño",
        "Tamaulipas": "Jaibas rellenas",
        "Tlaxcala": "Tacos de canasta",
        "Veracruz": "Huachinango a la veracruzana",
        "Yucatán": "Cochinita pibil",
        "Zacatecas": "Birria de chivo"
    ]
    
    let estadosLugarTuristico: [String: String] = [
        "Aguascalientes": "Feria de San Marcos",
        "Baja California": "La Bufadora",
        "Baja California Sur": "El Arco de Cabo",
        "Campeche": "Ciudad Amurallada",
        "Chiapas": "Cañón del Sumidero",
        "Chihuahua": "Barrancas del Cobre",
        "Ciudad de México": "Zócalo",
        "Coahuila": "Cuatro Ciénegas",
        "Colima": "Volcán de Colima",
        "Durango": "Zona del Silencio",
        "Guanajuato": "Callejón del Beso",
        "Guerrero": "Acapulco",
        "Hidalgo": "Prismas Basálticos",
        "Jalisco": "Tequila",
        "México": "Teotihuacán",
        "Michoacán": "Mariposa Monarca",
        "Morelos": "Tepoztlán",
        "Nayarit": "Islas Marietas",
        "Nuevo León": "Grutas de García",
        "Oaxaca": "Monte Albán",
        "Puebla": "Capilla del Rosario",
        "Querétaro": "Peña de Bernal",
        "Quintana Roo": "Chichén Itzá",
        "San Luis Potosí": "Sótano de las Golondrinas",
        "Sinaloa": "Mazatlán",
        "Sonora": "San Carlos",
        "Tabasco": "La Venta",
        "Tamaulipas": "Tampico",
        "Tlaxcala": "Cacaxtla",
        "Veracruz": "Tajín",
        "Yucatán": "Uxmal",
        "Zacatecas": "Cerro de la Bufa"
    ]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Memorama de Estados"
        view.backgroundColor = .systemGroupedBackground
        
        setupUI()
        iniciarJuego()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    // MARK: - Setup
    
    func setupUI() {
        // Agregar subvistas
        view.addSubview(headerView)
        headerView.addSubview(modoLabel)
        headerView.addSubview(statsStackView)
        headerView.addSubview(cambiarModoButton)
        headerView.addSubview(reiniciarButton)
        
        statsStackView.addArrangedSubview(paresLabel)
        statsStackView.addArrangedSubview(intentosLabel)
        statsStackView.addArrangedSubview(tiempoLabel)
        
        view.addSubview(collectionView)
        
        // Collection view setup
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CartaMemoramaCell.self, forCellWithReuseIdentifier: "CartaCell")
        
        // Botones
        cambiarModoButton.addTarget(self, action: #selector(cambiarModoTapped), for: .touchUpInside)
        reiniciarButton.addTarget(self, action: #selector(reiniciarTapped), for: .touchUpInside)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Modo label
            modoLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            modoLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12),
            modoLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -12),
            
            // Stats
            statsStackView.topAnchor.constraint(equalTo: modoLabel.bottomAnchor, constant: 8),
            statsStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12),
            statsStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -12),
            
            // Botones
            cambiarModoButton.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 12),
            cambiarModoButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12),
            cambiarModoButton.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.45),
            cambiarModoButton.heightAnchor.constraint(equalToConstant: 36),
            cambiarModoButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12),
            
            reiniciarButton.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 12),
            reiniciarButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -12),
            reiniciarButton.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.45),
            reiniciarButton.heightAnchor.constraint(equalToConstant: 36),
            
            // Collection view
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Game Logic
    
    func iniciarJuego() {
        cartas.removeAll()
        cartasVolteadas.removeAll()
        paresEncontrados = 0
        intentos = 0
        segundosTranscurridos = 0
        tiempoInicio = Date()
        
        // Iniciar timer
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.actualizarTiempo()
        }
        
        generarCartas()
        actualizarUI()
        collectionView.reloadData()
    }
    
    func generarCartas() {
        let diccionario: [String: String]
        
        switch modoActual {
        case .comida:
            diccionario = estadosComida
        case .capital:
            diccionario = estadosCapitales
        case .lugarTuristico:
            diccionario = estadosLugarTuristico
        }
        
        // Seleccionar 6 estados aleatorios
        let estadosSeleccionados = Array(diccionario.keys.shuffled().prefix(6))
        
        var tempCartas: [CartaMemorama] = []
        var id = 0
        
        for estado in estadosSeleccionados {
            // Carta del estado
            tempCartas.append(CartaMemorama(
                id: id,
                tipo: .estado,
                valor: estado,
                estado: estado
            ))
            id += 1
            
            // Carta de la característica
            if let caracteristica = diccionario[estado] {
                tempCartas.append(CartaMemorama(
                    id: id,
                    tipo: .caracteristica,
                    valor: caracteristica,
                    estado: estado
                ))
                id += 1
            }
        }
        
        // Mezclar cartas
        cartas = tempCartas.shuffled()
    }
    
    func voltearCarta(at indexPath: IndexPath) {
        guard cartasVolteadas.count < 2,
              !cartas[indexPath.row].estaVolteada,
              !cartas[indexPath.row].estaEmparejada else {
            return
        }
        
        cartas[indexPath.row].estaVolteada = true
        cartasVolteadas.append(indexPath)
        collectionView.reloadItems(at: [indexPath])
        
        if cartasVolteadas.count == 2 {
            verificarPareja()
        }
    }
    
    func verificarPareja() {
        guard cartasVolteadas.count == 2 else { return }
        
        intentos += 1
        
        let index1 = cartasVolteadas[0].row
        let index2 = cartasVolteadas[1].row
        
        let carta1 = cartas[index1]
        let carta2 = cartas[index2]
        
        if carta1.estado == carta2.estado && carta1.tipo != carta2.tipo {
            // ¡Pareja encontrada!
            paresEncontrados += 1
            cartas[index1].estaEmparejada = true
            cartas[index2].estaEmparejada = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.collectionView.reloadItems(at: self.cartasVolteadas)
                self.cartasVolteadas.removeAll()
                self.actualizarUI()
                
                // Verificar si ganó
                if self.paresEncontrados == 6 {
                    self.mostrarVictoria()
                }
            }
        } else {
            // No es pareja, voltear de nuevo
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.cartas[index1].estaVolteada = false
                self.cartas[index2].estaVolteada = false
                self.collectionView.reloadItems(at: self.cartasVolteadas)
                self.cartasVolteadas.removeAll()
            }
        }
        
        actualizarUI()
    }
    
    func actualizarUI() {
        modoLabel.text = "🎮 Modo: \(modoActual.rawValue)"
        paresLabel.text = "✅ Pares: \(paresEncontrados)/6"
        intentosLabel.text = "🔄 Intentos: \(intentos)"
        tiempoLabel.text = "⏱️ \(formatearTiempo(segundosTranscurridos))"
    }
    
    func actualizarTiempo() {
        if let inicio = tiempoInicio {
            segundosTranscurridos = Int(Date().timeIntervalSince(inicio))
            actualizarUI()
        }
    }
    
    func formatearTiempo(_ segundos: Int) -> String {
        let minutos = segundos / 60
        let segs = segundos % 60
        return String(format: "%02d:%02d", minutos, segs)
    }
    
    func mostrarVictoria() {
        timer?.invalidate()
        
        let alert = UIAlertController(
            title: "🎉 ¡Felicidades!",
            message: "Completaste el memorama en \(intentos) intentos y \(formatearTiempo(segundosTranscurridos))",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Jugar de nuevo", style: .default) { [weak self] _ in
            self?.reiniciarTapped()
        })
        
        alert.addAction(UIAlertAction(title: "Cambiar modo", style: .default) { [weak self] _ in
            self?.cambiarModoTapped()
        })
        
        present(alert, animated: true)
    }
    
    @objc func cambiarModoTapped() {
        let alert = UIAlertController(title: "Selecciona el modo", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "🍽️ Comida Típica", style: .default) { [weak self] _ in
            self?.modoActual = .comida
            self?.iniciarJuego()
        })
        
        alert.addAction(UIAlertAction(title: "🏛️ Capital", style: .default) { [weak self] _ in
            self?.modoActual = .capital
            self?.iniciarJuego()
        })
        
        alert.addAction(UIAlertAction(title: "📍 Lugar Turístico", style: .default) { [weak self] _ in
            self?.modoActual = .lugarTuristico
            self?.iniciarJuego()
        })
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = cambiarModoButton
            popover.sourceRect = cambiarModoButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    @objc func reiniciarTapped() {
        iniciarJuego()
    }
}

// MARK: - UICollectionViewDelegate & DataSource

extension MemoramaViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cartas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CartaCell", for: indexPath) as! CartaMemoramaCell
        let carta = cartas[indexPath.row]
        cell.configurar(con: carta)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        voltearCarta(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 24) / 3 // 3 columnas
        return CGSize(width: width, height: width * 1.2)
    }
}

// MARK: - Celda personalizada

class CartaMemoramaCell: UICollectionViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconLabel)
        containerView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            iconLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            iconLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            textLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 4),
            textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            textLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            textLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    func configurar(con carta: MemoramaViewController.CartaMemorama) {
        if carta.estaEmparejada {
            // Carta emparejada
            containerView.backgroundColor = .systemGreen
            textLabel.text = carta.valor
            iconLabel.text = "✅"
            textLabel.isHidden = false
            iconLabel.isHidden = false
        } else if carta.estaVolteada {
            // Carta volteada
            if carta.tipo == .estado {
                containerView.backgroundColor = .systemOrange
                iconLabel.text = "📍"
            } else {
                containerView.backgroundColor = .systemBlue
                iconLabel.text = getIcono(para: carta)
            }
            textLabel.text = carta.valor
            textLabel.isHidden = false
            iconLabel.isHidden = false
        } else {
            // Carta boca abajo
            containerView.backgroundColor = .systemGray
            textLabel.text = ""
            iconLabel.text = "❓"
            textLabel.isHidden = true
            iconLabel.isHidden = false
        }
    }
    
    private func getIcono(para carta: MemoramaViewController.CartaMemorama) -> String {
        // Determinar el icono basándose en el contexto
        if carta.valor.contains("Enchiladas") || carta.valor.contains("Tacos") || 
           carta.valor.contains("Mole") || carta.valor.contains("Pozole") ||
           carta.valor.contains("Carnitas") || carta.valor.contains("Barbacoa") {
            return "🍽️"
        } else if carta.valor.contains("Chichén") || carta.valor.contains("Zócalo") ||
                  carta.valor.contains("Monte") || carta.valor.contains("Pirámides") {
            return "🏛️"
        } else if carta.valor == carta.estado {
            // Es una capital (mismo nombre que el estado)
            return "🏛️"
        }
        return "📍"
    }
}
