import SwiftUI

struct SavedLocationsView: View {
    @StateObject private var viewModel: SavedLocationsViewModel
    @State private var isShowingSearch = false
    @Environment(\.dismiss) private var dismiss

    init() {
        let container = DependencyContainer.shared.container
        _viewModel = StateObject(wrappedValue: container.resolve(SavedLocationsViewModel.self)!)
    }

    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else if viewModel.savedLocations.isEmpty {
                    Text("No saved locations yet.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(viewModel.savedLocations) { location in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(location.name).font(.title3).bold()
                                Text(location.country).font(.subheadline).foregroundColor(.secondary)
                            }
                            Spacer()
                            // In a real app, we'd fetch the current temp here.
                            // For now, we just display the location name.
                        }
                        .padding(.vertical, 8)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task {
                                    await viewModel.deleteLocation(byId: location.id)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Routing to dashboard could happen via Environment or Coordinator pattern
                            dismiss()
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Saved Locations")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .fontWeight(.semibold)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isShowingSearch) {
                SearchView()
            }
            .task {
                await viewModel.fetchSavedLocations()
            }
        }
    }
}
