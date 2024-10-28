# Horizon

<p align="left">
  <img src="https://github.com/jonathanvieri/Horizon/blob/main/images/applogo.png" width="150" height="150">
</p>


<p>
  Horizon is a weather app that provides users with current weather data, air quality information, and location-based weather tracking. The app allows users to view real-time weather conditions, switch between measurement units, and customize settings for notifications. Horizon also includes a search feature for checking the weather in different cities and provides air quality details with a detailed view option.
</p>

<p>
  Horizon is designed to offer easy access to weather updates and air quality data, making it suitable for users who need quick and reliable information to plan their day or travel.
</p>


## Screenshots

## Features
- **View Current Weather Data**: Access up-to-date weather conditions, including current temperature, “feels like” temperature, and detailed weather descriptions for your location.
- **Location-Based Weather Tracking**: Automatically fetch weather data based on your current location, with an option to set a default city for easier access.
- **Air Quality Index (AQI) Display**: View the air quality index at a glance, with a detailed view option for additional AQI information.
- **Customizable Units of Measurement**: Easily switch between Celsius and Fahrenheit or adjust other measurement units according to your preference.
- **Daily Weather Notifications**: Get a daily weather update notification at a time you choose to stay informed about the day's forecast.
- **Data Caching for Offline Access**: Cached data for previously fetched weather information enables offline access and reduces data usage.

## Technical Overview
- **SwiftUI**: Used for building the user interface, with a focus on simplicity and responsiveness.
- **MVVM**: Implements MVVM architecture to ensure a clean separation of concerns, making the app modular, testable, and easier to maintain.
- **CoreLocation Framework**: Enables location-based weather tracking by managing user location permissions and updates.
- **UserDefaults**: Used for persistent storage of user preferences, such as selected units, default city, and caching weather data for offline access.
- **URLSession**: Handles network requests to fetch real-time weather and AQI data from the OpenWeather API.
- **Push Notifications**: Allows users to receive daily weather updates at a scheduled time.
- **Custom Toolbar**: Designed using SwiftUI’s Toolbar API for quick access to core actions like location, refresh, search, and settings.
- **Data Caching**: Caches fetched weather data for offline access, reducing network requests and improving data availability in low-bandwidth conditions.

## Usage


## License
This project is licensed under the [MIT License](https://github.com/jonathanvieri/Chooaca/blob/master/LICENSE)
