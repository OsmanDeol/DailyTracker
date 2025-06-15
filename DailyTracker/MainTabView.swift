import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Today", systemImage: "house")
                }

            WeeklySummaryView()
                .tabItem {
                    Label("Weekly", systemImage: "calendar")
                }
        }
    }
}

#Preview {
    MainTabView()
}
