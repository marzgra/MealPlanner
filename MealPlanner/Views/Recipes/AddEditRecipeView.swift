
import SwiftUI
import CoreData

struct AddEditRecipeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var category: String = "Obiad"
    @State private var preparationSteps: String = ""
    @State private var servings: String = "1"
    @State private var preparationTime: String = "0"
    @State private var tags: String = ""
    @State private var recipeIngredients: [RecipeIngredientForm] = []

    var recipe: Recipe? // For editing existing recipe
    var isNewRecipe: Bool

    let categories = ["Śniadanie", "Obiad", "Kolacja", "Przekąska", "Deser", "Inne"]
    let units = ["g", "ml", "sztuki", "opakowania", "łyżki", "łyżeczki", "szklanki", "inne"]

    init(recipe: Recipe? = nil, isNewRecipe: Bool) {
        self.recipe = recipe
        self.isNewRecipe = isNewRecipe
        _name = State(initialValue: recipe?.name ?? "")
        _category = State(initialValue: recipe?.category ?? "Obiad")
        _preparationSteps = State(initialValue: recipe?.preparationSteps ?? "")
        _servings = State(initialValue: String(recipe?.servings ?? 1))
        _preparationTime = State(initialValue: String(recipe?.preparationTime ?? 0))
        _tags = State(initialValue: recipe?.tags ?? "")

        if let existingIngredients = recipe?.ingredients as? Set<RecipeIngredient> {
            _recipeIngredients = State(initialValue: existingIngredients.map { RecipeIngredientForm(id: UUID(), name: $0.name, quantity: String($0.quantity), unit: $0.unit) })
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informacje o przepisie")) {
                    TextField("Nazwa przepisu", text: $name)
                    Picker("Kategoria", selection: $category) {
                        ForEach(categories, id: \.self) {
                            Text($0)
                        }
                    }
                    TextField("Ilość porcji", text: $servings)
                        .keyboardType(.numberPad)
                    TextField("Czas przygotowania (minuty)", text: $preparationTime)
                        .keyboardType(.numberPad)
                    TextField("Tagi (oddzielone przecinkami)", text: $tags)
                }

                Section(header: Text("Składniki")) {
                    ForEach($recipeIngredients) { $ingredient in
                        HStack {
                            TextField("Nazwa", text: $ingredient.name)
                            TextField("Ilość", text: $ingredient.quantity)
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                            Picker("Jednostka", selection: $ingredient.unit) {
                                ForEach(units, id: \.self) {
                                    Text($0)
                                }
                            }
                            .frame(width: 100)
                        }
                    }
                    .onDelete(perform: deleteRecipeIngredient)

                    Button("Dodaj składnik") {
                        recipeIngredients.append(RecipeIngredientForm(id: UUID(), name: "", quantity: "", unit: "sztuki"))
                    }
                }

                Section(header: Text("Kroki przygotowania")) {
                    TextEditor(text: $preparationSteps)
                        .frame(minHeight: 100)
                }

                Button("Zapisz przepis") {
                    saveRecipe()
                }
            }
            .navigationTitle(isNewRecipe ? "Dodaj przepis" : "Edytuj przepis")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func deleteRecipeIngredient(at offsets: IndexSet) {
        recipeIngredients.remove(atOffsets: offsets)
    }

    private func saveRecipe() {
        guard let servingsInt = Int16(servings), let preparationTimeInt = Int16(preparationTime) else { return }

        let recipeToSave = recipe ?? Recipe(context: viewContext)
        recipeToSave.name = name
        recipeToSave.category = category
        recipeToSave.preparationSteps = preparationSteps
        recipeToSave.servings = servingsInt
        recipeToSave.preparationTime = preparationTimeInt
        recipeToSave.tags = tags.isEmpty ? nil : tags

        // Remove old ingredients if editing
        if let existingIngredients = recipeToSave.ingredients as? Set<RecipeIngredient> {
            for ingredient in existingIngredients {
                viewContext.delete(ingredient)
            }
        }
        recipeToSave.ingredients = []

        // Add new ingredients
        for ingredientForm in recipeIngredients {
            guard let quantityDouble = Double(ingredientForm.quantity) else { continue }
            let newIngredient = RecipeIngredient(context: viewContext)
            newIngredient.name = ingredientForm.name
            newIngredient.quantity = quantityDouble
            newIngredient.unit = ingredientForm.unit
            recipeToSave.addToIngredients(newIngredient)
        }

        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct RecipeIngredientForm: Identifiable {
    let id: UUID
    var name: String
    var quantity: String
    var unit: String
}

struct AddEditRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditRecipeView(isNewRecipe: true)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


