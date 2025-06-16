
import Foundation
import CoreData

@objc(ShoppingListItem)
public class ShoppingListItem: NSManagedObject {
    @NSManaged public var name: String
    @NSManaged public var quantity: Double
    @NSManaged public var unit: String
    @NSManaged public var isChecked: Bool
    @NSManaged public var category: String
}


