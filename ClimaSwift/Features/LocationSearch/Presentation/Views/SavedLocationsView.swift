import SwiftUI

struct SavedLocationsView: View {
    @State private var isShowingSearch = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Cairo").font(.title3).bold()
                        Text("Egypt").font(.subheadline).foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("35°").font(.system(size: 36, weight: .semibold))
                }
                .padding(.vertical, 8)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Tokyo").font(.title3).bold()
                        Text("Japan").font(.subheadline).foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("22°").font(.system(size: 36, weight: .semibold))
                }
                .padding(.vertical, 8)
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
        }
    }
}

#Preview {
    SavedLocationsView()
}
