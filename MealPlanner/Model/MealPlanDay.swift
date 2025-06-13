import Foundation
import CoreData

@objc(MealPlanDay)
public class MealPlanDay: NSManagedObject {}

extension MealPlanDay {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MealPlanDay> {
        NSFetchRequest<MealPlanDay>(entityName: "MealPlanDay")
    }

    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var meals: NSSet? // przepisy (śniadanie, obiad, kolacja itd.)
    @NSManaged public var mealPlan: MealPlan
}
