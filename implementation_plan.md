# Implementation Plan - Refactor Models to English

## Goal
Refactor the `Thuoc` model to `Product` to resolve the naming inconsistency issue (Error 1). This involves renaming the class, file, and properties to English while maintaining mapping to the Vietnamese API.

## Proposed Changes

### 1. Model Refactoring
#### [NEW] [product.dart](file:///d:/HOCTAP/HK1_2025_2026/Do%20An%20Cu%20Nhan/nhathuoc_mobilee/lib/models/product.dart)
- Create `Product` class replacing `Thuoc`.
- Properties:
    - `maThuoc` -> `id`
    - `tenThuoc` -> `name`
    - `donGia` -> `price`
    - `anhURL` -> `imageUrl`
    - `donVi` -> `unit`
    - `cachSD` -> `usage`
    - `congDung` -> `description`
    - `thanhPhan` -> `ingredients`
    - `loaiThuoc` -> `type`
    - `nhaCungCap` -> `manufacturer`
    - `soLuongTon` -> `stock`
    - `khuyenMai` -> `promotion`
- `fromJson`: Map Vietnamese keys (e.g., `Id`, `TenThuoc`) to English properties.

#### [DELETE] [thuoc.dart](file:///d:/HOCTAP/HK1_2025_2026/Do%20An%20Cu%20Nhan/nhathuoc_mobilee/lib/models/thuoc.dart)

### 2. Update Dependencies
The following files reference `Thuoc` and need to be updated:

#### Services
- `lib/service/productservice.dart`: Update return types and logic (`hasPromotion`, `getDiscountedPrice`) to use `Product`.

#### Controllers
- `lib/controller/home_controller.dart`: Update `List<Thuoc>` to `List<Product>`.
- `lib/controller/productcontroller.dart`: Update references.
- `lib/controller/cartcontroller.dart`: Check if `GioHang` references `Thuoc`.
- `lib/controller/historyordercontroller.dart`: Check references.

#### UI
- `lib/UI/screens/home_screen.dart`: Update `SanPhamItem`.
- `lib/UI/widgets/Home/item_product.dart`: Update `Thuoc` to `Product`.
- `lib/UI/screens/detail_product_screen.dart`: Update navigation arguments.

#### Other Models
- `lib/models/giohang.dart`: Does it contain `Thuoc`?
- `lib/models/thuoc_detail.dart`: Does it extend `Thuoc`?

## Verification Plan
1.  **Analyze**: Run `flutter analyze` to find all broken references.
2.  **Manual Check**: Verify `HomeScreen` loads products correctly.
3.  **Manual Check**: Verify `ProductDetailScreen` shows correct info.
