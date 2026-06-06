//
//  DashboardView.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//

import SwiftUI
import SDWebImageSwiftUI

struct DashboardView: View {
    @StateObject private var themeEngine: DynamicThemeEngine
    @StateObject private var savedLocationsVM: SavedLocationsViewModel

    @State private var isShowingLocations = false
    @State private var selectedLocationId: UUID?
    /// Localtime strings keyed by location UUID — populated lazily as each page loads.
    @State private var localtimeCache: [UUID: String] = [:]
    /// Pending theme-update task — cancelled and replaced on every selectedLocationId change
    /// so that snap-back swipes (drag past 50% then reverse) never flash the wrong theme.
    @State private var themeUpdateTask: Task<Void, Never>? = nil

    private let defaultLat: Double = 30.5500
    private let defaultLon: Double = 30.9833

    init() {
        let container = DependencyContainer.shared.container
        _themeEngine = StateObject(wrappedValue: container.resolve(DynamicThemeEngine.self)!)
        _savedLocationsVM = StateObject(wrappedValue: container.resolve(SavedLocationsViewModel.self)!)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackgroundView(theme: themeEngine.currentTheme)

                if savedLocationsVM.savedLocations.isEmpty {
                    // Default location — no swipe, update theme directly when data loads
                    DashboardPageView(
                        lat: defaultLat,
                        lon: defaultLon,
                        locationName: "Menofia",
                        theme: themeEngine.currentTheme,
                        onLocaltimeLoaded: { localtime in
                            themeEngine.updateTheme(for: localtime)
                        }
                    )
                } else {
                    TabView(selection: $selectedLocationId) {
                        ForEach(savedLocationsVM.savedLocations) { location in
                            DashboardPageView(
                                lat: location.latitude,
                                lon: location.longitude,
                                locationName: location.name,
                                theme: themeEngine.currentTheme,
                                onLocaltimeLoaded: { localtime in
                                    // Cache the city's localtime when its data first arrives.
                                    localtimeCache[location.id] = localtime
                                    // Only apply theme if this is the committed page AND no
                                    // debounced task is already pending for a different page.
                                    if selectedLocationId == location.id {
                                        themeUpdateTask?.cancel()
                                        themeUpdateTask = Task { @MainActor in
                                            try? await Task.sleep(nanoseconds: 350_000_000)
                                            guard !Task.isCancelled else { return }
                                            // Re-check after the delay — user might have swiped away
                                            if selectedLocationId == location.id {
                                                themeEngine.updateTheme(for: localtime)
                                            }
                                        }
                                    }
                                }
                            )
                            .tag(location.id as UUID?)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    // onChange fires when the drag crosses the 50% threshold — NOT on finger lift.
                    // Using a debounced task ensures snap-backs (drag past 50% → reverse) cancel
                    // the in-flight update so only the truly committed page applies its theme.
                    .onChange(of: selectedLocationId) { _, newId in
                        themeUpdateTask?.cancel()
                        themeUpdateTask = Task { @MainActor in
                            // Wait long enough for a snap-back swipe to complete (~300 ms).
                            try? await Task.sleep(nanoseconds: 350_000_000)
                            guard !Task.isCancelled, let newId else { return }
                            if let cachedLocaltime = localtimeCache[newId] {
                                themeEngine.updateTheme(for: cachedLocaltime)
                            }
                            // If no cache yet, the page's onLocaltimeLoaded callback will apply
                            // the theme once the fetch completes (also guarded by selectedLocationId).
                        }
                    }
                }
            }
            .task {
                await savedLocationsVM.fetchSavedLocations()
                if selectedLocationId == nil {
                    selectedLocationId = savedLocationsVM.savedLocations.first?.id
                }
            }
            .onReceive(savedLocationsVM.$savedLocations) { locations in
                if let current = selectedLocationId, !locations.contains(where: { $0.id == current }) {
                    selectedLocationId = locations.first?.id
                } else if selectedLocationId == nil {
                    selectedLocationId = locations.first?.id
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isShowingLocations = true
                    } label: {
                        Image(systemName: "list.bullet")
                            .foregroundColor(themeEngine.currentTheme.foregroundColor)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if !savedLocationsVM.savedLocations.isEmpty, let currentId = selectedLocationId {
                        Button {
                            Task {
                                await savedLocationsVM.deleteLocation(byId: currentId)
                            }
                        } label: {
                            Image(systemName: "star.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 20))
                        }
                    } else {
                        Button {
                            // No-op for default location
                        } label: {
                            Image(systemName: "star")
                                .foregroundColor(themeEngine.currentTheme.foregroundColor.opacity(0.5))
                        }
                        .disabled(true)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $isShowingLocations, onDismiss: {
                Task {
                    await savedLocationsVM.fetchSavedLocations()
                }
            }) {
                SavedLocationsView { selectedLat, selectedLon in
                    if let location = savedLocationsVM.savedLocations.first(where: { abs($0.latitude - selectedLat) < 0.01 && abs($0.longitude - selectedLon) < 0.01 }) {
                        selectedLocationId = location.id
                    }
                }
            }
        }
    }
}

struct DashboardPageView: View {
    @StateObject private var viewModel: DashboardViewModel
    let lat: Double
    let lon: Double
    let locationName: String?
    let theme: ThemeType
    /// Called exactly once when weather data first loads — passes the city's localtime string.
    /// The parent decides when/whether to act on it (e.g. only on committed tab selection).
    let onLocaltimeLoaded: (String) -> Void

    init(lat: Double, lon: Double, locationName: String?, theme: ThemeType, onLocaltimeLoaded: @escaping (String) -> Void) {
        self.lat = lat
        self.lon = lon
        self.locationName = locationName
        self.theme = theme
        self.onLocaltimeLoaded = onLocaltimeLoaded
        _viewModel = StateObject(wrappedValue: DependencyContainer.shared.container.resolve(DashboardViewModel.self)!)
    }

    var body: some View {
        Group {
            switch viewModel.loadingState {
            case .idle, .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: theme.foregroundColor))
                    .scaleEffect(1.5)
            case .failure(let message):
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                    Text(message)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .foregroundColor(theme.foregroundColor)
            case .success(let weather):
                ScrollView(showsIndicators: false) {
                    WeatherContentView(
                        weather: weather,
                        forecast: viewModel.forecast,
                        theme: theme,
                        lat: lat,
                        lon: lon,
                        locationName: locationName
                    )
                    .padding(.bottom, 40) // Space for page indicator
                }
            }
        }
        .task(id: "\(lat)-\(lon)") {
            await viewModel.fetchWeather(lat: lat, lon: lon)
            // Report the city's localtime to the parent via callback.
            // The parent is responsible for deciding when to apply the theme change.
            if case .success(let weather) = viewModel.loadingState {
                onLocaltimeLoaded(weather.localtime)
            }
        }
    }
}

private struct WeatherContentView: View {
    let weather: WeatherDomainModel
    let forecast: [ForecastDayModel]
    let theme: ThemeType
    let lat: Double
    let lon: Double
    let locationName: String?

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text(locationName ?? weather.locationName)
                    .font(.system(size: 32, weight: .medium))

