# Production Code Audit: Online Pharmacy System

**Date:** 2025-11-29
**Auditor Role:** Senior Flutter Architect

## 1. Naming Conventions & Cognitive Load
**Verdict:** 🔴 **Critical Issues Found**

*   **Language Inconsistency (High Cognitive Load):**
    *   **Issue:** The codebase suffers from a severe split in naming languages. Models are in Vietnamese (`Thuoc`, `maThuoc`, `DonHang`), while Controllers/Services are in English (`CartController`, `ProductService`).
    *   **Impact:** This increases cognitive load significantly. Developers must constantly translate mental models (e.g., "Product ID" -> `maThuoc`). It also breaks standard Dart coding conventions.
    *   **Recommendation:** Refactor ALL Models to English to match the rest of the architecture. Use `json_annotation`'s `@JsonKey(name: 'TenThuoc')` to map API fields while keeping Dart properties in English (e.g., `final String name;`).

*   **Semantic Clarity:**
    *   **Issue:** `Thuoc` (Medicine) is used for all products, but a pharmacy sells more than just medicine (supplements, equipment).
    *   **Recommendation:** Rename to `Product` to be more semantically accurate and extensible.

## 2. Architectural Integrity
**Verdict:** 🟠 **Major Concerns**

*   **Navigation Anti-Pattern:**
    *   **Issue:** `main.dart` uses `final GlobalKey<MainScreenState> mainScreenKey` to control tab switching from outside the widget tree.
    *   **Critique:** This breaks encapsulation and creates tight coupling. Navigation logic should be handled via a `NavigationService` or proper State Management, not by exposing a widget's private State globally.

*   **Singleton Misuse in State Management:**
    *   **Issue:** `CartController` is implemented as a Singleton (`static final CartController _instance`) AND provided via `ChangeNotifierProvider`.
    *   **Critique:** This is redundant and dangerous. If you use Provider, the `Provider` itself should manage the instance lifecycle. Using a Singleton prevents you from easily mocking the controller for unit tests or resetting state (e.g., on user logout).

*   **Dependency Injection:**
    *   **Status:** Usage of `GetIt` (`locator`) is good, but inconsistent. Some controllers inject services, others instantiate them directly (e.g., `CartController` does `final CartService _service = CartService();`). This makes unit testing `CartController` impossible without mocking the backend.

## 3. Business Logic Placement
**Verdict:** 🟠 **Leaking Logic**

*   **Service Layer Leakage:**
    *   **Issue:** `ProductService` contains static methods like `hasPromotion` and `getDiscountedPrice`.
    *   **Critique:** This is "Anemic Domain Model" anti-pattern. Price calculation is a core business rule of a Product. It belongs in the `Thuoc` (Product) entity or an extension method, NOT in a data-fetching service.

*   **Error Handling Fragility:**
    *   **Issue:** `ProductService` returns `Map<String, dynamic>` (`{'success': true, ...}`).
    *   **Critique:** This is "Stringly-typed" programming. It is prone to typos (e.g., typing `'sucess'` instead of `'success'`).
    *   **Recommendation:** Use `Either<Failure, T>` (from `fpdart`) or sealed classes (`Result.success`, `Result.failure`) to enforce compile-time safety for errors.

## 4. UI/UX & Data Presentation
**Verdict:** 🟢 **Strong Point**

*   **Optimistic UI:**
    *   **Observation:** `CartController` updates the UI immediately (`notifyListeners`) before waiting for the API response.
    *   **Critique:** Excellent. This makes the app feel native and responsive.

*   **Visuals:**
    *   **Observation:** High-quality implementation using `SliverAppBar`, Glassmorphism, and consistent spacing. The "Modern Medical" theme is well executed.

## 5. Gap Analysis (Production Readiness)
**Verdict:** 🔴 **Not Production Ready**

To launch, you **MUST** address these gaps:

1.  **Prescription Upload (Legal/Compliance):** You cannot sell Rx drugs without a prescription. The app needs a flow to upload images/PDFs during checkout.
2.  **Robust Search:** A text-only search is insufficient. Users need filters for **Symptoms** (Headache, Fever), **Brands**, and **Price Range**.
3.  **Offline Capability:** There is no local database (Hive/SQLite). If the user loses internet, the cart and product history are lost or inaccessible.
4.  **Guest Checkout:** Forcing login immediately (`DialogHelper.showLoginRequirement`) causes high drop-off rates. Implement a Guest Checkout flow.
5.  **Form Validation:** Ensure strict validation on the Address and Phone Number fields in the Order flow.

## Final Score: 6.5/10
**Summary:** The app has a beautiful frontend and a decent architectural skeleton, but it is held back by "Student Project" habits (Vietnamese naming, Singletons, GlobalKeys) and lacks critical e-commerce features.
