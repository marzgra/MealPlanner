
import Foundation
import CoreData

@objc(Ingredient)
public class Ingredient: NSManagedObject {
    @NSManaged public var name: String
    @NSManaged public var quantity: Double
    @NSManaged public var unit: String
    @NSManaged public var expiryDate: Date?
    @NSManaged public var category: String
}


