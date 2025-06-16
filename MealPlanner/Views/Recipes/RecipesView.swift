import SwiftUI
import CoreData

struct RecipesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \.name, ascending: true)],
        animation: .default)
    private var recipes: FetchedResults<Recipe>

    @State private var showingAddRecipeSheet = false
    @State private var searchText = ""

    var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return Array(recipes)
        } else {
            return recipes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(filteredRecipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        RecipeRow(recipe: recipe)
                    }
                }
                .onDelete(perform: deleteRecipes)
            }
            .navigationTitle("Przepisy")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button {
                        showingAddRecipeSheet = true
                    } label: {
                        Label("Dodaj przepis", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipeSheet) {
                AddEditRecipeView(isNewRecipe: true)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private func deleteRecipes(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredRecipes[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct RecipeRow: View {
    @ObservedObject var recipe: Recipe

    var body: some View {
        VStack(alignment: .leading) {
            Text(recipe.name)
                .font(.headline)
            Text(recipe.category ?? "Brak kategorii")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("Składników: \(recipe.ingredients?.count ?? 0)")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct RecipesView_Previews: PreviewProvider {
    static var previews: some View {
        RecipesView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


