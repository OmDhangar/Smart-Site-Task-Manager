# Flutter Riverpod Todo App

This is a Todo app built with Flutter and Riverpod that uses an AI-powered backend to classify and manage tasks.

## Getting Started

1. **Clone the repository:**

   ```bash
   git clone https://github.com/your-username/flutter_riverpod_todo_app.git
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Set up the environment variables:**

   Create a `.env` file in the root of the project and add the following values (see `.env.example`):

   ```
   API_BASE_URL=http://localhost:3000
   API_KEY=your-secret-api-key
   ```

   Platform examples:
   - Android emulator: use `http://10.0.2.2:3000`
   - iOS simulator: `http://localhost:3000`
   - Physical device: use your machine LAN IP, e.g. `http://192.168.1.42:3000`
   - Production: use your HTTPS API, e.g. `https://api.example.com`

   Do NOT hardcode URLs or API keys anywhere in code; configure them via `.env`.

## Networking & Auth (Why this is correct) ✅

- The app loads environment variables early in `main.dart` using `flutter_dotenv` so values can be changed without code edits.
- A centralized `DioClient` reads `API_BASE_URL` and `API_KEY` from the environment and sets:
  - `baseUrl` for all requests
  - default headers `Content-Type: application/json` and `X-API-Key` / `Authorization: Bearer <key>`
  - timeouts for reliability
- The `DioClient` instance is a singleton and provided via Riverpod, so it is reused across the app (no per-request recreation).
- Repositories/data sources accept `DioClient` via DI and only use relative paths such as `/api/tasks` — they never read env variables directly.

This satisfies platform-awareness (you can set `API_BASE_URL` to `http://10.0.2.2:3000` for the Android emulator, `http://localhost:3000` for iOS simulator, LAN IP for physical devices, or an HTTPS domain for production) and keeps keys out of the source code.



4. **Run the app:**

   ```bash
   flutter run
   ```
