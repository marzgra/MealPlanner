import SwiftUI
import CoreData
import EventKit

struct ShoppingListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ShoppingListItem.category, ascending: true),
                          NSSortDescriptor(keyPath: \ShoppingListItem.name, ascending: true)],
        animation: .default)
    private var shoppingListItems: FetchedResults<ShoppingListItem>

    @State private var showingGenerateShoppingListSheet = false
    @State private var showingReminderListPicker = false
    @State private var selectedReminderList: EKCalendar? = nil
    @State private var showingExportSuccessAlert = false
    @State private var showingExportErrorAlert = false
    @State private var exportErrorMessage: String = ""

    let reminderManager = ReminderManager()

    var body: some View {
        NavigationView {
            List {
                ForEach(groupedShoppingListItems.keys.sorted(), id: \.self) { category in
                    Section(header: Text(category)) {
                        ForEach(groupedShoppingListItems[category]!, id: \.self) { item in
                            ShoppingListItemRow(item: item)
                        }
                        .onDelete { indexSet in
                            deleteShoppingListItem(offsets: indexSet, category: category)
                        }
                    }
                }
            }
            .navigationTitle("Lista zakupów")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button {
                        showingGenerateShoppingListSheet = true
                    } label: {
                        Label("Generuj listę", systemImage: "plus.circle.fill")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Eksportuj do Reminders") {
                        exportToReminders()
                    }
                }
            }
            .sheet(isPresented: $showingGenerateShoppingListSheet) {
                GenerateShoppingListView()
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingReminderListPicker) {
                ReminderListPicker(selectedReminderList: $selectedReminderList)
            }
            .alert("Eksport zakończony pomyślnie", isPresented: $showingExportSuccessAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Błąd eksportu", isPresented: $showingExportErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(exportErrorMessage)
            }
        }
    }

    private var groupedShoppingListItems: [String: [ShoppingListItem]] {
        Dictionary(grouping: shoppingListItems) { $0.category }
    }

    private func deleteShoppingListItem(offsets: IndexSet, category: String) {
        withAnimation {
            guard let itemsInCategory = groupedShoppingListItems[category] else { return }
            offsets.map { itemsInCategory[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func exportToReminders() {
        reminderManager.requestAccess { granted, error in
            if granted {
                if let selectedList = selectedReminderList {
                    reminderManager.addShoppingListToReminders(items: Array(shoppingListItems), toList: selectedList) { success, exportError in
                        if success {
                            showingExportSuccessAlert = true
                        } else {
                            exportErrorMessage = exportError?.localizedDescription ?? "Nieznany błąd podczas eksportu."
                            showingExportErrorAlert = true
                        }
                    }
                } else {
                    // No list selected, show picker
                    showingReminderListPicker = true
                }
            } else if let error = error {
                exportErrorMessage = error.localizedDescription
                showingExportErrorAlert = true
            } else {
                exportErrorMessage = "Brak dostępu do Reminders. Proszę włączyć dostęp w Ustawieniach."
                showingExportErrorAlert = true
            }
        }
    }
}

struct ShoppingListItemRow: View {
    @ObservedObject var item: ShoppingListItem
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        HStack {
            Button {
                item.isChecked.toggle()
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            } label: {
                Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(item.isChecked ? .green : .primary)
            }
            .buttonStyle(.plain)

            Text("\(item.name) - \(item.quantity, specifier: "%.0f") \(item.unit)")
                .strikethrough(item.isChecked)
                .foregroundColor(item.isChecked ? .gray : .primary)

            Spacer()
        }
    }
}

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


