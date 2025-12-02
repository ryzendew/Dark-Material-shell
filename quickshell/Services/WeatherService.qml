pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

Singleton {
    id: root

    property int refCount: 0
    onRefCountChanged: {
        if (refCount === 1 && !weather.available && SettingsData.weatherEnabled) {
            fetchWeather()
        }
    }

    property var weather: ({
                               "available": false,
                               "loading": true,
                               "temp": 0,
                               "tempF": 0,
                               "feelsLike": 0,
                               "feelsLikeF": 0,
                               "city": "",
                               "country": "",
                               "wCode": 0,
                               "humidity": 0,
                               "wind": "",
                               "sunrise": "06:00",
                               "sunset": "18:00",
                               "uv": 0,
                               "pressure": 0,
                               "precipitationProbability": 0,
                               "isDay": true,
                               "forecast": []
                           })

    property var location: null
    property int updateInterval: 900000 // 15 minutes
    property int retryAttempts: 0
    property int maxRetryAttempts: 3
    property int retryDelay: 30000
    property int lastFetchTime: 0
    property int minFetchInterval: 30000
    property int persistentRetryCount: 0

    readonly property var lowPriorityCmd: ["nice", "-n", "19", "ionice", "-c3"]
    readonly property var curlBaseCmd: ["curl", "-sS", "--fail", "--connect-timeout", "3", "--max-time", "6", "--limit-rate", "100k", "--compressed"]

    property var weatherIcons: ({
                                    "0": "clear_day",
                                    "1": "clear_day",
                                    "2": "partly_cloudy_day",
                                    "3": "cloud",
                                    "45": "foggy",
                                    "48": "foggy",
                                    "51": "rainy",
                                    "53": "rainy",
                                    "55": "rainy",
                                    "56": "rainy",
                                    "57": "rainy",
                                    "61": "rainy",
                                    "63": "rainy",
                                    "65": "rainy",
                                    "66": "rainy",
                                    "67": "rainy",
                                    "71": "cloudy_snowing",
                                    "73": "cloudy_snowing",
                                    "75": "snowing_heavy",
                                    "77": "cloudy_snowing",
                                    "80": "rainy",
                                    "81": "rainy",
                                    "82": "rainy",
                                    "85": "cloudy_snowing",
                                    "86": "snowing_heavy",
                                    "95": "thunderstorm",
                                    "96": "thunderstorm",
                                    "99": "thunderstorm"
                                })

    property var nightWeatherIcons: ({
                                        "0": "clear_night",
                                        "1": "clear_night",
                                        "2": "partly_cloudy_night",
                                        "3": "cloud",
                                        "45": "foggy",
                                        "48": "foggy",
                                        "51": "rainy",
                                        "53": "rainy",
                                        "55": "rainy",
                                        "56": "rainy",
                                        "57": "rainy",
                                        "61": "rainy",
                                        "63": "rainy",
                                        "65": "rainy",
                                        "66": "rainy",
                                        "67": "rainy",
                                        "71": "cloudy_snowing",
                                        "73": "cloudy_snowing",
                                        "75": "snowing_heavy",
                                        "77": "cloudy_snowing",
                                        "80": "rainy",
                                        "81": "rainy",
                                        "82": "rainy",
                                        "85": "cloudy_snowing",
                                        "86": "snowing_heavy",
                                        "95": "thunderstorm",
                                        "96": "thunderstorm",
                                        "99": "thunderstorm"
                                    })

    function getWeatherIcon(code, isDay) {
        if (typeof isDay === "undefined") {
            isDay = weather.isDay
        }
        const iconMap = isDay ? weatherIcons : nightWeatherIcons
        return iconMap[String(code)] || "cloud"
    }

    function getWeatherCondition(code) {
        const conditions = {
            "0": "Clear",
            "1": "Clear", 
            "2": "Partly cloudy",
            "3": "Overcast",
            "45": "Fog",
            "48": "Fog",
            "51": "Drizzle",
            "53": "Drizzle", 
            "55": "Drizzle",
            "56": "Freezing drizzle",
            "57": "Freezing drizzle",
            "61": "Light rain",
            "63": "Rain",
            "65": "Heavy rain", 
            "66": "Light rain",
            "67": "Heavy rain",
            "71": "Light snow",
            "73": "Snow",
            "75": "Heavy snow",
            "77": "Snow",
            "80": "Light rain",
            "81": "Rain",
            "82": "Heavy rain",
            "85": "Light snow showers",
            "86": "Heavy snow showers",
            "95": "Thunderstorm",
            "96": "Thunderstorm with hail",
            "99": "Thunderstorm with hail"
        }
        return conditions[String(code)] || "Unknown"
    }

    function formatTime(isoString) {
        if (!isoString) return "--"

        try {
            const date = new Date(isoString)
            if (SettingsData.use24HourClock) {
                // Force 24-hour format with AM/PM
                const hours = date.getHours()
                const minutes = date.getMinutes()
                const period = hours >= 12 ? "PM" : "AM"
                return String(hours).padStart(2, '0') + ":" + String(minutes).padStart(2, '0') + " " + period
            } else {
                const formatted = date.toLocaleTimeString(Qt.locale(), "h:mm AP")
                return formatted.replace(/\./g, "").trim()
            }
        } catch (e) {
            return "--"
        }
    }

    function formatForecastDay(isoString, index) {
        if (!isoString) return "--"

        try {
            const date = new Date(isoString)
            if (index === 0) return I18n.tr("Today")
            if (index === 1) return I18n.tr("Tomorrow")

            const locale = Qt.locale()
            return locale.dayName(date.getDay(), Locale.ShortFormat)
        } catch (e) {
            return "--"
        }
    }

    function getWeatherApiUrl() {
        if (!location) {
            return null
        }

        const params = [
            "latitude=" + location.latitude,
            "longitude=" + location.longitude,
            "current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,surface_pressure,wind_speed_10m",
            "daily=sunrise,sunset,temperature_2m_max,temperature_2m_min,weather_code,precipitation_probability_max",
            "timezone=auto",
            "forecast_days=7"
        ]

        const url = "https://api.open-meteo.com/v1/forecast?" + params.join('&')
        return url
    }

    function getGeocodingUrl(query) {
        return "https://geocoding-api.open-meteo.com/v1/search?name=" + encodeURIComponent(query) + "&count=1&language=en&format=json"
    }

    function addRef() {
        refCount++

        if (refCount === 1 && !weather.available && SettingsData.weatherEnabled) {
            fetchWeather()
        }
    }

    function removeRef() {
        refCount = Math.max(0, refCount - 1)
    }

    function updateLocation() {
        
        if (SettingsData.useAutoLocation) {
            getLocationFromIP()
        } else {
            const coords = SettingsData.weatherCoordinates
            if (coords) {
                const parts = coords.split(",")
                if (parts.length === 2) {
                    const lat = parseFloat(parts[0])
                    const lon = parseFloat(parts[1])
                    if (!isNaN(lat) && !isNaN(lon)) {
                        getLocationFromCoords(lat, lon)
                        return
                    } else {
                    }
                } else {
                }
            } else {
            }

            const cityName = SettingsData.weatherLocation
            if (cityName) {
                getLocationFromCity(cityName)
            } else {
            }
        }
    }

    function getLocationFromCoords(lat, lon) {
        


        root.location = {
            city: "Loading...",
            country: "",
            latitude: lat,
            longitude: lon
        }
        

        fetchWeather()
        

        const url = "https://nominatim.openstreetmap.org/reverse?lat=" + lat + "&lon=" + lon + "&format=json&addressdetails=1&accept-language=en"
        reverseGeocodeFetcher.command = lowPriorityCmd.concat(curlBaseCmd).concat(["-H", "User-Agent: DankMaterialShell Weather Widget", url])
        reverseGeocodeFetcher.running = true
    }

    function getLocationFromCity(city) {
        const url = getGeocodingUrl(city)
        cityGeocodeFetcher.command = lowPriorityCmd.concat(curlBaseCmd).concat([url])
        cityGeocodeFetcher.running = true
    }

    function getLocationFromIP() {
        ipLocationFetcher.running = true
    }

    function fetchWeather() {
        
        if (root.refCount === 0 || !SettingsData.weatherEnabled) {
            return
        }

        if (!location) {
            updateLocation()
            return
        }

        if (weatherFetcher.running) {
            return
        }

        const now = Date.now()
        const timeSinceLastFetch = now - root.lastFetchTime
        if (timeSinceLastFetch < root.minFetchInterval) {
            return
        }

        const apiUrl = getWeatherApiUrl()
        if (!apiUrl) {
            return
        }

        root.lastFetchTime = now
        root.weather.loading = true
        


        weatherFetcher.command = ["curl", "-sS", "--fail", "--connect-timeout", "5", "--max-time", "10", "--compressed", apiUrl]
        

        weatherFetcher.running = true
    }

    function forceRefresh() {
        root.lastFetchTime = 0 // Reset throttle
        fetchWeather()
    }

    function nextInterval() {
        const jitter = Math.floor(Math.random() * 15000) - 7500
        return Math.max(60000, root.updateInterval + jitter)
    }

    function handleWeatherSuccess() {
        root.retryAttempts = 0
        root.persistentRetryCount = 0
        if (persistentRetryTimer.running) {
            persistentRetryTimer.stop()
        }
        if (updateTimer.interval !== root.updateInterval) {
            updateTimer.interval = root.updateInterval
        }
    }

    function handleWeatherFailure() {
        root.retryAttempts++
        
        if (root.retryAttempts < root.maxRetryAttempts) {
            retryTimer.start()
        } else {
            root.retryAttempts = 0
            if (!root.weather.available) {
                root.weather.loading = false
            }
            const backoffDelay = Math.min(60000 * Math.pow(2, persistentRetryCount), 300000)
            persistentRetryCount++
            persistentRetryTimer.interval = backoffDelay
            persistentRetryTimer.start()
        }
    }

    Process {
        id: ipLocationFetcher

        command: lowPriorityCmd.concat(curlBaseCmd).concat(["http://ip-api.com/json/?fields=status,message,lat,lon,city,regionName,country,countryCode,zip,timezone"])
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const raw = text.trim()
                
                if (!raw || raw[0] !== "{") {
                    root.handleWeatherFailure()
                    return
                }

                try {
                    const data = JSON.parse(raw)

                    if (data.status === "fail") {
                        const errorMsg = "IP location lookup failed: " + (data.message || "Unknown error")
                        throw new Error(errorMsg)
                    }

                    const lat = parseFloat(data.lat)
                    const lon = parseFloat(data.lon)
                    const city = data.city || ""
                    const region = data.regionName || ""
                    const country = data.country || ""



                    if (isNaN(lat) || isNaN(lon) || lat < -90 || lat > 90 || lon < -180 || lon > 180) {
                        throw new Error("Invalid coordinates from IP location")
                    }


                    let locationName = city
                    if (region && region !== city) {
                        locationName += ", " + region
                    }
                    if (country) {
                        locationName += ", " + country
                    }
                    if (!locationName) {
                        locationName = "Unknown Location"
                    }


                    const coordsString = lat.toFixed(6) + "," + lon.toFixed(6)


                    SettingsData.weatherCoordinates = coordsString
                    SettingsData.weatherLocation = locationName
                    SettingsData.saveSettings()


                    root.location = {
                        city: city || locationName,
                        country: country || "",
                        latitude: lat,
                        longitude: lon
                    }
                    fetchWeather()
                } catch (e) {
                    root.handleWeatherFailure()
                }
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.handleWeatherFailure()
            }
        }
    }

    Process {
        id: reverseGeocodeFetcher
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const raw = text.trim()
                
                if (!raw || raw[0] !== "{") {


                    if (root.location) {
                        root.location.city = root.location.city === "Loading..." ? "Unknown" : root.location.city
                    }
                    return
                }

                try {
                    const data = JSON.parse(raw)
                    const address = data.address || {}



                    if (root.location) {
                        const oldCity = root.location.city
                        root.location.city = address.hamlet || address.city || address.town || address.village || "Unknown"
                        root.location.country = address.country || root.location.country || "Unknown"
                        

                        const lat = parseFloat(data.lat)
                        const lon = parseFloat(data.lon)
                        if (!isNaN(lat) && !isNaN(lon)) {
                            root.location.latitude = lat
                            root.location.longitude = lon
                        } else {
                        }
                        

                        if (root.weather && root.weather.available) {
                            const updatedWeather = Object.assign({}, root.weather, {
                                "city": root.location.city,
                                "country": root.location.country
                            })
                            root.weather = updatedWeather
                        }
                    } else {

                        root.location = {
                            city: address.hamlet || address.city || address.town || address.village || "Unknown",
                            country: address.country || "Unknown",
                            latitude: parseFloat(data.lat),
                            longitude: parseFloat(data.lon)
                        }
                        fetchWeather()
                    }
                } catch (e) {

                    if (root.location) {
                        root.location.city = root.location.city === "Loading..." ? "Unknown" : root.location.city
                    }
                }
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0) {


                if (root.location && root.location.city === "Loading...") {
                    root.location.city = "Unknown"
                }
            }
        }
    }

    Process {
        id: cityGeocodeFetcher
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const raw = text.trim()
                
                if (!raw || raw[0] !== "{") {
                    root.handleWeatherFailure()
                    return
                }

                try {
                    const data = JSON.parse(raw)
                    const results = data.results

                    if (!results || results.length === 0) {
                        throw new Error("No results found")
                    }

                    const result = results[0]

                    root.location = {
                        city: result.name,
                        country: result.country,
                        latitude: result.latitude,
                        longitude: result.longitude
                    }
                    fetchWeather()
                } catch (e) {
                    root.handleWeatherFailure()
                }
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.handleWeatherFailure()
            }
        }
    }

    Process {
        id: weatherFetcher
        running: false
        
        onRunningChanged: {
        }

        stdout: StdioCollector {
            onStreamFinished: {
                const raw = text.trim()
                
                if (!raw || raw[0] !== "{") {
                    root.handleWeatherFailure()
                    return
                }

                try {
                    const data = JSON.parse(raw)

                    if (!data.current || !data.daily) {
                        throw new Error("Required weather data fields missing")
                    }

                    const current = data.current
                    const daily = data.daily
                    const currentUnits = data.current_units || {}
                    

                    const tempC = current.temperature_2m || 0
                    const tempF = (tempC * 9/5 + 32)
                    const feelsLikeC = current.apparent_temperature || tempC
                    const feelsLikeF = (feelsLikeC * 9/5 + 32)

                    const forecast = []
                    if (daily.time && daily.time.length > 0) {
                        for (let i = 0; i < Math.min(daily.time.length, 7); i++) {
                            const tempMinC = daily.temperature_2m_min?.[i] || 0
                            const tempMaxC = daily.temperature_2m_max?.[i] || 0
                            const tempMinF = (tempMinC * 9/5 + 32)
                            const tempMaxF = (tempMaxC * 9/5 + 32)

                            forecast.push({
                                "day": formatForecastDay(daily.time[i], i),
                                "wCode": daily.weather_code?.[i] || 0,
                                "tempMin": Math.round(tempMinC),
                                "tempMax": Math.round(tempMaxC),
                                "tempMinF": Math.round(tempMinF),
                                "tempMaxF": Math.round(tempMaxF),
                                "precipitationProbability": Math.round(daily.precipitation_probability_max?.[i] || 0),
                                "sunrise": daily.sunrise?.[i] ? formatTime(daily.sunrise[i]) : "",
                                "sunset": daily.sunset?.[i] ? formatTime(daily.sunset[i]) : ""
                            })
                        }
                    } else {
                    }


                    const newWeather = {
                        "available": true,
                        "loading": false,
                        "temp": Math.round(tempC),
                        "tempF": Math.round(tempF),
                        "feelsLike": Math.round(feelsLikeC),
                        "feelsLikeF": Math.round(feelsLikeF),
                        "city": root.location?.city || "Unknown",
                        "country": root.location?.country || "Unknown",
                        "wCode": current.weather_code || 0,
                        "humidity": Math.round(current.relative_humidity_2m || 0),
                        "wind": Math.round(current.wind_speed_10m || 0) + " " + (currentUnits.wind_speed_10m || 'm/s'),
                        "sunrise": formatTime(daily.sunrise?.[0]) || "06:00",
                        "sunset": formatTime(daily.sunset?.[0]) || "18:00",
                        "uv": 0,
                        "pressure": Math.round(current.surface_pressure || 0),
                        "precipitationProbability": Math.round(daily.precipitation_probability_max?.[0] || 0),
                        "isDay": Boolean(current.is_day),
                        "forecast": forecast
                    }

                    root.weather = newWeather

                    Qt.callLater(() => {

                        const _ = root.weather.available && root.weather.temp
                    })

                    const displayTemp = SettingsData.useFahrenheit ? root.weather.tempF : root.weather.temp
                    const unit = SettingsData.useFahrenheit ? "°F" : "°C"

                    root.handleWeatherSuccess()
                } catch (e) {
                    root.handleWeatherFailure()
                }
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.handleWeatherFailure()
            } else {
            }
        }
    }

    Timer {
        id: updateTimer
        interval: nextInterval()
        running: root.refCount > 0 && SettingsData.weatherEnabled
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.fetchWeather()
            interval = nextInterval()
        }
    }

    Timer {
        id: retryTimer
        interval: root.retryDelay
        running: false
        repeat: false
        onTriggered: {
            root.fetchWeather()
        }
    }

    Timer {
        id: persistentRetryTimer
        interval: 60000
        running: false
        repeat: false
        onTriggered: {
            if (!root.weather.available) {
                root.weather.loading = true
            }
            root.fetchWeather()
        }
    }

    Component.onCompleted: {

        SettingsData.weatherCoordinatesChanged.connect(() => {
                                                           root.location = null
                                                           root.weather = {
                                                               "available": false,
                                                               "loading": true,
                                                               "temp": 0,
                                                               "tempF": 0,
                                                               "feelsLike": 0,
                                                               "feelsLikeF": 0,
                                                               "city": "",
                                                               "country": "",
                                                               "wCode": 0,
                                                               "humidity": 0,
                                                               "wind": "",
                                                               "sunrise": "06:00",
                                                               "sunset": "18:00",
                                                               "uv": 0,
                                                               "pressure": 0,
                                                               "precipitationProbability": 0,
                                                               "isDay": true,
                                                               "forecast": []
                                                           }
                                                           root.lastFetchTime = 0
                                                           root.forceRefresh()
                                                       })

        SettingsData.weatherLocationChanged.connect(() => {
                                                        root.location = null
                                                        root.lastFetchTime = 0
                                                        root.forceRefresh()
                                                    })

        SettingsData.useAutoLocationChanged.connect(() => {
                                                        root.location = null
                                                        root.weather = {
                                                            "available": false,
                                                            "loading": true,
                                                            "temp": 0,
                                                            "tempF": 0,
                                                            "feelsLike": 0,
                                                            "feelsLikeF": 0,
                                                            "city": "",
                                                            "country": "",
                                                            "wCode": 0,
                                                            "humidity": 0,
                                                            "wind": "",
                                                            "sunrise": "06:00",
                                                            "sunset": "18:00",
                                                            "uv": 0,
                                                            "pressure": 0,
                                                            "precipitationProbability": 0,
                                                            "isDay": true,
                                                            "forecast": []
                                                        }
                                                        root.lastFetchTime = 0
                                                        root.forceRefresh()
                                                    })

        SettingsData.weatherEnabledChanged.connect(() => {
                                                       if (SettingsData.weatherEnabled && root.refCount > 0 && !root.weather.available) {
                                                           root.forceRefresh()
                                                       } else if (!SettingsData.weatherEnabled) {
                                                           updateTimer.stop()
                                                           retryTimer.stop()
                                                           persistentRetryTimer.stop()
                                                           if (weatherFetcher.running) {
                                                               weatherFetcher.running = false
                                                           }
                                                       }
                                                   })
    }
}
