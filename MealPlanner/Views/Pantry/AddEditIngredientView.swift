
import SwiftUI
import CoreData

struct AddEditIngredientView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var quantity: String = ""
    @State private var unit: String = "sztuki"
    @State private var expiryDate: Date = Date()
    @State private var hasExpiryDate: Bool = false
    @State private var category: String = "Inne"

    var ingredient: Ingredient? // For editing existing ingredient
    var isNewIngredient: Bool

    let units = ["g", "ml", "sztuki", "opakowania", "łyżki", "łyżeczki", "szklanki", "inne"]
    let categories = ["Nabiał", "Puszki", "Mięso", "Warzywa i owoce", "Mąki", "Makaron i ryż", "Przekąski", "Inne"]

    init(ingredient: Ingredient? = nil, isNewIngredient: Bool) {
        self.ingredient = ingredient
        self.isNewIngredient = isNewIngredient
        _name = State(initialValue: ingredient?.name ?? "")
        _quantity = State(initialValue: String(ingredient?.quantity ?? 0.0))
        _unit = State(initialValue: ingredient?.unit ?? "sztuki")
        _expiryDate = State(initialValue: ingredient?.expiryDate ?? Date())
        _hasExpiryDate = State(initialValue: ingredient?.expiryDate != nil)
        _category = State(initialValue: ingredient?.category ?? "Inne")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informacje o składniku")) {
                    TextField("Nazwa", text: $name)
                    TextField("Ilość", text: $quantity)
                        .keyboardType(.decimalPad)
                    Picker("Jednostka", selection: $unit) {
                        ForEach(units, id: \.self) {
                            Text($0)
                        }
                    }
                    Picker("Kategoria", selection: $category) {
                        ForEach(categories, id: \.self) {
                            Text($0)
                        }
                    }
                }

                Section {
                    Toggle(isOn: $hasExpiryDate) {
                        Text("Data przydatności")
                    }
                    if hasExpiryDate {
                        DatePicker("Data", selection: $expiryDate, displayedComponents: .date)
                    }
                }

                Button("Zapisz") {
                    saveIngredient()
                }
            }
            .navigationTitle(isNewIngredient ? "Dodaj składnik" : "Edytuj składnik")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveIngredient() {
        guard let quantityDouble = Double(quantity) else { return }

        let ingredientToSave = ingredient ?? Ingredient(context: viewContext)
        ingredientToSave.name = name
        ingredientToSave.quantity = quantityDouble
        ingredientToSave.unit = unit
        ingredientToSave.expiryDate = hasExpiryDate ? expiryDate : nil
        ingredientToSave.category = category

        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct AddEditIngredientView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditIngredientView(isNewIngredient: true)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


