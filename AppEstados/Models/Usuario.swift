//
//  Usuario.swift
//  AppEstados
//
//  Created by Jose David on 03/12/25.
//

import Foundation
import FirebaseFirestore

struct Usuario: Codable {
    var uid: String
    var nombre: String
    var email: String
    var usuario: String
    var imagenProfile: String
    var fechaRegistro: Timestamp?
    var fechaActualizacionImagen: Timestamp?
    
    // Convertir de Dictionary a Usuario
    init?(dictionary: [String: Any], uid: String) {
        guard let nombre = dictionary["nombre"] as? String,
              let email = dictionary["email"] as? String,
              let usuario = dictionary["usuario"] as? String else {
            return nil
        }
        
        self.uid = uid
        self.nombre = nombre
        self.email = email
        self.usuario = usuario
        self.imagenProfile = dictionary["imagenProfile"] as? String ?? ""
        self.fechaRegistro = dictionary["fechaRegistro"] as? Timestamp
        self.fechaActualizacionImagen = dictionary["fechaActualizacionImagen"] as? Timestamp
    }
    
    // Convertir de Usuario a Dictionary
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "nombre": nombre,
            "email": email,
            "usuario": usuario,
            "imagenProfile": imagenProfile
        ]
        
        if let fechaRegistro = fechaRegistro {
            dict["fechaRegistro"] = fechaRegistro
        }
        
        if let fechaActualizacionImagen = fechaActualizacionImagen {
            dict["fechaActualizacionImagen"] = fechaActualizacionImagen
        }
        
        return dict
    }
}
