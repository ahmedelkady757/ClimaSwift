import SwiftUI

struct SavedLocationsView: View {
    @StateObject private var viewModel: SavedLocationsViewModel
    @StateObject private var themeEngine: DynamicThemeEngine
    @State private var isShowingSearch = false
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
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
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
                            .foregroundColor(.white.opacity(0.5))
                        Text("No saved locations yet.")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.savedLocations) { location in
                                SavedLocationCard(location: location) {
                                    Task { await viewModel.deleteLocation(byId: location.id) }
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
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
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
        }
    }
}

struct SavedLocationCard: View {
    let location: LocationDomainModel
    let onDelete: () -> Void
    let onTap: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(location.name)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(location.country)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red.opacity(0.9))
                    .padding(12)
                    .background(Color.white.opacity(0.15))
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
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}
