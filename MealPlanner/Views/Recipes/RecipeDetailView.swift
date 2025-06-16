
import SwiftUI
import CoreData

struct RecipeDetailView: View {
    @ObservedObject var recipe: Recipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(recipe.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Kategoria: \(recipe.category)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if let tags = recipe.tags, !tags.isEmpty {
                    Text("Tagi: \(tags)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Divider()

                Text("Składniki")
                    .font(.title2)
                    .fontWeight(.semibold)

                if let recipeIngredients = recipe.ingredients as? Set<RecipeIngredient> {
                    ForEach(recipeIngredients.sorted(by: { $0.name < $1.name })) { ingredient in
                        Text("- \(ingredient.name): \(ingredient.quantity, specifier: "%.0f") \(ingredient.unit)")
                    }
                }

                Divider()

                Text("Kroki przygotowania")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(recipe.preparationSteps)

                Divider()

                HStack {
                    Text("Porcje: \(recipe.servings)")
                    Spacer()
                    Text("Czas przygotowania: \(recipe.preparationTime) min")
                }
                .font(.subheadline)
                .foregroundColor(.gray)
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AddEditRecipeView(recipe: recipe, isNewRecipe: false)) {
                    Text("Edytuj")
                }
            }
        }
    }
}

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let newRecipe = Recipe(context: context)
        newRecipe.name = "Przykładowy przepis"
        newRecipe.category = "Obiad"
        newRecipe.preparationSteps = "Krok 1. Zrób to. Krok 2. Zrób tamto."
        newRecipe.servings = 4
        newRecipe.preparationTime = 30
        newRecipe.tags = "szybkie, wege"

        let ingredient1 = RecipeIngredient(context: context)
        ingredient1.name = "Cebula"
        ingredient1.quantity = 1
        ingredient1.unit = "sztuki"
        newRecipe.addToIngredients(ingredient1)

        let ingredient2 = RecipeIngredient(context: context)
        ingredient2.name = "Ryż"
        ingredient2.quantity = 200
        ingredient2.unit = "g"
        newRecipe.addToIngredients(ingredient2)

        return NavigationView {
            RecipeDetailView(recipe: newRecipe)
                .environment(\.managedObjectContext, context)
        }
    }
}


