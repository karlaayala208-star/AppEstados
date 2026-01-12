//
//  EstadoDetalleViewController.swift
//  AppEstados
//
//  Created by Karla Ayala on 23/06/25.
//

import UIKit
import AVFoundation

class EstadoDetalleViewController: UIViewController {

    @IBOutlet weak var vervideo: UIButton!
    @IBOutlet weak var escuchar: UIButton!
    @IBOutlet weak var verimagen: UIImageView!
    @IBOutlet weak var nombreComidaLabel: UILabel!
    
    // Label del storyboard que vamos a ocultar
    private var labelComidaTipicaStoryboard: UILabel?

    // Container para la comida típica
    private let comidaContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let comidaTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "🍽️ La comida típica es:"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .systemOrange
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // ScrollView para mejor organización
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = true
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // Labels para lugares turísticos
    private let lugarTuristicoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let lugarTuristicoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "📍 Lugar turístico"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let lugarTuristicoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var reproductor: AVAudioPlayer?
    var estadoNombre: String?
    
    let enlacesPorEstado: [String: String] = [
        "Aguascalientes": "https://youtu.be/1YEApj1pmGk?si=frkjJqlO793Lz4eH",
        "Baja California": "https://youtu.be/ylMCRBl-dx8",
        "Baja California Sur": "https://youtu.be/LIoR41lKcjU?si=UbXPhkpATurhpmvN",
        "Campeche": "https://youtu.be/_rsF-pgqf4c?si=b4OCOT-QV9HufeUT",
        "Coahuila": "https://youtu.be/doaKx-VPaJI?si=asqjbCXZtNtJjQBd",
        "Colima": "https://youtu.be/-77zp0Qcoz4?si=jbB7oBgLehCjAp5n",
        "Chiapas": "https://youtu.be/2CO_RWLVAwQ",
        "Chihuahua": "https://youtu.be/9ferQVAV0DE?si=h-wtMTfkhwXdCNmb",
        "Ciudad de México": "https://youtu.be/k-fNZv8XHxw?si=yQNRzeeO7y2rfTtN",
        "Durango": "https://youtu.be/uZnaXoJKIDc?feature=shared",
        "Guanajuato": "https://youtu.be/Q86r3bHyV4E?si=6smV5lI4nxFLDecI",
        "Guerrero": "https://youtu.be/EjfKzSyKVdY?si=8jxMkVW3LbWSh6ww",
        "Hidalgo": "https://youtu.be/hgxWd1JHcbA?si=lidMZBe635aRfq0R",
        "Jalisco": "https://youtu.be/vdS9u35gG0w", // video sobre Jalisco :contentReference[oaicite:1]{index=1}
        "México": "https://youtu.be/gmNczJQLJoc?si=QvOlRj1AeIUnfi1K",
        "Michoacán": "https://youtu.be/PxJVcSDQxnw?si=nfGssHXr1-z3Lb4u",
        "Morelos": "https://youtu.be/w65K9pTrX9o?si=vkddBjzYxWUsi-mQ",
        "Nayarit": "https://youtu.be/zjsTKTa0e-A?si=7NZDJGBQaaFKwlIc",
        "Nuevo León": "https://youtu.be/GBdnes873e0?si=IAiI8euTJ5KmW7VA",
        "Oaxaca": "https://youtu.be/d0lTcs4PfcA?feature=shared", // things to do in Oaxaca :contentReference[oaicite:2]{index=2}
        "Puebla": "https://youtu.be/u97QlrsFoIU?si=B2tfAye7MvJupNUO",
        "Querétaro": "https://youtu.be/ewwiCBh6r6g?si=xzswEHHhi9vm5R5Q",
        "Quintana Roo": "https://youtu.be/m8C8bI7ySco?feature=shared",
        "San Luis Potosí": "https://youtu.be/Yn20gDyGvH8?si=0pUMG1QDLSE8amQ2",
        "Sinaloa": "https://youtu.be/87n-IygVQwk?si=g--I2DRHgSHY1jGr",
        "Sonora": "https://youtu.be/sMUtazM__4A?si=Ymz_yWsM4x1ztdPD",
        "Tabasco": "https://youtu.be/enhuEOl8Joc?si=RwRSZZe8EM6WkG1b",
        "Tamaulipas": "https://youtu.be/mu3d8CFvtx8?si=MSu36Yq8xdyUxGaP",
        "Tlaxcala": "https://youtu.be/WT7KZU22UZY?si=j8FP2s5MwNDjXpdX",
        "Veracruz": "https://youtu.be/Iv2MarBcLAo?si=dnzhy3kbPTxPlI82",
        "Yucatán": "https://youtu.be/vdterYYtIoM?si=BQQ6lHngiwFrI9V5",
        "Zacatecas": "https://youtu.be/EywjljZHLBY?si=LPr5sS8prWFf-fTG"
    ]
    
