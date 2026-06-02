import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Search Results")) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("London").font(.headline)
                            Text("United Kingdom").font(.subheadline).foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        dismiss()
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("New York").font(.headline)
                            Text("United States of America").font(.subheadline).foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        dismiss()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Search Location")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search for a city...")
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

#Preview {
    SearchView()
}
