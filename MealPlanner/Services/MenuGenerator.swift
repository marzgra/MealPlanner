import Foundation
import CoreData

class MenuGenerator {
    private let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    func generateWeeklyMenu() {
        // Clear existing meal plans for the week
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MealPlan.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        let calendar = Calendar.current
        let today = Date()
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else { return }

        let mealTypes = ["Śniadanie", "Obiad", "Kolacja", "Przekąska"]

        for i in 0..<7 { // For each day of the week
            guard let currentDay = calendar.date(byAdding: .day, value: i, to: startOfWeek) else { continue }

            for mealType in mealTypes {
                // Simple logic: just add a placeholder for now
                let newMealPlan = MealPlan(context: viewContext)
                newMealPlan.date = currentDay
                newMealPlan.mealType = mealType
                newMealPlan.customMealName = "Wygenerowany posiłek (\[mealType])"
            }
        }

        do {
            try viewContext.save()
            print("Menu wygenerowane pomyślnie.")
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}