    let comidaPorEstado: [String: String] = [
        "Aguascalientes": "Enchiladas Aguascalentenses",
        "Bajacalifornia": "Tacos de Pescado/camaron",
        "Bajacaliforniasur": "Almejas chocolatadas tatemadas",
        "Campeche": "Pan de cazon",
        "Chiapas": "Tamales de chipilín",
        "Oaxaca": "Mole negro oaxaqueño",
        "Jalisco": "Tortas ahogadas",
        "Ciudad de México": "Tacos al pastor",
        "Yucatán": "Cochinita pibil",
        "Puebla": "Chiles en nogada",
        "Veracruz": "Huachinango a la veracruzana",
        "Sonora": "Carne asada",
        "Nuevo León": "Cabrito asado",
        "Michoacán": "Carnitas",
        "Chihuahua": "Machaca con huevo",
        "Coahuila": "Discada",
        "Colima": "Sopitos",
        "Durango": "Caldillo durangueño",
        "México": "Barbacoa de borrego",
        "Guanajuato": "Enchiladas Mineras",
        "Guerrero": "Pozole verde",
        "Hidalgo": "Pastes",
        "Morelos": "Cecina de Yecapixtla",
        "Nayarit": "Pescado Zarandeado",
        "Querétaro": "Nopal en Penca",
        "Quintana Roo": "Tikin Xic",
        "San Luis Potosí": "Enchiladas potosinas",
        "Sinaloa": "Aguachile",
        "Tamaulipas": "Jaibas rellenas",
        "Tlaxcala": "Tacos de canasta",
        "Zacatecas": "Birria de chivo",
        "Tabasco": "Puchero Tabasqueño",
        "Baja California": "Pescado zarandeado",
        "Baja California Sur": "Ceviche de camarón"
    ]
    
    let lugarTuristicoPorEstado: [String: String] = [
        "Aguascalientes": "Feria Nacional de San Marcos - La feria más importante de México",
        "Baja California": "La Bufadora - Géiser marino natural y playas de Ensenada",
        "Baja California Sur": "El Arco de Cabo San Lucas - Formación rocosa icónica",
        "Campeche": "Ciudad amurallada de Campeche - Patrimonio de la Humanidad",
        "Chiapas": "Cañón del Sumidero - Impresionante formación natural",
        "Chihuahua": "Barrancas del Cobre - Sistema de cañones más grande que el Gran Cañón",
        "Ciudad de México": "Centro Histórico - Zócalo, Catedral Metropolitana y Templo Mayor",
        "Coahuila": "Cuatro Ciénegas - Reserva de la biosfera única",
        "Colima": "Volcán de Colima - Uno de los volcanes más activos de México",
        "Durango": "Zona del Silencio - Área con fenómenos magnéticos únicos",
        "Guanajuato": "Callejón del Beso - Leyenda romántica y arquitectura colonial",
        "Guerrero": "Acapulco - Playas y los famosos clavadistas de La Quebrada",
        "Hidalgo": "Prismas Basálticos - Formaciones de columnas de basalto",
        "Jalisco": "Tequila - Pueblo Mágico y paisaje agavero, Patrimonio de la Humanidad",
        "México": "Teotihuacán - Zona arqueológica con las pirámides del Sol y la Luna",
        "Michoacán": "Santuario de la Mariposa Monarca - Reserva de la Biosfera",
        "Morelos": "Tepoztlán - Pueblo Mágico y zona arqueológica",
        "Nayarit": "Islas Marietas - Reserva natural con la Playa del Amor",
        "Nuevo León": "Grutas de García - Sistema de cuevas impresionantes",
        "Oaxaca": "Monte Albán - Zona arqueológica zapoteca, Patrimonio de la Humanidad",
        "Puebla": "Puebla Capital - Centro histórico y la Capilla del Rosario",
        "Querétaro": "Peña de Bernal - Tercer monolito más grande del mundo",
        "Quintana Roo": "Chichén Itzá - Una de las nuevas siete maravillas del mundo",
        "San Luis Potosí": "Sótano de las Golondrinas - Abismo natural impresionante",
        "Sinaloa": "Mazatlán - Malecón y playas del Pacífico",
        "Sonora": "San Carlos - Playas y deportes acuáticos",
        "Tabasco": "Parque Museo La Venta - Sitio arqueológico olmeca",
        "Tamaulipas": "Tampico - Playas y laguna del Chairel",
        "Tlaxcala": "Cacaxtla - Zona arqueológica con murales prehispánicos",
        "Veracruz": "Tajín - Zona arqueológica con la Pirámide de los Nichos",
        "Yucatán": "Chichén Itzá y Uxmal - Ciudades mayas antiguas",
        "Zacatecas": "Cerro de la Bufa - Mirador y teleférico"
    ]

