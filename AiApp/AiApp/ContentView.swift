//
//  ContentView.swift
//  AiApp
//
//  Created by Nguyen, Sydney on 4/9/25.
//
//
//  ContentView.swift
//  Bridgit (all‑in‑one file)
//

//
//  ContentView.swift  –  Bridgit one‑file prototype
//

import SwiftUI

// MARK: ‑ Global App State
class AppSettings: ObservableObject {
    @Published var selectedLanguage = "English"
    @Published var hasSelectedLanguage = false
    @Published var isProfileComplete = false
}

// MARK: ‑ Root
struct ContentView: View {
    @EnvironmentObject var settings: AppSettings
    var body: some View {
        NavigationStack {
            if settings.hasSelectedLanguage {
                if settings.isProfileComplete {
                    HomePageView()
                } else {
                    PersonalizedQuestionsView()
                }
            } else {
                IntroScreen()
            }
        }
    }
}


// MARK: - Intro Screen
struct IntroScreen: View {
    @EnvironmentObject var settings: AppSettings

    private let languages: [String] = {
        let names = Locale.isoLanguageCodes
            .compactMap { Locale.current.localizedString(forLanguageCode: $0) }
        return Array(Set(names)).sorted()
    }()

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.teal, Color.blue]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("Bridgit")
                    .font(.system(size: 60, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)

                Text("Please select your language:")
                    .font(.headline)
                    .foregroundColor(.white)

                Picker("Language", selection: $settings.selectedLanguage) {
                    ForEach(languages, id: \.self) { Text($0) }
                }
                .pickerStyle(.menu)
                .padding(12)
                .background(Color.white.opacity(0.85))
                .cornerRadius(12)
                .shadow(radius: 5)

                Button {
                    settings.hasSelectedLanguage = true
                } label: {
                    Text("Continue")
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.9))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 10)
                }

                Spacer()
            }
            .padding()
        }
    }
}


// MARK: ‑ Question model
struct Question: Identifiable {
    let id = UUID(); var text:String; var options:[String]; var selectedOption:String? = nil
}

// MARK: ‑ Profile & Preferences (with About‑You)
struct PersonalizedQuestionsView: View {
    @EnvironmentObject var settings: AppSettings

