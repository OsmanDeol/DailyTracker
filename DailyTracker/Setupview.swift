import SwiftUI

struct SetupView: View {
    @State private var calorieGoal = ""
    @State private var proteinGoal = ""
    @AppStorage("hasSetupGoals") private var hasSetupGoals = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Set Your Daily Goals")
                    .font(.title2)
                    .fontWeight(.bold)

                TextField("Daily Calorie Goal", text: $calorieGoal)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Daily Protein Goal (g)", text: $proteinGoal)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Save & Continue") {
                    if let cal = Int(calorieGoal), let prot = Int(proteinGoal) {
                        UserDefaults.standard.set(cal, forKey: "calorieGoal")
                        UserDefaults.standard.set(prot, forKey: "proteinGoal")
                        hasSetupGoals = true
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
            .navigationTitle("Welcome")
        }
    }
}