                Text("\(Int(forecast.first?.avgTemp ?? weather.temperature))°")
                    .font(.system(size: 72, weight: .thin))

                Text(weather.conditionText)
                    .font(.title3)

                Text("H:\(Int(weather.maxTemp))° L:\(Int(weather.minTemp))°")
                    .font(.headline)

                WebImage(url: URL(string: weather.conditionIconURL)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Image(systemName: "cloud.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(theme.foregroundColor.opacity(0.4))
                }
                .frame(width: 80, height: 80)
            }
            .foregroundColor(theme.foregroundColor)
            .padding(.top, 40)

            Spacer()

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("3-DAY FORECAST")
                        .font(.caption)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal)
                .foregroundColor(theme.foregroundColor.opacity(0.7))

                Divider()
                    .background(theme.foregroundColor.opacity(0.3))

                ForEach(forecast) { day in
                    NavigationLink(destination: DailyForecastView(day: day, theme: theme)) {
                        ForecastRowView(day: day, theme: theme)
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            .foregroundColor(theme.foregroundColor)
            .padding(.horizontal)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                MetricTile(title: "VISIBILITY", value: "\(Int(weather.visibility)) km", theme: theme)
                MetricTile(title: "HUMIDITY", value: "\(weather.humidity)%", theme: theme)
                MetricTile(title: "FEELS LIKE", value: "\(Int(weather.feelsLike))°", theme: theme)
                MetricTile(title: "PRESSURE", value: "\(Int(weather.pressure)) mb", theme: theme)
            }
            .padding()
        }
    }
}

private struct ForecastRowView: View {
    let day: ForecastDayModel
    let theme: ThemeType

    var body: some View {
        HStack {
            Text(formattedDay)
                .frame(width: 80, alignment: .leading)

            Spacer()

            WebImage(url: URL(string: day.iconURL)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Image(systemName: "cloud.fill")
                    .foregroundColor(theme.foregroundColor.opacity(0.4))
            }
            .frame(width: 44, height: 44)

            Spacer()

            Text("\(Int(day.minTemp))° - \(Int(day.maxTemp))°")
        }
        .padding(.horizontal)
    }

    private var formattedDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: day.date) else { return day.date }
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        else if calendar.isDateInTomorrow(date) { return "Tomorrow" }
        else {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            return dayFormatter.string(from: date)
        }
    }
}

private struct MetricTile: View {
    let title: String
    let value: String
    let theme: ThemeType

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(theme.foregroundColor.opacity(0.6))

            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(theme.foregroundColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}
