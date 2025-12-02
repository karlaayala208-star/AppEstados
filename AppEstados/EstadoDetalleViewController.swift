//
//  EstadoDetalleViewController.swift
//  AppEstados
//
//  Created by Karla Ayala on 23/06/25.
//

import UIKit
import MediaPlayer

class EstadoDetalleViewController: UIViewController {

    
    @IBOutlet weak var vervideo: UIButton!
    @IBOutlet weak var escuchar: UIButton!
    @IBOutlet weak var verimagen: UIImageView!
    @IBOutlet weak var nombreComidaLabel: UILabel!

    
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
        "Tabasco": "Puchero Tabasqueño"
        
        
    ]



    override func viewDidLoad() {
            super.viewDidLoad()
            mostrarNombreYComida()
            
            // Cargar imagen según el estado
            if let nombre = estadoNombre {
                let nombreImagen = nombreImagenParaEstado(nombre)
                verimagen.image = UIImage(named: nombreImagen) ?? UIImage(named: "comidadesconocida") // Imagen por defecto si no encuentra
            } else {
                verimagen.image = UIImage(named: "comidadesconocida")
            }
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
    func reproducirAudio() {
        guard let path = Bundle.main.path(forResource: "Audio" + (estadoNombre ?? ""), ofType: "mp3") else {
            print("Audio no encontrado")
            return
        }

        let url = URL(fileURLWithPath: path)

        do {
            reproductor = try AVAudioPlayer(contentsOf: url)
            reproductor?.prepareToPlay()
            reproductor?.play()
        } catch {
            print("Error al reproducir el audio: \(error.localizedDescription)")
        }
    }


}
