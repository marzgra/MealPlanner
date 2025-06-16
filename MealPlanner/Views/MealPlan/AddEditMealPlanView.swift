
import SwiftUI
import CoreData

struct AddEditMealPlanView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    var mealPlan: MealPlan? // For editing existing meal plan
    var selectedDate: Date
    var mealType: String

    @State private var selectedRecipe: Recipe? = nil
    @State private var customMealName: String = ""
    @State private var useCustomMeal: Bool = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.name, ascending: true)],
        animation: .default
    )
    private var recipes: FetchedResults<Recipe>


    init(mealPlan: MealPlan? = nil, selectedDate: Date, mealType: String = "") {
        self.mealPlan = mealPlan
        self.selectedDate = selectedDate
        self.mealType = mealType

        _selectedRecipe = State(initialValue: mealPlan?.recipe)
        _customMealName = State(initialValue: mealPlan?.customMealName ?? "")
        _useCustomMeal = State(initialValue: mealPlan?.customMealName != nil)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Typ posiłku")) {
                    Text("\(mealType) - \(selectedDate, formatter: itemFormatter)")
                }

                Toggle(isOn: $useCustomMeal) {
                    Text("Dodaj własny posiłek")
                }

                if useCustomMeal {
                    TextField("Nazwa posiłku", text: $customMealName)
                } else {
                    Picker("Wybierz przepis", selection: $selectedRecipe) {
                        Text("Brak").tag(nil as Recipe?)
                        ForEach(recipes, id: \.self) {
                            Text($0.name).tag($0 as Recipe?)
                        }
                    }
                }

                Button("Zapisz") {
                    saveMealPlan()
                }

                if mealPlan != nil {
                    Button("Usuń posiłek") {
                        deleteMealPlan()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle(mealPlan == nil ? "Dodaj posiłek" : "Edytuj posiłek")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveMealPlan() {
        let mealPlanToSave = mealPlan ?? MealPlan(context: viewContext)
        mealPlanToSave.date = selectedDate.startOfDay
        mealPlanToSave.mealType = mealType

        if useCustomMeal {
            mealPlanToSave.customMealName = customMealName
            mealPlanToSave.recipe = nil
        } else {
            mealPlanToSave.recipe = selectedRecipe
            mealPlanToSave.customMealName = nil
        }

        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func deleteMealPlan() {
        if let mealPlan = mealPlan {
            viewContext.delete(mealPlan)
            do {
                try viewContext.save()
                dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

struct AddEditMealPlanView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditMealPlanView(selectedDate: Date(), mealType: "Śniadanie")
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


