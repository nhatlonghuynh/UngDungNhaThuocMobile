# Business Logic Flow Analysis

I have verified the core business logic flows of the application. The codebase is currently consistent using the `Thuoc` model (Vietnamese naming).

## 1. Authentication Flow
- **Status**: ✅ Functional
- **Components**: `AuthController`, `LoginScreen`, `AuthService`
- **Flow**:
    1. User enters Phone/Pass.
    2. `AuthController` calls `AuthService`.
    3. On success, `UserManager` updates state.
    4. UI navigates back or updates.
- **Notes**:
    - The flow requires users to manually re-initiate actions (like "Buy Now") after logging in from a prompt.

## 2. Product List & Search
- **Status**: ✅ Functional
- **Components**: `HomeController`, `ProductService`, `Thuoc` model
- **Flow**:
    1. `HomeController` fetches data via `ProductService`.
    2. `ProductService` maps API response to `Thuoc` objects.
    3. Business logic (Promotion, Price) is handled via static methods in `ProductService` (e.g., `ProductService.getDiscountedPrice(thuoc)`).
- **Issues**:
    - Business logic is "leaked" into the Service layer instead of being in the Model.

## 3. Cart & Checkout
- **Status**: ✅ Functional
- **Components**: `CartController`, `CartManager`, `OrderScreen`
- **Flow**:
    1. **Add to Cart**: `CartManager` saves to Local Storage (SharedPreferences).
    2. **View Cart**: `CartManager` syncs Local IDs with Server to get latest details.
    3. **Checkout**: `OrderController` handles order placement.
    4. **Payment**: Supports COD and PayOS (via WebView).
- **Notes**:
    - `CartController` uses a Singleton pattern, which is functional but can be fragile for testing.

## 4. Order History
- **Status**: ✅ Functional
- **Components**: `OrderHistoryController`, `OrderService`
- **Flow**:
    1. Fetches orders based on status.
    2. Supports cancelling orders.

## Summary
The application logic is currently **stable** and **consistent** with the original design. The previous attempt to refactor `Thuoc` to `Product` appears to have been reverted.

**Recommendations:**
- If you wish to proceed with modernization, we should restart the `Thuoc` -> `Product` refactor carefully.
- If you prefer to keep `Thuoc`, we can focus on fixing the "Leaking Logic" (moving logic from Service to `Thuoc` model) and improving Error Handling.
