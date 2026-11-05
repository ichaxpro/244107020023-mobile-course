# Mobile Programming Report - Week 10: AI Feature Integration


## 1. Overview & Objectives

In this lab session, we explored the integration of Artificial Intelligence (AI) capabilities into a Flutter mobile application. The main focus was on utilizing Generative AI models (such as Google Gemini / OpenAI) to create smart mobile experiences using proper state management and asynchronous response streaming.

### Core Learning Objectives:
- [x] Setting up API authentication and securing API keys using environment configuration (`.env`).
- [x] Implementing Generative AI services for text-based prompts and multimodal (image/text) inputs.
- [x] Handling real-time streaming data from AI APIs using Flutter stream builders and asynchronous logic.
- [x] Managing UI state (loading, streaming, success, and error states) during AI interaction.

---

## 2. Project Architecture & Code Structure

The project follows a clean, modular Flutter project layout separating business logic, models, services, and UI components:

```text
lib/
├── config/
│   └── env_config.dart     # Loads environment variables securely
├── models/
│   └── chat_message.dart   # Data model representing user & AI prompts/responses
├── services/
│   └── ai_service.dart     # Handles HTTP requests & SDK calls to the AI API
├── providers / state/
│   └── ai_provider.dart    # Manages application state and API stream responses
└── screens/
    └── ai_chat_screen.dart # User interface for interaction and displaying results
```

---

## 3. Key Features Implemented

1. **Secure Configuration:**
   - Managed API keys via `flutter_dotenv` to prevent exposing secret credentials inside public Git repositories.

2. **Generative Text & Multimodal Prompts:**
   - Integrated AI model calls capable of receiving text queries and image payloads to generate relevant contextual responses.

3. **Streamed Response UI:**
   - Leveraged reactive UI components to dynamically render partial tokens as the AI model streams its response line-by-line.

4. **Error & Edge-Case Handling:**
   - Implemented fallback views and friendly user notifications for offline mode, invalid API keys, or model rate limits.

---

## 4. Screenshots & Output Demonstration
<img src="image\chat_ai.jpeg" width="350" alt="Warmup Result">


---

## 5. Setup & Running Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/flutter-ai-integration.git
   cd flutter-ai-integration
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables:**


4. **Run the Flutter App:**
   ```bash
   flutter run
   ```

---

## 6. Reflection & Conclusions

- **API Security:** Hardcoding secret keys directly in client-side mobile code poses severe security risks. Utilizing environment variables (`.env`) or compile-time flags (`--dart-define`) is an industry best practice.
- **Asynchronous UX:** Waiting for full AI responses can lead to a sluggish user experience. Using streams (`StreamBuilder`) allows immediate user feedback by rendering AI output iteratively.
- **Prompt Engineering:** Formulating structured system instructions and clear user inputs heavily influences the quality and reliability of the generated output in mobile apps.