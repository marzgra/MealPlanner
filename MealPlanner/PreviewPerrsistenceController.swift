import CoreData

struct PreviewPersistenceController {
    static let shared: PersistenceController = {
        let controller = PersistenceController(inMemory: true)

        let viewContext = controller.container.viewContext

        do {
            try viewContext.save()
        } catch {
            fatalError("Błąd zapisu danych preview: \(error)")
        }

        return controller
    }()
}
