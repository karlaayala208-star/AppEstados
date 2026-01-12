//
//  CoreDataManager.swift
//  AppEstados
//
//  Created by AI Assistant on 12/01/26.
//

import Foundation
import CoreData

class CoreDataManager {
    
    // Singleton
    static let shared = CoreDataManager()
    
    private init() {}
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AppEstados")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error al cargar Core Data: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Guardar Contexto
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Core Data guardado exitosamente")
            } catch {
                print("❌ Error al guardar Core Data: \(error)")
            }
        }
    }
    
    // MARK: - Operaciones de Favoritos
    
    /// Verificar si un estado es favorito
    func esFavorito(_ nombreEstado: String) -> Bool {
        let fetchRequest: NSFetchRequest<EstadoFavorito> = EstadoFavorito.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "nombreEstado == %@", nombreEstado)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error al verificar favorito: \(error)")
            return false
        }
    }
    
    /// Agregar estado a favoritos
    func agregarFavorito(_ nombreEstado: String) {
        // Verificar que no exista ya
        guard !esFavorito(nombreEstado) else {
            print("⚠️ El estado \(nombreEstado) ya está en favoritos")
            return
        }
        
        // Crear nuevo favorito
        let nuevoFavorito = EstadoFavorito(context: context)
        nuevoFavorito.nombreEstado = nombreEstado
        nuevoFavorito.fechaAgregado = Date()
        nuevoFavorito.ordenPersonalizado = Int16(obtenerCantidadFavoritos())
        
        saveContext()
        print("⭐ Estado \(nombreEstado) agregado a favoritos")
    }
    
    /// Quitar estado de favoritos
    func quitarFavorito(_ nombreEstado: String) {
        let fetchRequest: NSFetchRequest<EstadoFavorito> = EstadoFavorito.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "nombreEstado == %@", nombreEstado)
        
        do {
            let resultados = try context.fetch(fetchRequest)
            for favorito in resultados {
                context.delete(favorito)
            }
            saveContext()
            print("🗑️ Estado \(nombreEstado) eliminado de favoritos")
        } catch {
            print("Error al eliminar favorito: \(error)")
        }
    }
    
    /// Alternar estado favorito (agregar si no existe, quitar si existe)
    func toggleFavorito(_ nombreEstado: String) -> Bool {
        if esFavorito(nombreEstado) {
            quitarFavorito(nombreEstado)
            return false
        } else {
            agregarFavorito(nombreEstado)
            return true
        }
    }
    
    /// Obtener todos los favoritos ordenados
    func obtenerFavoritos() -> [EstadoFavorito] {
        let fetchRequest: NSFetchRequest<EstadoFavorito> = EstadoFavorito.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fechaAgregado", ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error al obtener favoritos: \(error)")
            return []
        }
    }
    
    /// Obtener cantidad de favoritos
    func obtenerCantidadFavoritos() -> Int {
        let fetchRequest: NSFetchRequest<EstadoFavorito> = EstadoFavorito.fetchRequest()
        
        do {
            return try context.count(for: fetchRequest)
        } catch {
            print("Error al contar favoritos: \(error)")
            return 0
        }
    }
    
    /// Limpiar todos los favoritos
    func limpiarTodosFavoritos() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = EstadoFavorito.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            saveContext()
            print("🧹 Todos los favoritos han sido eliminados")
        } catch {
            print("Error al limpiar favoritos: \(error)")
        }
    }
}
