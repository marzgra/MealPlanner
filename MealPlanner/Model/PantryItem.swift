import CoreData

@objc(PantryItem)
public class PantryItem: NSManagedObject {}

extension PantryItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PantryItem> {
        NSFetchRequest<PantryItem>(entityName: "PantryItem")
    }

    @NSManaged public var id: UUID
    @NSManaged public var ingredientName: String
    @NSManaged public var quantity: Double
    @NSManaged public var unit: String
    @NSManaged public var expirationDate: Date?
}
