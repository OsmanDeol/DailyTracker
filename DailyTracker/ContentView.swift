import SwiftUI

// MARK: - Data Model
struct FoodEntry: Identifiable, Codable {
    var id = UUID()
    var name: String
    var calories: Int
    var protein: Int
}

// MARK: - Main View
struct ContentView: View {
    @State private var name = ""
    @State private var caloriesText = ""
    @State private var proteinText = ""
    @State private var entries: [FoodEntry] = []

    let calorieGoal = UserDefaults.standard.integer(forKey: "calorieGoal")
    let proteinGoal = UserDefaults.standard.integer(forKey: "proteinGoal")

    var totalCalories: Int {
        entries.reduce(0) { $0 + $1.calories }
    }

    var totalProtein: Int {
        entries.reduce(0) { $0 + $1.protein }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Add Food Entry")
                            .font(.headline)

                        TextField("Food Name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextField("Calories", text: $caloriesText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextField("Protein (g)", text: $proteinText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button(action: addEntry) {
                            Text("Add Entry")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .shadow(radius: 5)
                    .padding(.horizontal)

                    // Entries List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Entries")
                            .font(.headline)

                        ForEach(entries) { entry in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(entry.name)
                                        .font(.headline)
                                    Text("\(entry.calories) cal • \(entry.protein)g protein")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button(action: {
                                    deleteEntry(id: entry.id)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                        }
                    }
                    .padding(.horizontal)

                    // Reset Button
                    Button(action: resetDay) {
                        Text("Reset Today")
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    // Totals
                    VStack(spacing: 8) {
                        HStack {
                            Text("Calories:")
                            Spacer()
                            Text("\(totalCalories) / \(calorieGoal)")
                                .foregroundColor(.blue)
                        }
                        HStack {
                            Text("Remaining:")
                            Spacer()
                            Text("\(max(calorieGoal - totalCalories, 0)) cal")
                                .foregroundColor(.green)
                        }

                        Divider()

                        HStack {
                            Text("Protein:")
                            Spacer()
                            Text("\(totalProtein)g / \(proteinGoal)g")
                                .foregroundColor(.blue)
                        }
                        HStack {
                            Text("Remaining:")
                            Spacer()
                            Text("\(max(proteinGoal - totalProtein, 0))g")
                                .foregroundColor(.green)
                        }
                    }
                    .font(.subheadline)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 3)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Food Tracker")
            .onAppear(perform: loadEntries)
        }
    }

    // MARK: - Logic

    func addEntry() {
        guard let cal = Int(caloriesText),
              let prot = Int(proteinText),
              !name.isEmpty else { return }

        let newEntry = FoodEntry(name: name, calories: cal, protein: prot)
        entries.append(newEntry)
        name = ""
        caloriesText = ""
        proteinText = ""
        saveEntries()
        UserDefaults.standard.set(Date(), forKey: "lastOpenedDate")
    }

    func deleteEntry(id: UUID) {
        entries.removeAll { $0.id == id }
        saveEntries()
    }

    func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "foodEntries")
        }

        var weekly: [[FoodEntry]] = (UserDefaults.standard.data(forKey: "weeklyFoodEntries")
            .flatMap { try? JSONDecoder().decode([[FoodEntry]].self, from: $0) }) ?? []

        let today = Calendar.current.startOfDay(for: Date())

        if weekly.count == 0 || Calendar.current.isDate(today, inSameDayAs: Date()) == false {
            if weekly.count == 7 { weekly.removeFirst() }
            weekly.append(entries)
            if let encodedWeekly = try? JSONEncoder().encode(weekly) {
                UserDefaults.standard.set(encodedWeekly, forKey: "weeklyFoodEntries")
            }
        }
    }

    func loadEntries() {
        let lastOpened = UserDefaults.standard.object(forKey: "lastOpenedDate") as? Date ?? Date()
        let today = Calendar.current.startOfDay(for: Date())
        let lastDay = Calendar.current.startOfDay(for: lastOpened)

        if today != lastDay {
            entries = []
            UserDefaults.standard.set(today, forKey: "lastOpenedDate")
            return
        }

        if let data = UserDefaults.standard.data(forKey: "foodEntries"),
           let decoded = try? JSONDecoder().decode([FoodEntry].self, from: data) {
            entries = decoded
        }
    }

    func resetDay() {
        // Clear today's entries
        entries = []
        UserDefaults.standard.removeObject(forKey: "foodEntries")
        UserDefaults.standard.set(Date(), forKey: "lastOpenedDate")

        
        var weekly: [[FoodEntry]] = (UserDefaults.standard.data(forKey: "weeklyFoodEntries")
            .flatMap { try? JSONDecoder().decode([[FoodEntry]].self, from: $0) }) ?? []

        if !weekly.isEmpty {
            weekly.removeLast()
            if let encoded = try? JSONEncoder().encode(weekly) {
                UserDefaults.standard.set(encoded, forKey: "weeklyFoodEntries")
            }
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
