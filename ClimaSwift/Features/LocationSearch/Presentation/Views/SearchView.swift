import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @StateObject private var themeEngine: DynamicThemeEngine
    @Environment(\.dismiss) private var dismiss

    init() {
        let container = DependencyContainer.shared.container
        _viewModel = StateObject(wrappedValue: container.resolve(SearchViewModel.self)!)
        _themeEngine = StateObject(wrappedValue: container.resolve(DynamicThemeEngine.self)!)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackgroundView(theme: themeEngine.currentTheme)
                
                List {
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: themeEngine.currentTheme.foregroundColor))
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(viewModel.searchResults) { location in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(location.name)
                                        .font(.headline)
                                        .foregroundColor(themeEngine.currentTheme.foregroundColor)
                                    Text("\(location.region), \(location.country)")
                                        .font(.subheadline)
                                        .foregroundColor(themeEngine.currentTheme.foregroundColor.opacity(0.7))
                                }
                                Spacer()
                                if location.isSaved {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                }
                            }
                            .padding(.vertical, 8)
                            .listRowBackground(themeEngine.currentTheme.cardBackground)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Task {
                                    await viewModel.saveLocation(location)
                                    dismiss()
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Search Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(themeEngine.currentTheme == .evening ? .dark : .light, for: .navigationBar)
            .searchable(text: $viewModel.searchQuery, prompt: "Search for a city...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(themeEngine.currentTheme.foregroundColor)
                }
            }
        }
    }
}
