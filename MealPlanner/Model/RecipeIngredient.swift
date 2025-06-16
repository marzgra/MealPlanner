
import Foundation
import CoreData

@objc(RecipeIngredient)
public class RecipeIngredient: NSManagedObject, Identifiable {
    @NSManaged public var name: String
    @NSManaged public var quantity: Double
    @NSManaged public var unit: String
    @NSManaged public var recipe: Recipe?
}


