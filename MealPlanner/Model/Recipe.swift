import Foundation
import CoreData

@objc(Recipe)
public class Recipe: NSManagedObject {}

extension Recipe {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        NSFetchRequest<Recipe>(entityName: "Recipe")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var instructions: String?
    @NSManaged public var ingredients: NSSet? // relacja do RecipeIngredient
}
