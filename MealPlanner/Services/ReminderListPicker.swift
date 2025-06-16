
import SwiftUI
import EventKit

struct ReminderListPicker: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedReminderList: EKCalendar?

    @State private var reminderLists: [EKCalendar] = []
    @State private var selectedListId: String? = nil

    let reminderManager = ReminderManager()

    var body: some View {
        NavigationView {
            List(reminderLists, id: \.calendarIdentifier) {
                list in
                HStack {
                    Text(list.title)
                    Spacer()
                    if list.calendarIdentifier == selectedListId {
                        Image(systemName: "checkmark")
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedListId = list.calendarIdentifier
                    selectedReminderList = list
                    dismiss()
                }
            }
            .navigationTitle("Wybierz listę Reminders")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
            }
            .onAppear(perform: loadReminderLists)
        }
    }

    private func loadReminderLists() {
        reminderManager.requestAccess { granted, error in
            if granted {
                reminderLists = reminderManager.getReminderLists()
                selectedListId = selectedReminderList?.calendarIdentifier
            } else if let error = error {
                print("Błąd dostępu do Reminders: \(error.localizedDescription)")
                // TODO: Show alert to user
            }
        }
    }
}

struct ReminderListPicker_Previews: PreviewProvider {
    @State static var selectedList: EKCalendar? = nil

    static var previews: some View {
        ReminderListPicker(selectedReminderList: $selectedList)
    }
}


