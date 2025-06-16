import SwiftUI
import CoreData

struct WeeklyMenuView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \.date, ascending: true)],
        animation: .default)
    private var mealPlans: FetchedResults<MealPlan>

    @State private var selectedDate: Date = Date()

    var body: some View {
        NavigationView {
            VStack {
                // Horizontal Date Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(0..<7) { i in
                            let date = Calendar.current.date(byAdding: .day, value: i, to: startOfWeek())!
                            DayCell(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate))
                                .onTapGesture {
                                    selectedDate = date
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 80)

                // Meals for selected day
                List {
                    Section(header: Text("Śniadanie")) {
                        MealPlanRow(mealType: "Śniadanie", selectedDate: selectedDate)
                    }
                    Section(header: Text("Obiad")) {
                        MealPlanRow(mealType: "Obiad", selectedDate: selectedDate)
                    }
                    Section(header: Text("Kolacja")) {
                        MealPlanRow(mealType: "Kolacja", selectedDate: selectedDate)
                    }
                    Section(header: Text("Przekąska")) {
                        MealPlanRow(mealType: "Przekąska", selectedDate: selectedDate)
                    }
                }
                .listStyle(.insetGrouped)

                Spacer()

                Button("Wygeneruj menu") {
                    MenuGenerator(viewContext: viewContext).generateWeeklyMenu()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("Menu tygodniowe")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // TODO: Add settings or other actions
                    } label: {
                        Label("Ustawienia", systemImage: "gear")
                    }
                }
            }
        }
    }

    private func startOfWeek() -> Date {
        Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: selectedDate).date!
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool

    var body: some View {
        VStack {
            Text(date, format: .dateTime(.weekday(.short)))
                .font(.caption)
            Text(date, format: .dateTime(.day))
                .font(.title2)
        }
        .padding(8)
        .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
        .cornerRadius(8)
    }
}

struct MealPlanRow: View {
    @Environment(\.managedObjectContext) private var viewContext
    let mealType: String
    let selectedDate: Date

    @FetchRequest var mealPlansForType: FetchedResults<MealPlan>

    init(mealType: String, selectedDate: Date) {
        self.mealType = mealType
        self.selectedDate = selectedDate
        _mealPlansForType = FetchRequest<MealPlan>(
            sortDescriptors: [],
            predicate: NSPredicate(format: "mealType == %@ AND date >= %@ AND date < %@",
                                   mealType, selectedDate.startOfDay as NSDate, selectedDate.endOfDay as NSDate)
        )
    }

    var body: some View {
        if let mealPlan = mealPlansForType.first {
            NavigationLink(destination: AddEditMealPlanView(mealPlan: mealPlan, selectedDate: selectedDate)) {
                Text(mealPlan.recipe?.name ?? mealPlan.customMealName ?? "Brak")
            }
        } else {
            NavigationLink(destination: AddEditMealPlanView(selectedDate: selectedDate, mealType: mealType)) {
                Text("Dodaj posiłek")
                    .foregroundColor(.gray)
            }
        }
    }
}

struct WeeklyMenuView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyMenuView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)! 
    }
}


