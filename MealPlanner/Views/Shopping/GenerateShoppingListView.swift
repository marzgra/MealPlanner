import SwiftUI
import CoreData

struct GenerateShoppingListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MealPlan.date, ascending: true)],
        animation: .default)
    private var mealPlans: FetchedResults<MealPlan>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Ingredient.name, ascending: true)],
        animation: .default)
    private var pantryIngredients: FetchedResults<Ingredient>
    
    @State private var selectedMealPlans: Set<MealPlan> = []
    @State private var shoppingListPreview: [ShoppingListItemPreview] = []
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Wybierz posiłki do uwzględnienia")) {
                        ForEach(mealPlans) { mealPlan in
                            Toggle(isOn: bindingForMealPlan(mealPlan)) {
                                Text("\(mealPlan.mealType) - \(mealPlan.recipe?.name ?? mealPlan.customMealName ?? "Brak") (\(mealPlan.date, formatter: itemFormatter))")
                            }
                        }
                    }
                    
                    Section(header: Text("Podgląd listy zakupów")) {
                        if shoppingListPreview.isEmpty {
                            Text("Wybierz posiłki, aby wygenerować podgląd.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach($shoppingListPreview) { $item in
                                HStack {
                                    Text("\(item.name) - \(item.quantity, specifier: "%.0f") \(item.unit)")
                                    Spacer()
                                    Button(action: {
                                        item.inPantry.toggle()
                                    }) {
                                        Image(systemName: item.inPantry ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .foregroundColor(item.inPantry ? .green : .red)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Button("Generuj listę zakupów") {
                    generateShoppingList()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("Generuj listę zakupów")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Podgląd") {
                        updateShoppingListPreview()
                    }
                }
            }
        }
    }
    
    private func bindingForMealPlan(_ mealPlan: MealPlan) -> Binding<Bool> {
        Binding(
            get: { selectedMealPlans.contains(mealPlan) },
            set: { isSelected in
                if isSelected {
                    selectedMealPlans.insert(mealPlan)
                } else {
                    selectedMealPlans.remove(mealPlan)
                }
            }
        )
    }
    
    private func updateShoppingListPreview() {
        var combinedIngredients: [String: ShoppingListItemPreview] = [:]
        
        for mealPlan in selectedMealPlans {
            if let recipe = mealPlan.recipe {
                if let recipeIngredients = recipe.ingredients as? Set<RecipeIngredient> {
                    for recipeIngredient in recipeIngredients {
                        let key = "\(recipeIngredient.name)-\(recipeIngredient.unit)"
                        let inPantry = pantryIngredients.contains(where: { $0.name == recipeIngredient.name && $0.unit == recipeIngredient.unit && $0.quantity >= recipeIngredient.quantity })
                        
                        if var existing = combinedIngredients[key] {
                            existing.quantity += recipeIngredient.quantity
                        } else {
                            combinedIngredients[key] = ShoppingListItemPreview(name: recipeIngredient.name,
                                                                               quantity: recipeIngredient.quantity,
                                                                               unit: recipeIngredient.unit,
                                                                               inPantry: inPantry)
                        }
                    }
                }
            }
        }
        shoppingListPreview = Array(combinedIngredients.values).sorted { $0.name < $1.name }
    }
    
    private func generateShoppingList() {
        updateShoppingListPreview() // Ensure preview is up-to-date
        
        for itemPreview in shoppingListPreview where !itemPreview.inPantry {
            let newItem = ShoppingListItem(context: viewContext)
            newItem.name = itemPreview.name
            newItem.quantity = itemPreview.quantity
            newItem.unit = itemPreview.unit
            newItem.isChecked = false
            newItem.category = "Inne" // TODO: Better category assignment
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

struct ShoppingListItemPreview: Identifiable {
    let id = UUID()
    var name: String
    var quantity: Double
    var unit: String
    var inPantry: Bool
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()

struct GenerateShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        GenerateShoppingListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


