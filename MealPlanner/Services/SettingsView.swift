
import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Jednostki")) {
                    Text("Domyślne jednostki")
                    // TODO: Implement unit selection
                }

                Section(header: Text("Integracje")) {
                    Text("Integracja z Reminders")
                    // TODO: Implement Reminders integration settings
                }

                Section(header: Text("Dane")) {
                    Button("Resetuj wszystkie dane") {
                        // TODO: Implement data reset functionality
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Ustawienia")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}


