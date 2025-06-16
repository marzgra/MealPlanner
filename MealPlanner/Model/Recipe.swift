
import Foundation
import CoreData

@objc(Recipe)
public class Recipe: NSManagedObject, Identifiable {
    @NSManaged public var name: String
    @NSManaged public var preparationSteps: String
    @NSManaged public var servings: Int16
    @NSManaged public var preparationTime: Int16
    @NSManaged public var category: String
    @NSManaged public var tags: String?
    @NSManaged public var ingredients: NSSet?
}

extension Recipe {
    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: RecipeIngredient)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: RecipeIngredient)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSSet)
}


