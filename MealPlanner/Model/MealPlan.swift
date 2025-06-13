import Foundation
import CoreData

@objc(MealPlan)
public class MealPlan: NSManagedObject {}

extension MealPlan {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MealPlan> {
        NSFetchRequest<MealPlan>(entityName: "MealPlan")
    }

    @NSManaged public var id: UUID
    @NSManaged public var weekStartDate: Date
    @NSManaged public var days: NSSet? // relacja do MealPlanDay
}
