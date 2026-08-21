# 🎬 Flutter Movie App

A mobile movie application built with **Flutter**, using the **TMDB API** to fetch trending movies, search, watch trailers, manage favorites, and support multiple themes (Dark/Light Mode).

---

## ✨ Key Features

- **🌙 Dark / Light Mode Switching:** Smooth switching between Light and Dark themes using `Bloc`/`Cubit`.
- **🔥 Popular Movies & Pagination (Infinite Scroll):** Displays a list of popular movies and automatically loads the next page when scrolling to the bottom.
- **🏷️ Genre Filtering (Genre Chips):** A horizontal scroll bar allowing users to quickly filter movies by genre (Action, Comedy, Horror, Sci-Fi, etc.).
- **🔍 Smart Search:** Search for movies by keyword with optimized multilingual data support.
- **📺 Live Trailer Streaming:** Integrated with `youtube_player_flutter` to play movie trailers directly within the detail screen.
- **⭐ Similar Movies:** Suggests a horizontal scrolling list of related movies on the detail screen to help users discover more content.
- **❤️ Favorites Management:** Stores and manages personal favorite movies locally.
- **🧭 Bottom Navigation Bar:** Modern navigation bar for quick switching between tabs: Home, Favorites, and Settings.
- **🌐 Multi-language Support:** Supports multiple languages (Vietnamese, English, Chinese, Korean, Japanese).

---

## 🛠️ Technologies & Libraries Used

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **State Management:** [Flutter Bloc](https://pub.dev/packages/flutter_bloc) (`Cubit`)
- **Networking:** [Dio](https://pub.dev/packages/dio) for API requests
- **Image Handling:** [Cached Network Image](https://pub.dev/packages/cached_network_image) for optimized poster loading and caching
- **Video Playback:** [Youtube Player Flutter](https://pub.dev/packages/youtube_player_flutter) for YouTube trailer playback
- **Data Source:** [TMDB API (The Movie Database)](https://www.themoviedb.org/documentation/api)

---

## 📂 Project Directory Structure

```text
lib/
│
├── core/              # General configurations
├── data/              # Data Layer
│   ├── models/        # Movie model
│   └── repositories/  # API and local storage
│
├── logic/             # App State Management (ThemeCubit, BLoC...)
│   └── cubits/
│
└── presentation/      # Presentation Layer (UI)
    ├── bloc/          # MovieBloc, Event, State
    └── screens/       # Screens

 ``` 

## 📱 App Screenshots

<img width="200" alt="image" src="https://github.com/user-attachments/assets/0d60fcc9-37ee-49ad-bec8-cb33db9421c0" />

