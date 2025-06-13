import Foundation
import CoreData

@objc(ShoppingItem)
public class ShoppingItem: NSManagedObject {}

extension ShoppingItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShoppingItem> {
        NSFetchRequest<ShoppingItem>(entityName: "ShoppingItem")
    }

    @NSManaged public var id: UUID
    @NSManaged public var ingredientName: String
    @NSManaged public var quantity: Double
    @NSManaged public var unit: String
    @NSManaged public var isChecked: Bool
    @NSManaged public var exportedToReminders: Bool
}

