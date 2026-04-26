# Flutter Recipe Browser App


## Student Information

- Name: Biniyam Abel
- ID: ATE/8191/15


## Track

Track C -- Recipe Browser App (TheMealDB API)


## Description

A Flutter application that allows users to browse meal recipes using TheMealDB API. The app displays a list of meal categories on the home screen. Users can tap a category to view all meals within that category, then tap a meal to see its full details including the image, category, area of origin, list of ingredients, cooking instructions, and a link to watch the recipe video on YouTube. The app includes proper error handling for network issues, timeouts, and unexpected API responses.


## Project Structure

```
lib/
  main.dart
  models/
    meal.dart
    meal_category.dart
  services/
    meal_api_handler.dart
    api_exception.dart
  screens/
    home_screen.dart
    category_screen.dart
    detail_screen.dart
```


## Setup Instructions

1. Clone the repository
2. Run the following commands:

```
flutter pub get
flutter run
```


## API Endpoints Used

All endpoints use the base URL: https://www.themealdb.com/api/json/v1/1/

- GET /categories.php -- Fetches all meal categories
- GET /filter.php?c={category} -- Fetches meals filtered by category name
- GET /lookup.php?i={mealId} -- Fetches full details of a meal by its ID


## Dependencies

- http -- For making HTTP API requests
- url_launcher -- For opening YouTube links in an external browser


## Features

- Browse meal categories with images and names
- View meals within a selected category in a grid layout
- View full meal details including ingredients and instructions
- Watch recipe videos on YouTube via external link
- Error handling with retry functionality on all screens
- Handles no internet, timeout, invalid data, and API errors


## Known Limitations

- Requires an active internet connection to fetch data
- YouTube links depend on device browser or YouTube app availability
- TheMealDB free API may have rate limits or occasional downtime
