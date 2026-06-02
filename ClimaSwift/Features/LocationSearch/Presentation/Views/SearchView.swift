import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @Environment(\.dismiss) private var dismiss

    init() {
        let container = DependencyContainer.shared.container
        _viewModel = StateObject(wrappedValue: container.resolve(SearchViewModel.self)!)
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
                } else {
                    ForEach(viewModel.searchResults) { location in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(location.name).font(.headline)
                                Text("\(location.region), \(location.country)").font(.subheadline).foregroundColor(.secondary)
                            }
                            Spacer()
                            if location.isSaved {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
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
            .listStyle(.insetGrouped)
            .navigationTitle("Search Location")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchQuery, prompt: "Search for a city...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
