# HR RECRUITMENT CONTROL – HỆ THỐNG QUẢN LÝ YÊU CẦU TUYỂN DỤNG SUẤT ĂN CÔNG NGHIỆP

Ứng dụng web quản lý tập trung nhu cầu tuyển dụng từ tất cả các cơ sở bếp ăn công nghiệp, kết nối Leader tại từng nhà máy với phòng HR/HCNS, quản lý định biên nhân sự, cảnh báo thời hạn và báo cáo tổng hợp.

---

## 🌟 TÍNH NĂNG CHÍNH

### 1. Phân Quyền Vai Trò Người Dùng (Role Switcher)
- **Leader / Cấp cơ sở**: Tạo yêu cầu tuyển dụng cho bếp ăn phụ trách, theo dõi tiến độ HR, xem định biên nhân sự.
- **Phòng HR / HCNS**: Tiếp nhận yêu cầu (Intake Queue), phân công nhân viên HR, cập nhật ứng viên đã tuyển, duyệt thông tin hoặc yêu cầu bổ sung.
- **Admin**: Quản trị toàn bộ danh mục Khách hàng, Bếp ăn, Vị trí tuyển dụng, Người dùng và sao lưu/phục hồi dữ liệu.

### 2. Quản Lý Yêu Cầu Tuyển Dụng Tập Trung
- Mã yêu cầu tự động: `REQ-2026-0001`, `REQ-2026-0002`...
- Phân tách độc lập **Trạng thái xử lý HR** (Chờ tiếp nhận, Đã tiếp nhận, Chờ bổ sung, Từ chối) và **Trạng thái tuyển dụng** (Chưa triển khai, Đang tuyển, Đúng hạn, Quá hạn).
- Theo dõi nhật ký thao tác (Audit trail timeline) cho từng yêu cầu.

### 3. Quản Lý Định Biên Nhân Sự (Staffing Plan)
- So sánh **Định biên được duyệt** vs **Số nhân sự hiện có** tại từng bếp ăn.
- Tự động tính số lượng thiếu hụt (`Định biên - Hiện có`).
- Cho phép ấn nút `+ Tuyển Thiếu` để mở form đăng ký với các trường được điền sẵn.

### 4. Trung Tâm Cảnh Báo Tuyển Dụng (Alert Center)
- Giám sát 12 loại cảnh báo: Yêu cầu mới chưa tiếp nhận, Chưa phân công HR, Sắp đến hạn (7 ngày), Khẩn cấp (3 ngày), Đến hạn hôm nay, Quá hạn tuyển dụng, Tuyển vượt chỉ tiêu...
- Tự động tính toán theo ngày hiện tại và múi giờ `Asia/Ho_Chi_Minh`.

### 5. Chuẩn Hóa Múi Giờ & Định Dạng Việt Nam
- **Múi giờ**: `Asia/Ho_Chi_Minh` (UTC+07:00).
- **Ngày tháng**: `DD/MM/YYYY` (ví dụ `08/11/2026`) & `DD/MM/YYYY HH:mm`.
- **Tiền tệ**: Đồng Việt Nam `VNĐ` (dấu chấm phân cách nghìn: `6.500.000 VNĐ`).
- **Ngôn ngữ**: 100% tiếng Việt.

### 6. Xuất & Nhập Dữ Liệu Dạng JSON / Excel CSV
- **Xuất JSON**: Sao lưu toàn bộ dữ liệu hệ thống (Customers, Locations, Positions, Requests, Audit Logs, Settings).
- **Nhập JSON**: Kiểm tra cú pháp, xem trước số bản ghi, chọn **Nhập gộp (Merge)** hoặc **Thay thế toàn bộ (Replace)**.
- **Xuất Excel CSV**: Định dạng UTF-8 có BOM (`\uFEFF`) giúp mở trực tiếp bằng Microsoft Excel tiếng Việt không bị lỗi phông chữ.

---

## 🛠 HƯỚNG DẪN TRIỂN KHAI LÊN VERCEL

1. Push mã nguồn lên repository GitHub.
2. Đăng nhập vào dashboard [Vercel](https://vercel.com).
3. Chọn **New Project** -> Import repository GitHub.
4. Framework Preset: **Vite**.
5. Build Command: `npm run build`.
6. Output Directory: `dist`.
7. Nhấn **Deploy**.

---

## 🏗 KIẾN TRÚC MÃ NGUỒN

```
/src
  /components
    NavbarHeader.tsx        # Thanh điều hướng trên cùng & Role Switcher
    Sidebar.tsx             # Menu dọc phân quyền
    DashboardView.tsx       # Báo cáo tổng quan & Biểu đồ Recharts
    RequestsListView.tsx    # Bảng quản lý yêu cầu tuyển dụng central
    LeaderRequestForm.tsx   # Form đăng ký tuyển dụng chuyên nghiệp
    StaffingPlanView.tsx    # Quản lý định biên bếp ăn
    IntakeProcessingView.tsx# Hàng chờ tiếp nhận của phòng HR
    AlertCenterView.tsx     # Trung tâm cảnh báo 12 loại quy tắc
    MasterDataView.tsx      # Quản lý danh mục Khách hàng, Cơ sở, Vị trí, User
    ReportsView.tsx         # Báo cáo chi tiết & Xuất Excel CSV UTF-8 BOM
    DataBackupView.tsx      # Xuất/Nhập file JSON & Restore Seed
    SettingsView.tsx        # Cấu hình số ngày cảnh báo
  /services
    initialData.ts          # Dữ liệu mẫu kiểm thử Samsung, LG, Foxconn, Canon, Vinschool
    storage.ts              # Động cơ LocalStorage, Auto Alert Engine & REQ Code Generator
  /utils
    formatters.ts           # Hàm định dạng VNĐ, Ngày tháng Việt Nam, Múi giờ UTC+7
    csvExport.ts            # Hàm xuất file CSV UTF-8 với BOM prefix
  /types
    index.ts                # TypeScript Interfaces
```
