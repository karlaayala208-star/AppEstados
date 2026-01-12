import UIKit
import FirebaseAuth
import FirebaseFirestore

struct Pregunta {
    let texto: String
    let opciones: [String]
    let respuestaCorrecta: String
}

class CuestionarioViewController: UIViewController {

    let preguntas: [Pregunta] = [
        Pregunta(texto: "¿Cuál es la capital de Jalisco?", opciones: ["Guadalajara", "Zapopan", "Puerto Vallarta"], respuestaCorrecta: "Guadalajara"),
        Pregunta(texto: "¿Cuál es la capital de Yucatán?", opciones: ["Mérida", "Cancún", "Campeche"], respuestaCorrecta: "Mérida"),
        Pregunta(texto: "¿Qué estado es famoso por la Cochinita Pibil?", opciones: ["Yucatán", "Veracruz", "Chiapas"], respuestaCorrecta: "Yucatán"),
        Pregunta(texto: "¿Cuál es la capital de Oaxaca?", opciones: ["Oaxaca de Juárez", "Tuxtla Gutiérrez", "San Cristóbal"], respuestaCorrecta: "Oaxaca de Juárez"),
        Pregunta(texto: "¿Qué estado es conocido por la birria?", opciones: ["Jalisco", "Baja California", "Puebla"], respuestaCorrecta: "Jalisco"),
        Pregunta(texto: "¿Cuál es la capital de Sonora?", opciones: ["Hermosillo", "Nogales", "Guaymas"], respuestaCorrecta: "Hermosillo"),
        Pregunta(texto: "¿Cuál es la capital de Veracruz?", opciones: ["Xalapa", "Veracruz", "Coatzacoalcos"], respuestaCorrecta: "Xalapa"),
        Pregunta(texto: "¿Qué estado es famoso por el mole poblano?", opciones: ["Puebla", "Oaxaca", "Tlaxcala"], respuestaCorrecta: "Puebla"),
        Pregunta(texto: "¿Cuál es la capital de Michoacán?", opciones: ["Morelia", "Uruapan", "Lázaro Cárdenas"], respuestaCorrecta: "Morelia"),
        Pregunta(texto: "¿Cuál es la capital de Chiapas?", opciones: ["Tuxtla Gutiérrez", "San Cristóbal", "Palenque"], respuestaCorrecta: "Tuxtla Gutiérrez")
    ]

    var indiceActual = 0
    var puntaje = 0

    let preguntaLabel = UILabel()
    let botonesOpciones: [UIButton] = (0..<3).map { _ in UIButton(type: .system) }
    let siguienteBoton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Cuestionario"
        configurarVista()
        mostrarPregunta()
    }

    func configurarVista() {
        preguntaLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        preguntaLabel.numberOfLines = 0
        preguntaLabel.textAlignment = .center
        preguntaLabel.textColor = .label
        preguntaLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(preguntaLabel)

        for boton in botonesOpciones {
            boton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            boton.backgroundColor = .systemBlue
            boton.setTitleColor(.white, for: .normal)
            boton.layer.cornerRadius = 8
            boton.translatesAutoresizingMaskIntoConstraints = false
            boton.addTarget(self, action: #selector(opcionSeleccionada(_:)), for: .touchUpInside)
            view.addSubview(boton)
        }

        siguienteBoton.setTitle("Siguiente", for: .normal)
        siguienteBoton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        siguienteBoton.translatesAutoresizingMaskIntoConstraints = false
        siguienteBoton.addTarget(self, action: #selector(siguientePregunta), for: .touchUpInside)
        siguienteBoton.isHidden = true
        view.addSubview(siguienteBoton)

        // Constraints
        NSLayoutConstraint.activate([
            preguntaLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            preguntaLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            preguntaLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        for (index, boton) in botonesOpciones.enumerated() {
            NSLayoutConstraint.activate([
                boton.topAnchor.constraint(equalTo: index == 0 ? preguntaLabel.bottomAnchor : botonesOpciones[index - 1].bottomAnchor, constant: 20),
                boton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                boton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
                boton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }

        NSLayoutConstraint.activate([
            siguienteBoton.topAnchor.constraint(equalTo: botonesOpciones.last!.bottomAnchor, constant: 30),
            siguienteBoton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    func mostrarPregunta() {
        guard indiceActual < preguntas.count else {
            mostrarResultado()
            return
        }

        let pregunta = preguntas[indiceActual]
        preguntaLabel.text = pregunta.texto

        for (index, opcion) in pregunta.opciones.enumerated() {
            botonesOpciones[index].setTitle(opcion, for: .normal)
            botonesOpciones[index].isEnabled = true
            botonesOpciones[index].backgroundColor = .systemBlue
        }

        siguienteBoton.isHidden = true
    }

    @objc func opcionSeleccionada(_ sender: UIButton) {
        guard indiceActual < preguntas.count else { return }

        let respuestaUsuario = sender.title(for: .normal)
        let respuestaCorrecta = preguntas[indiceActual].respuestaCorrecta

        if respuestaUsuario == respuestaCorrecta {
            puntaje += 1
            sender.backgroundColor = .systemGreen
        } else {
            sender.backgroundColor = .systemRed
        }

        for boton in botonesOpciones {
            boton.isEnabled = false
        }

        siguienteBoton.isHidden = false
    }

    @objc func siguientePregunta() {
        indiceActual += 1
        mostrarPregunta()
    }

    func mostrarResultado() {
        // Guardar el puntaje en Firestore antes de mostrar el resultado
        guardarPuntajeEnFirestore()
        
        let alerta = UIAlertController(title: "Resultado",
                                       message: "Obtuviste \(puntaje) de \(preguntas.count) respuestas correctas.",
                                       preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Reintentar", style: .default) { _ in
            self.indiceActual = 0
            self.puntaje = 0
            self.mostrarPregunta()
        })
        alerta.addAction(UIAlertAction(title: "Salir", style: .cancel) { _ in
//            self.dismiss(animated: true)
            self.navigationController?.popViewController(animated: true)
        })
        present(alerta, animated: true)
    }
    
    func guardarPuntajeEnFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No hay usuario autenticado")
            return
        }
        
        let db = Firestore.firestore()
        
        // Datos del puntaje
        let puntajeData: [String: Any] = [
            "puntaje": puntaje,
            "totalPreguntas": preguntas.count,
            "porcentaje": Double(puntaje) / Double(preguntas.count) * 100,
            "fecha": FieldValue.serverTimestamp(),
            "uid": uid
        ]
        
        // Guardar en la colección "puntajes"
        db.collection("puntajes").addDocument(data: puntajeData) { error in
            if let error = error {
                print("Error al guardar puntaje: \(error.localizedDescription)")
            } else {
                print("Puntaje guardado exitosamente")
                
                // Actualizar el mejor puntaje del usuario si es necesario
                self.actualizarMejorPuntaje(puntaje: self.puntaje, uid: uid)
            }
        }
    }
    
    func actualizarMejorPuntaje(puntaje: Int, uid: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("usuarios").document(uid)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let mejorPuntajeActual = data?["mejorPuntaje"] as? Int ?? 0
                
                // Solo actualizar si el nuevo puntaje es mejor
                if puntaje > mejorPuntajeActual {
                    userRef.updateData([
                        "mejorPuntaje": puntaje,
                        "fechaMejorPuntaje": FieldValue.serverTimestamp()
                    ]) { error in
                        if let error = error {
                            print("Error al actualizar mejor puntaje: \(error.localizedDescription)")
                        } else {
                            print("Mejor puntaje actualizado: \(puntaje)")
                        }
                    }
                }
            }
        }
    }
}