    // About You
    @State private var name = ""
    @State private var yearsInUS = "Less than 1"
    @State private var selectedState = "Alabama"
    let states = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut",
                  "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa",
                  "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan",
                  "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
                  "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio",
                  "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
                  "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia",
                  "Wisconsin", "Wyoming"]

    // Preference questions
    @State private var questions: [Question] = [
        Question(text: "How do you prefer to receive help?",
                 options: ["Text explanations", "Visual guides", "One‑on‑one assistance"]),
        Question(text: "What is your comfort level with technology?",
                 options: ["Beginner", "Intermediate", "Advanced"]),
        Question(text: "How often do you need help understanding forms?",
                 options: ["Rarely", "Sometimes", "Often"])
    ]
    private var canContinue: Bool { !name.isEmpty }

    var body: some View {
        Form {
            // About You
            Section(header: Text("About You")) {
                TextField("Your name", text: $name)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .shadow(radius: 5)

                Picker("Time spent in the U.S.", selection: $yearsInUS) {
                    Text("Less than 1 year").tag("Less than 1")
                    Text("3 years or more").tag("3+")
                    Text("10 years or more").tag("10+")
                }

                Picker("Current State", selection: $selectedState) {
                    ForEach(states, id: \.self) { Text($0).tag($0) }
                }
            }

            // Preferences
            Section(header: Text("Your Preferences")) {
                ForEach($questions) { $q in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(q.text).font(.headline)
                        ForEach(q.options, id: \.self) { opt in
                            HStack {
                                Text(opt)
                                Spacer()
                                if q.selectedOption == opt { Image(systemName: "checkmark") }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { q.selectedOption = opt }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            // Next
            Section {
                NavigationLink {
                    AppPersonalizationView()
                } label: {
                    Text("Next")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(canContinue ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .disabled(!canContinue)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.teal.opacity(0.15))
        .navigationTitle("Profile & Preferences")
    }
}


// MARK: ‑ Pick up‑to‑3 Categories
struct AppPersonalizationView: View {
    let categories = ["Medical documents", "Taxes & money", "Communication",
                      "Job applications", "Transportation", "Banking",
                      "Housing", "Healthcare"]

    @EnvironmentObject var settings: AppSettings
    @Environment(\.presentationMode) private var presentationMode
    @State private var selected: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Choose up to 3 areas").font(.title2).bold()
            Text("You can change these anytime").font(.footnote).foregroundColor(.gray)

            List {
                ForEach(categories, id: \.self) { cat in
                    MultipleSelectionRow(title: cat,
                                         isSelected: selected.contains(cat)) {
                        if selected.contains(cat) {
                            selected.remove(cat)
                        } else if selected.count < 3 {
                            selected.insert(cat)
                        }
                    }
                }
            }

            Spacer()

            Button("Continue") {
                settings.isProfileComplete = true
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(selected.isEmpty)
            .frame(maxWidth: .infinity).padding()
            .background(selected.isEmpty ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .shadow(radius: 5)  // Added shadow to button
        }
        .padding(.top)
        .navigationBarBackButtonHidden(true)
    }
}

struct MultipleSelectionRow: View {
    let title: String; let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.7))
        .cornerRadius(10)
        .shadow(radius: 3)  // Added shadow to each row for depth
    }
}

// MARK: ‑ Home Page
struct HomePageView: View {
    let bridgeTopics = ["Medical Docs", "Taxes & Money", "Communication", "Job Applications",
                        "Transportation", "Banking", "Housing", "Healthcare"]
    let learnTopics = ["Grammar", "Vocabulary", "U.S. History", "Civics",
                        "Slang", "Pronunciation", "Culture", "Idioms"]

    @State private var searchText = ""; @State private var showSearch = false; @State private var showSide = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                // icon row
                HStack {
                    Button { withAnimation { showSide.toggle() } } label: {
                        Image(systemName: "person.circle.fill").resizable()
                            .frame(width: 28, height: 28).foregroundColor(.teal)
                    }
                    Spacer()
                    Button { withAnimation { showSearch.toggle() } } label: {
                        Image(systemName: "magnifyingglass.circle.fill").resizable()
                            .frame(width: 28, height: 28).foregroundColor(.orange)
                    }
                }.padding(.horizontal)

                SectionHeader(title: "What Are We Bridging Today?", color: .teal, fontSize: 24)

                if showSearch {
                    TextField("Search topics...", text: $searchText)
                        .padding(10).background(Color(.systemGray6))
                        .cornerRadius(10).padding(.horizontal)
                }
                TopicGrid(topics: filtered(bridgeTopics), boxColor: Color.orange.opacity(0.2))

                SectionHeader(title: "What Are We Learning Today?", color: .orange, fontSize: 24)
                TopicGrid(topics: learnTopics, boxColor: Color.teal.opacity(0.15))
                Spacer()
            }

            if showSide {
                SidebarView(showSidebar: $showSide)
                    .transition(.move(edge: .leading)).zIndex(1)
            }
        }
        .navigationBarHidden(true)
    }

    private func filtered(_ list: [String]) -> [String] {
        searchText.isEmpty ? list :
        list.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
}

// helpers
struct SectionHeader: View {
    let title: String; let color: Color; let fontSize: CGFloat

    var body: some View {
        Text(title)
            .font(.system(size: fontSize, weight: .bold))
            .padding(.horizontal).foregroundColor(color)
    }
}

struct TopicGrid: View {
    let topics: [String]; let boxColor: Color
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            ForEach(topics, id: \.self) { topic in
                NavigationLink { TopicDetailView(topic: topic) } label: {
                    Text(topic).fontWeight(.medium)
                        .frame(maxWidth: .infinity).padding()
                        .background(boxColor).cornerRadius(12)
                        .foregroundColor(.black)
                        .shadow(radius: 5) // Added shadow to each topic grid item
                }
            }
        }.padding(.horizontal)
    }
}

// MARK: ‑ Topic Detail
struct TopicDetailView: View {
    let topic: String
    let sub = ["Overview", "Step‑by‑Step", "FAQ"]
    var body: some View {
        List {
            ForEach(sub, id: \.self) { s in
                NavigationLink(s) { Text("\(s) content") }.underline()
            }
        }
        .navigationTitle(topic).navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: ‑ Sidebar
struct SidebarView: View {
    @Binding var showSidebar: Bool
    var body: some View {
        ZStack(alignment: .leading) {
            Color.black.opacity(0.3).ignoresSafeArea()
                .onTapGesture { withAnimation { showSidebar = false } }

            VStack(alignment: .leading, spacing: 20) {
                Text("👤 My Account").font(.title2).bold().foregroundColor(.teal)

                Labeled("Name: ", "John Doe")
                Labeled("Language: ", "English")
                Labeled("State: ", "Texas")

                Divider()

                NavigationLink("Bridging History") { Text("Bridging History") }
                NavigationLink("Learning History") { Text("Learning History") }
                NavigationLink("Account Status") { Text("Basic") }
                NavigationLink("Upgrade to Premium") { Text("Upgrade") }
                Spacer()
            }
            .padding().frame(width: 260).background(Color.white).shadow(radius: 8)
        }
    }
    @ViewBuilder private func Labeled(_ l: String, _ v: String) -> some View {
        HStack { Text(l).foregroundColor(.orange); Text(v).foregroundColor(.orange) }
    }
}

// MARK: ‑ Preview
#Preview {
    ContentView().environmentObject(AppSettings())
}
