import Foundation
import CoreData

@objc(RecipeIngredient)
public class RecipeIngredient: NSManagedObject {}

extension RecipeIngredient {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecipeIngredient> {
        NSFetchRequest<RecipeIngredient>(entityName: "RecipeIngredient")
    }

    @NSManaged public var id: UUID
    @NSManaged public var quantity: Double
    @NSManaged public var unit: String
    @NSManaged public var ingredientName: String
    @NSManaged public var recipe: Recipe
}
