//
//  MapaViewController.swift
//  AppEstados
//
//  Created by Karla Ayala on 23/06/25.
//

import UIKit
import MapKit

class MapaViewController: UIViewController, MKMapViewDelegate {


    let mapView = MKMapView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        self.title = " "
        mapView.frame = view.bounds
        mapView.delegate = self
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tapRecognizer)
        agregarEstados()
    }

    func agregarEstados() {

        guard let url = Bundle.main.url(forResource: "estados_simplificados 2", withExtension: "geojson"),
              let data = try? Data(contentsOf: url),
              let features = try? MKGeoJSONDecoder().decode(data) as? [MKGeoJSONFeature] else {
            print("Error cargando GeoJSON")
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
        if let first = mapView.overlays.first as? MKPolygon {
            let region = MKCoordinateRegion(center: first.coordinate,
                                            latitudinalMeters: 1_500_000,
                                            longitudinalMeters: 1_500_000)
            mapView.setRegion(region, animated: false)
        }


        //  Coordenadas de ejemplo (CDMX ficticia)
        /*   let coords = [
         CLLocationCoordinate2D(latitude: 19.43, longitude: -99.13),
         CLLocationCoordinate2D(latitude: 19.5, longitude: -99.1),
         CLLocationCoordinate2D(latitude: 19.45, longitude: -98.9),
         CLLocationCoordinate2D(latitude: 19.35, longitude: -99.0)
         ]

         let estado = MKPolygon(coordinates: coords, count: coords.count)
         estado.title = "CDMX"
         mapView.addOverlay(estado)

         // Ajustar cámara
         let region = MKCoordinateRegion(center: coords[0], latitudinalMeters: 100_000, longitudinalMeters: 100_000)
         mapView.setRegion(region, animated: true) */




        /*
         if let url = Bundle.main.url(forResource: "estados_mexico", withExtension: "geojson") {
         let data = try! Data(contentsOf: url)
         let features = try! MKGeoJSONDecoder().decode(data)
         for feature in features {
         if let mkFeature = feature as? MKGeoJSONFeature,
         let geometry = mkFeature.geometry.first as? MKPolygon {
         geometry.title = mkFeature.identifier
         mapView.addOverlay(geometry)
         }
         }
         } */
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
                present(detalleVC ?? UIViewController(), animated: true)
                
                return // Salir después de encontrar el estado
            }
        }
    }


}
