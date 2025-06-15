import SwiftUI
import Charts

struct WeeklySummaryView: View {
    @State private var weeklyEntries: [[FoodEntry]] = []

    let calorieGoal = UserDefaults.standard.integer(forKey: "calorieGoal")

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Weekly Summary")
                    .font(.title2)
                    .fontWeight(.bold)

                if !weeklyEntries.isEmpty {
                    let dailyTotals = weeklyEntries.map { day in
                        day.reduce(0) { $0 + $1.calories }
                    }

                    let weeklyTotalCalories = dailyTotals.reduce(0, +)
                    let weeklyGoal = calorieGoal * 7
                    let weeklyDeficit = max(weeklyGoal - weeklyTotalCalories, 0)

                    VStack(spacing: 12) {
                        Text("Weekly Calorie Goal: \(weeklyGoal)")
                        Text("Calories Consumed: \(weeklyTotalCalories)")
                        Text("Deficit: \(weeklyDeficit) calories")
                            .foregroundColor(.green)
                        Text("Est. Weight Loss: \((Double(weeklyDeficit) / 7700).formatted(.number.precision(.fractionLength(2)))) kg")
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 3)
                    .padding(.horizontal)

                    // Bar chart for daily calories
                    let calendar = Calendar.current
                    let weekdaySymbols = calendar.shortWeekdaySymbols

                    let chartData = weeklyEntries.enumerated().map { index, day in
                        DailyCalorie(
                            day: weekdaySymbols[index % 7],
                            total: day.reduce(0) { $0 + $1.calories }
                        )
                    }

                    Chart(chartData) {
                        BarMark(
                            x: .value("Day", $0.day),
                            y: .value("Calories", $0.total)
                        )
                        .foregroundStyle(.blue)
                    }
                    .frame(height: 200)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                } else {
                    Text("No data for the week yet.")
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding()
            .onAppear(perform: loadWeeklyEntries)
            .navigationTitle("Weekly Summary")
        }
    }

    func loadWeeklyEntries() {
        if let data = UserDefaults.standard.data(forKey: "weeklyFoodEntries"),
           let decoded = try? JSONDecoder().decode([[FoodEntry]].self, from: data) {
            weeklyEntries = decoded
        }
    }
}

// MARK: - Chart Model
struct DailyCalorie: Identifiable {
    var id = UUID()
    var day: String
    var total: Int
}
