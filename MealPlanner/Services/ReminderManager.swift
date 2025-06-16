import EventKit

class ReminderManager {
    let eventStore = EKEventStore()
    
    func requestAccess(completion: @escaping (Bool, Error?) -> Void) {
        eventStore.requestAccess(to: .reminder) { granted, error in
            DispatchQueue.main.async {
                completion(granted, error)
            }
        }
    }
    
    func getReminderLists() -> [EKCalendar] {
        eventStore.calendars(for: .reminder).filter { $0.allowsContentModifications }
    }
    
    func addShoppingListToReminders(items: [ShoppingListItem], toList list: EKCalendar, completion: @escaping (Bool, Error?) -> Void) {
        for item in items {
            let reminder = EKReminder(eventStore: eventStore)
            reminder.title = "\(item.name) - \(String(format: "%.0f", item.quantity)) \(item.unit)"
            reminder.calendar = list
            do {
                try eventStore.save(reminder, commit: true)
            } catch let error {
                completion(false, error)
                return
            }
        }
        completion(true, nil)
    }
}


