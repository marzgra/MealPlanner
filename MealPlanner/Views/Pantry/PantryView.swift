import SwiftUI
import CoreData

struct PantryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Ingredient.category, ascending: true),
                          NSSortDescriptor(keyPath: \Ingredient.name, ascending: true)],
        animation: .default)
    private var ingredients: FetchedResults<Ingredient>

    @State private var showingAddIngredientSheet = false

    var body: some View {
        NavigationView {
            List {
                ForEach(groupedIngredients.keys.sorted(), id: \.self) { category in
                    Section(header: Text(category)) {
                        ForEach(groupedIngredients[category]!, id: \.self) { ingredient in
                            IngredientRow(ingredient: ingredient)
                        }
                        .onDelete { indexSet in
                            deleteIngredients(offsets: indexSet, category: category)
                        }
                    }
                }
            }
            .navigationTitle("Spiżarnia")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button {
                        showingAddIngredientSheet = true
                    } label: {
                        Label("Dodaj składnik", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddIngredientSheet) {
                AddEditIngredientView(isNewIngredient: true)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private var groupedIngredients: [String: [Ingredient]] {
        Dictionary(grouping: ingredients) { $0.category }
    }

    private func deleteIngredients(offsets: IndexSet, category: String) {
        withAnimation {
            guard let ingredientsInCategory = groupedIngredients[category] else { return }
            offsets.map { ingredientsInCategory[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct IngredientRow: View {
    @ObservedObject var ingredient: Ingredient

    var body: some View {
        HStack {
            Text(ingredient.name)
            Spacer()
            Text("\(ingredient.quantity, specifier: "%.0f") \(ingredient.unit)")
            if let expiryDate = ingredient.expiryDate {
                Text("\(expiryDate, formatter: itemFormatter)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()

struct PantryView_Previews: PreviewProvider {
    static var previews: some View {
        PantryView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


