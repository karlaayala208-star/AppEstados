//
//  MapaViewController.swift
//  AppEstados
//
//  Created by Karla Ayala on 23/06/25.
//

import UIKit
import MapKit
import FirebaseStorage

class MapaViewController: UIViewController, MKMapViewDelegate {

    let mapView = MKMapView()
    let activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        self.title = " "
        mapView.frame = view.bounds
        mapView.delegate = self
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tapRecognizer)
        
        // Configurar indicador de carga
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        cargarGeoJSON()
    }
    
    func cargarGeoJSON() {
        // Primero intentar cargar desde caché local
        if let cachedData = cargarGeoJSONDeCache() {
            print("Cargando GeoJSON desde caché")
            procesarGeoJSON(data: cachedData)
            return
        }
        
        // Si no hay caché, descargar desde Firebase Storage
        print("Descargando GeoJSON desde Firebase Storage")
        activityIndicator.startAnimating()
        descargarGeoJSONDeFirebase()
    }
    
    func cargarGeoJSONDeCache() -> Data? {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsURL.appendingPathComponent("estados_simplificados.geojson")
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        return try? Data(contentsOf: fileURL)
    }
    
    func descargarGeoJSONDeFirebase() {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let geoJSONRef = storageRef.child("maps/estados_simplificados.geojson")
        
        // Descargar con tamaño máximo de 10MB
        geoJSONRef.getData(maxSize: 10 * 1024 * 1024) { [weak self] data, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            
            if let error = error {
                print("Error descargando GeoJSON: \(error.localizedDescription)")
                // Intentar cargar desde bundle como fallback
                self.cargarGeoJSONDeBundle()
                return
            }
            
            guard let data = data else {
                print("No se recibió data del GeoJSON")
                self.cargarGeoJSONDeBundle()
                return
            }
            
            // Guardar en caché
            self.guardarGeoJSONEnCache(data: data)
            
            // Procesar el GeoJSON
            DispatchQueue.main.async {
                self.procesarGeoJSON(data: data)
            }
        }
    }
    
    func guardarGeoJSONEnCache(data: Data) {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL = documentsURL.appendingPathComponent("estados_simplificados.geojson")
        
        do {
            try data.write(to: fileURL)
            print("GeoJSON guardado en caché exitosamente")
        } catch {
            print("Error guardando GeoJSON en caché: \(error.localizedDescription)")
        }
    }
    
    func cargarGeoJSONDeBundle() {
        // Fallback: cargar desde el bundle si Firebase falla
        print("Cargando GeoJSON desde bundle (fallback)")
        guard let url = Bundle.main.url(forResource: "estados_simplificados 2", withExtension: "geojson"),
              let data = try? Data(contentsOf: url) else {
            print("Error: No se pudo cargar GeoJSON ni de Firebase ni del bundle")
            mostrarAlertaError()
            return
        }
        
        procesarGeoJSON(data: data)
    }
    
    func procesarGeoJSON(data: Data) {
        guard let features = try? MKGeoJSONDecoder().decode(data) as? [MKGeoJSONFeature] else {
            print("Error decodificando GeoJSON")
            mostrarAlertaError()
            return
        }

        for feature in features {
            // Extraer el nombre del estado
            let estadoNombre = feature.properties.flatMap {
                (try? JSONSerialization.jsonObject(with: $0)) as? [String: Any]
            }.flatMap {
                $0["name"] as? String
            }
            
            for geo in feature.geometry {
                // Manejar Polygon simple
                if let poly = geo as? MKPolygon {
                    poly.title = estadoNombre
                    mapView.addOverlay(poly)
                }
                // Manejar MultiPolygon (estados con islas como Baja California)
                else if let multiPoly = geo as? MKMultiPolygon {
                    multiPoly.title = estadoNombre
                    mapView.addOverlay(multiPoly)
                }
            }
        }
        
        // Centrar el mapa en México
        if let first = mapView.overlays.first as? MKPolygon {
            let region = MKCoordinateRegion(center: first.coordinate,
                                            latitudinalMeters: 1_500_000,
                                            longitudinalMeters: 1_500_000)
            mapView.setRegion(region, animated: false)
        }
        
        print("GeoJSON procesado exitosamente: \(features.count) estados cargados")
    }
    
    func mostrarAlertaError() {
        let alerta = UIAlertController(
            title: "Error",
            message: "No se pudo cargar el mapa. Por favor, verifica tu conexión a internet e intenta de nuevo.",
            preferredStyle: .alert
        )
        alerta.addAction(UIAlertAction(title: "Reintentar", style: .default) { [weak self] _ in
            self?.cargarGeoJSON()
        })
        alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alerta, animated: true)
    }

    // 🎨 Renderiza los polígonos
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Manejar Polygon simple
        if let polygon = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.3)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 2
            return renderer
        }
        // Manejar MultiPolygon (estados con islas)
        else if let multiPolygon = overlay as? MKMultiPolygon {
            let renderer = MKMultiPolygonRenderer(multiPolygon: multiPolygon)
            renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.3)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 2
            return renderer
        }
        
        return MKOverlayRenderer()
    }

    @objc func handleMapTap(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: mapView)
        let tapCoordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)
        let mapPoint = MKMapPoint(tapCoordinate)

        for overlay in mapView.overlays {
            var estadoNombre: String?
            var contains = false
            
            // Manejar Polygon simple
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                let point = renderer.point(for: mapPoint)
                if renderer.path.contains(point) {
                    estadoNombre = polygon.title
                    contains = true
                }
            }
            // Manejar MultiPolygon (estados con islas como Baja California)
            else if let multiPolygon = overlay as? MKMultiPolygon {
                let renderer = MKMultiPolygonRenderer(multiPolygon: multiPolygon)
                let point = renderer.point(for: mapPoint)
                if renderer.path.contains(point) {
                    estadoNombre = multiPolygon.title
                    contains = true
                }
            }
            
            if contains, let nombre = estadoNombre {
                print("Tocaste el estado: \(nombre)")
                // Crear y presentar la vista de detalle
                /*  let detalleVC = EstadoDetalleViewController()
                 detalleVC.estadoNombre = nombre

                 // Puedes usar push o modal, según tu estructura
                 if let nav = navigationController {
                 nav.pushViewController(detalleVC, animated: true)
                 } else {
                 present(detalleVC, animated: true)
                 } */

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let detalleVC = storyboard.instantiateViewController(withIdentifier: "EstadoDetalleViewController") as?
                EstadoDetalleViewController
                detalleVC?.estadoNombre = nombre
                
                // Usar push en lugar de present para mostrar el botón de regreso
                if let nav = navigationController {
                    nav.pushViewController(detalleVC ?? UIViewController(), animated: true)
                } else {
                    present(detalleVC ?? UIViewController(), animated: true)
                }
                
                return // Salir después de encontrar el estado
            }
        }
    }
}