    override func viewDidLoad() {
            super.viewDidLoad()
            
            // Configurar navegación
            title = estadoNombre ?? "Detalle del Estado"
            navigationItem.largeTitleDisplayMode = .never
            
            // Asegurar que el navigation bar sea visible
            navigationController?.setNavigationBarHidden(false, animated: false)
            
            // Configurar el fondo
            view.backgroundColor = .systemGroupedBackground
            
            setupScrollView()
            setupComidaContainer()
            configurarEstiloVistas()  // Mover ANTES de setupLugarTuristicoViews
            setupLugarTuristicoViews()  // Ahora los botones ya están en contentView
            
            // Cargar imagen según el estado
            if let nombre = estadoNombre {
                let nombreImagen = nombreImagenParaEstado(nombre)
                verimagen.image = UIImage(named: nombreImagen) ?? UIImage(named: "comidadesconocida")
            } else {
                verimagen.image = UIImage(named: "comidadesconocida")
            }
            
            mostrarNombreYComida()
            mostrarLugarTuristico()
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            // Actualizar el contentSize del scroll después de que el layout se haya calculado
            DispatchQueue.main.async {
                print("📐 ContentView height: \(self.contentView.frame.height)")
                print("📐 ScrollView contentSize: \(self.scrollView.contentSize)")
                print("📐 Lugar Turístico Container frame: \(self.lugarTuristicoContainerView.frame)")
            }
        }
        
