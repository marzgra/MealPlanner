
import Foundation
import CoreData

@objc(MealPlan)
public class MealPlan: NSManagedObject, Identifiable {
    @NSManaged public var date: Date
    @NSManaged public var mealType: String // e.g., "Breakfast", "Lunch", "Dinner", "Snack"
    @NSManaged public var recipe: Recipe?
    @NSManaged public var customMealName: String?
}


