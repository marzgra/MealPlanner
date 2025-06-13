import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            PantryView()
                .tabItem {
                    Label("Spiżarnia", systemImage: "archivebox")
                }

            RecipesView()
                .tabItem {
                    Label("Przepisy", systemImage: "book")
                }

            MealPlanView()
                .tabItem {
                    Label("Menu", systemImage: "calendar")
                }

            ShoppingListView()
                .tabItem {
                    Label("Zakupy", systemImage: "cart")
                }
        }
    }
}