        func setupComidaContainer() {
            // Ocultar el label "La comida tipica es:" del storyboard
            if let labelStoryboard = view.subviews.first(where: { ($0 as? UILabel)?.text == "La comida tipica es:" }) as? UILabel {
                labelStoryboard.isHidden = true
            }
            
            // Agregar el container de comida al contentView
            contentView.addSubview(comidaContainerView)
            comidaContainerView.addSubview(comidaTitleLabel)
            
            // Mover el label de nombre de comida al container
            nombreComidaLabel.removeFromSuperview()
            comidaContainerView.addSubview(nombreComidaLabel)
            
            // Actualizar el estilo del label de nombre de comida
            nombreComidaLabel.font = .systemFont(ofSize: 18, weight: .semibold)
            nombreComidaLabel.textColor = .label
            nombreComidaLabel.numberOfLines = 0
            nombreComidaLabel.translatesAutoresizingMaskIntoConstraints = false
            
            // Mover la imagen después del container
            verimagen.removeFromSuperview()
            contentView.addSubview(verimagen)
            verimagen.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                // Container de comida - PRIMERO
                comidaContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
                comidaContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                comidaContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                
                // Título de comida
                comidaTitleLabel.topAnchor.constraint(equalTo: comidaContainerView.topAnchor, constant: 16),
                comidaTitleLabel.leadingAnchor.constraint(equalTo: comidaContainerView.leadingAnchor, constant: 16),
                comidaTitleLabel.trailingAnchor.constraint(equalTo: comidaContainerView.trailingAnchor, constant: -16),
                
                // Nombre de la comida
                nombreComidaLabel.topAnchor.constraint(equalTo: comidaTitleLabel.bottomAnchor, constant: 8),
                nombreComidaLabel.leadingAnchor.constraint(equalTo: comidaContainerView.leadingAnchor, constant: 16),
                nombreComidaLabel.trailingAnchor.constraint(equalTo: comidaContainerView.trailingAnchor, constant: -16),
                nombreComidaLabel.bottomAnchor.constraint(equalTo: comidaContainerView.bottomAnchor, constant: -16),
                
                // Imagen - SEGUNDO, debajo del container de comida
                verimagen.topAnchor.constraint(equalTo: comidaContainerView.bottomAnchor, constant: 20),
                verimagen.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                verimagen.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                verimagen.heightAnchor.constraint(equalToConstant: 250)
            ])
        }
        
        func setupScrollView() {
            // Configurar el ScrollView
            view.addSubview(scrollView)
            scrollView.addSubview(contentView)
            
            NSLayoutConstraint.activate([
                // ScrollView llena toda la vista
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                // ContentView dentro del ScrollView
                contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            ])
        }
        
        func configurarEstiloVistas() {
            // Estilo de la imagen
            verimagen.layer.cornerRadius = 16
            verimagen.clipsToBounds = true
            verimagen.layer.borderWidth = 3
            verimagen.layer.borderColor = UIColor.systemGray5.cgColor
            verimagen.contentMode = .scaleAspectFill
            
            // Mover botones después de la imagen programáticamente
            vervideo.removeFromSuperview()
            escuchar.removeFromSuperview()
            contentView.addSubview(vervideo)
            contentView.addSubview(escuchar)
            vervideo.translatesAutoresizingMaskIntoConstraints = false
            escuchar.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                // Botón de video - debajo de la imagen
                vervideo.topAnchor.constraint(equalTo: verimagen.bottomAnchor, constant: 20),
                vervideo.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
                vervideo.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
                vervideo.heightAnchor.constraint(equalToConstant: 50),
                
                // Botón de audio - debajo del botón de video
                escuchar.topAnchor.constraint(equalTo: vervideo.bottomAnchor, constant: 16),
                escuchar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
                escuchar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
                escuchar.heightAnchor.constraint(equalToConstant: 50)
            ])
            
            // Estilo de los botones
            configurarBoton(vervideo, titulo: "🎥 Ver video con más información", color: .systemOrange)
            configurarBoton(escuchar, titulo: "🔊 Escuchar estado y capital", color: .systemGreen)
        }
        
        func configurarBoton(_ boton: UIButton, titulo: String, color: UIColor) {
            boton.setTitle(titulo, for: .normal)
            boton.backgroundColor = color
            boton.setTitleColor(.white, for: .normal)
            boton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            boton.layer.cornerRadius = 12
            boton.layer.shadowColor = UIColor.black.cgColor
            boton.layer.shadowOpacity = 0.2
            boton.layer.shadowOffset = CGSize(width: 0, height: 2)
            boton.layer.shadowRadius = 4
        }
        
        func setupLugarTuristicoViews() {
            contentView.addSubview(lugarTuristicoContainerView)
            lugarTuristicoContainerView.addSubview(lugarTuristicoTitleLabel)
            lugarTuristicoContainerView.addSubview(lugarTuristicoLabel)
            
            print("🏗️ Configurando vista de lugar turístico")
            
            NSLayoutConstraint.activate([
                // Container del lugar turístico - debajo de los botones
                lugarTuristicoContainerView.topAnchor.constraint(equalTo: escuchar.bottomAnchor, constant: 24),
                lugarTuristicoContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                lugarTuristicoContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                lugarTuristicoContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
                lugarTuristicoContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
                
                // Título de lugar turístico
                lugarTuristicoTitleLabel.topAnchor.constraint(equalTo: lugarTuristicoContainerView.topAnchor, constant: 16),
                lugarTuristicoTitleLabel.leadingAnchor.constraint(equalTo: lugarTuristicoContainerView.leadingAnchor, constant: 16),
                lugarTuristicoTitleLabel.trailingAnchor.constraint(equalTo: lugarTuristicoContainerView.trailingAnchor, constant: -16),
                
                // Descripción del lugar turístico
                lugarTuristicoLabel.topAnchor.constraint(equalTo: lugarTuristicoTitleLabel.bottomAnchor, constant: 12),
                lugarTuristicoLabel.leadingAnchor.constraint(equalTo: lugarTuristicoContainerView.leadingAnchor, constant: 16),
                lugarTuristicoLabel.trailingAnchor.constraint(equalTo: lugarTuristicoContainerView.trailingAnchor, constant: -16),
                lugarTuristicoLabel.bottomAnchor.constraint(equalTo: lugarTuristicoContainerView.bottomAnchor, constant: -16)
            ])
        }
        
        func mostrarLugarTuristico() {
            if let nombre = estadoNombre {
                let lugarInfo = lugarTuristicoPorEstado[nombre] ?? "Información no disponible"
                lugarTuristicoLabel.text = lugarInfo
                print("🗺️ Lugar turístico para \(nombre): \(lugarInfo)")
                print("📏 Frame del container: \(lugarTuristicoContainerView.frame)")
                print("📏 Frame del label: \(lugarTuristicoLabel.frame)")
            } else {
                lugarTuristicoLabel.text = "Información no disponible"
                print("⚠️ No hay estadoNombre configurado")
            }
            
            // Forzar layout
            view.layoutIfNeeded()
        }

        // Método para generar el nombre del asset de imagen
        func nombreImagenParaEstado(_ estado: String) -> String {
            let sinAcentos = estado.folding(options: .diacriticInsensitive, locale: .current)
            let sinEspacios = sinAcentos.replacingOccurrences(of: " ", with: "").lowercased()
            return "comida\(sinEspacios)"
        }

    
    
    @IBAction func vervideo(_ sender: UIButton) {
     
   /* func mostrarAlertaParaAbrirEnlace() {
        let alerta = UIAlertController(
            title: "Aviso",
            message: "Vas a salir de la aplicación para abrir un enlace externo. ¿Deseas continuar?",
            preferredStyle: .alert
        )
        let cancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        let aceptar = UIAlertAction(title: "Abrir", style: .default) { _ in
            if let url = URL(string:"https://youtu.be/k-fNZv8XHxw?si=yQNRzeeO7y2rfTtN"
)
            {
                UIApplication.shared.open(url)
            }
        }
        alerta.addAction(cancelar)
        alerta.addAction(aceptar)
        present(alerta, animated: true, completion: nil)
    }*/
    
    guard let estado = estadoNombre,
              let urlString = enlacesPorEstado[estado],
              let url = URL(string: urlString) else {
            print("No se encontró video para el estado: \(estadoNombre ?? "ninguno")")
            return
        }
        mostrarAlertaParaAbrirEnlace(url: url)
    }

    func mostrarAlertaParaAbrirEnlace(url: URL) {
        let alerta = UIAlertController(
            title: "Aviso",
            message: "Vas a salir de la app para abrir un video. ¿Deseas continuar?",
            preferredStyle: .alert
        )
        alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alerta.addAction(UIAlertAction(title: "Abrir", style: .default) { _ in
            UIApplication.shared.open(url)
        })
        present(alerta, animated: true)
    }
    
    func mostrarNombreYComida() {
        if let nombre = estadoNombre {
            let nombreImagen = nombreImagenParaEstado(nombre)
            verimagen.image = UIImage(named: nombreImagen) ?? UIImage(named: "comidadesconocida")
            nombreComidaLabel.text = comidaPorEstado[nombre] ?? "Comida no disponible"
        } else {
            verimagen.image = UIImage(named: "comidadesconocida")
            nombreComidaLabel.text = "Comida no disponible"
        }
    }



    
    @IBAction func escuchar(_ sender: UIButton) {
        reproducirAudio()
    }
    
    // Método para obtener el nombre correcto del archivo de audio
    func nombreAudioParaEstado(_ estado: String) -> String {
        // Mapeo especial para casos que no siguen el patrón estándar
        let mapaEspecial: [String: String] = [
            "Baja California": "AudioBajaCalifornia",
            "Baja California Sur": "AudioBajaCaliforniaSur",
            "Ciudad de México": "AudioCiudad de México",
            "Nuevo León": "AudioNuevo León",
            "Quintana Roo": "AudioQuintana Roo",
            "San Luis Potosí": "AudioSan Luis Potosí",
            "Michoacán": "AudioMichoacan",
            "Querétaro": "AudioQueretaro",
            "Yucatán": "AudioYucatan"
        ]
        
        if let nombreEspecial = mapaEspecial[estado] {
            return nombreEspecial
        }
        
        // Para los demás estados, simplemente concatenar "Audio" + nombre
        return "Audio" + estado
    }
    
    func reproducirAudio() {
        guard let nombre = estadoNombre else {
            print("No hay estado seleccionado")
            return
        }
        
        let nombreArchivo = nombreAudioParaEstado(nombre)
        
        guard let path = Bundle.main.path(forResource: nombreArchivo, ofType: "mp3") else {
            print("Audio no encontrado para: \(nombre)")
            print("Buscando archivo: \(nombreArchivo).mp3")
            
            // Mostrar alerta al usuario
            let alerta = UIAlertController(
                title: "Audio no disponible",
                message: "Lo sentimos, el audio para \(nombre) no está disponible en este momento.",
                preferredStyle: .alert
            )
            alerta.addAction(UIAlertAction(title: "OK", style: .default))
            present(alerta, animated: true)
            return
        }

        let url = URL(fileURLWithPath: path)

        do {
            reproductor = try AVAudioPlayer(contentsOf: url)
            reproductor?.prepareToPlay()
            reproductor?.play()
            print("Reproduciendo audio: \(nombreArchivo).mp3")
        } catch {
            print("Error al reproducir el audio: \(error.localizedDescription)")
            
            // Mostrar alerta al usuario
            let alerta = UIAlertController(
                title: "Error",
                message: "No se pudo reproducir el audio. Por favor, intenta de nuevo.",
                preferredStyle: .alert
            )
            alerta.addAction(UIAlertAction(title: "OK", style: .default))
            present(alerta, animated: true)
        }
    }


}
