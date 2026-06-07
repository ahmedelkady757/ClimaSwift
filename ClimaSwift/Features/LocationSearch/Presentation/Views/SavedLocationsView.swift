import SwiftUI

struct SavedLocationsView: View {
    @StateObject private var viewModel: SavedLocationsViewModel
    @StateObject private var themeEngine: DynamicThemeEngine
    @State private var isShowingSearch = false
    @State private var locationToDelete: LocationDomainModel? = nil
    @State private var isShowingDeleteAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var onLocationSelected: ((Double, Double) -> Void)?

    init(onLocationSelected: ((Double, Double) -> Void)? = nil) {
        self.onLocationSelected = onLocationSelected
        let container = DependencyContainer.shared.container
        _viewModel = StateObject(wrappedValue: container.resolve(SavedLocationsViewModel.self)!)
        _themeEngine = StateObject(wrappedValue: container.resolve(DynamicThemeEngine.self)!)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackgroundView(theme: themeEngine.currentTheme)
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: themeEngine.currentTheme.foregroundColor))
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                } else if viewModel.savedLocations.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "globe.americas")
                            .font(.system(size: 60))
                            .foregroundColor(themeEngine.currentTheme.foregroundColor.opacity(0.5))
                        Text("No saved locations yet.")
                            .font(.title3)
                            .foregroundColor(themeEngine.currentTheme.foregroundColor.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.savedLocations) { location in
                                SavedLocationCard(location: location, theme: themeEngine.currentTheme) {
                                    locationToDelete = location
                                    isShowingDeleteAlert = true
                                } onTap: {
                                    onLocationSelected?(location.latitude, location.longitude)
                                    dismiss()
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Saved Locations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(themeEngine.currentTheme == .evening ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .fontWeight(.semibold)
                            .foregroundColor(themeEngine.currentTheme.foregroundColor)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeEngine.currentTheme.foregroundColor)
                }
            }
            .sheet(isPresented: $isShowingSearch, onDismiss: {
                Task {
                    await viewModel.fetchSavedLocations()
                }
            }) {
                SearchView()
            }
            .task {
                await viewModel.fetchSavedLocations()
            }
            .alert("Remove City", isPresented: $isShowingDeleteAlert, presenting: locationToDelete) { location in
                Button(role: .destructive) {
                    Task { await viewModel.deleteLocation(byId: location.id) }
                } label: {
                    Text("Delete")
                }
                Button("Cancel", role: .cancel) { }
            } message: { location in
                Text("Are you sure you want to remove \(location.name) from your favorites?")
            }
        }
    }
}

struct SavedLocationCard: View {
    let location: LocationDomainModel
    let theme: ThemeType
    let onDelete: () -> Void
    let onTap: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(location.name)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(theme.foregroundColor)
                Text(location.country)
                    .font(.subheadline)
                    .foregroundColor(theme.foregroundColor.opacity(0.7))
            }
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red.opacity(0.9))
                    .padding(12)
                    .background(Color.white.opacity(theme == .morning ? 0.3 : 0.15))
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle()) // Prevent whole card from tapping when deleting
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(theme.foregroundColor.opacity(0.2), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}
