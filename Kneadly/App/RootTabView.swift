import SwiftUI

struct RootTabView: View {
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            TodayView()
                .tabItem { Label("Today", systemImage: "sun.horizon") }
                .tag(0)
            BodyMapTab()
                .tabItem { Label("Body", systemImage: "figure.stand") }
                .tag(1)
            LearnView()
                .tabItem { Label("Learn", systemImage: "book") }
                .tag(2)
            MeView()
                .tabItem { Label("Me", systemImage: "person.crop.circle") }
                .tag(3)
        }
    }
}
