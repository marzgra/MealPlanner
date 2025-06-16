
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PantryView()
                .tabItem {
                    Label("Spiżarnia", systemImage: "archivebox.fill")
                }

            RecipesView()
                .tabItem {
                    Label("Przepisy", systemImage: "book.closed.fill")
                }

            WeeklyMenuView()
                .tabItem {
                    Label("Menu", systemImage: "calendar")
                }

            ShoppingListView()
                .tabItem {
                    Label("Zakupy", systemImage: "cart.fill")
                }
        }
    }
}
