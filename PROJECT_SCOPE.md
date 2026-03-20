# PROJECT_SCOPE.md
flutter clean && flutter pub get

tinh.musicapp@gmail.com
tinh123456

nguyenngoctinh011258@gmail.com
Twot2k5musicapp
## 1. Tên đề tài

Ứng dụng nghe nhạc di động phong cách Spotify mini

## 2. Mục tiêu bản demo đầu tiên (MVP)

Bản demo đầu tiên tập trung vào một ứng dụng nghe nhạc có thể chạy ổn định, giao diện hiện đại, có cá nhân hóa cơ bản và đủ để trình bày với giảng viên.

## 3. Chức năng bắt buộc trong MVP

### 3.1. Tài khoản người dùng

* Đăng ký tài khoản bằng email và mật khẩu
* Đăng nhập
* Đăng xuất
* Hiển thị avatar và thông tin tài khoản cơ bản

### 3.2. Trang chủ

* Avatar người dùng ở góc trên trái
* Bộ lọc nội dung phía trên gồm:

  * Tất cả
  * Âm nhạc
  * Podcasts
* Khi chọn Âm nhạc hoặc Podcasts sẽ có thêm mục Đang theo dõi
* Nội dung chính của Trang chủ gồm:

  * Nghe gần đây
  * Nhạc hay mỗi ngày cho bạn
  * Nội dung bạn nghe gần đây

### 3.3. Tìm kiếm

* Ô tìm kiếm với placeholder “Bạn muốn nghe gì?”
* Hiển thị lịch sử tìm kiếm gần đây
* Hiển thị khu vực khám phá nội dung mới mẻ
* Hiển thị khu vực duyệt tìm tất cả
* Tìm kiếm theo:

  * Bài hát
  * Nghệ sĩ
  * Album
  * Playlist
  * Podcast

### 3.4. Thư viện

* Hiển thị toàn bộ nội dung nếu không lọc
* Có 2 chip lọc:

  * Danh sách phát
  * Nghệ sĩ
* Hiển thị:

  * Playlist người dùng tạo
  * Playlist hệ thống như Bài hát đã thích
  * Nghệ sĩ người dùng đang theo dõi
* Có icon tìm kiếm và icon tạo ở góc trên phải

### 3.5. Tạo playlist

* Nút Tạo ở thanh điều hướng dưới
* Khi bấm sẽ hiện bottom sheet từ dưới lên
* Trong MVP chỉ làm hoàn chỉnh mục Danh sách phát
* Luồng tạo playlist:

  1. Bấm Tạo
  2. Chọn Danh sách phát
  3. Nhập tên playlist
  4. Tạo playlist
  5. Mở màn hình chi tiết playlist
  6. Thêm / xóa bài hát trong playlist
  7. Playlist xuất hiện trong Thư viện

### 3.6. Phát nhạc

* Mini player ở phía trên thanh điều hướng dưới
* Full player khi bấm vào mini player
* Phát / tạm dừng / chuyển bài
* Hiển thị ảnh cover, tên bài hát, nghệ sĩ
* Phát nhạc nền khi người dùng thoát khỏi app nhưng chưa đóng ứng dụng hoàn toàn

### 3.7. Lời bài hát

* Hiển thị lyrics cho bài hát
* Hỗ trợ lyrics đồng bộ theo thời gian phát với một số bài demo

### 3.8. Cá nhân hóa

* Like / unlike bài hát
* Theo dõi / bỏ theo dõi nghệ sĩ
* Tab Đang theo dõi lấy dữ liệu từ nghệ sĩ hoặc podcast đã follow
* Lưu lịch sử nghe gần đây

## 4. Chức năng chưa đưa vào MVP

Các chức năng sau chưa làm trong bản đầu tiên hoặc chỉ để dạng placeholder:

* Nhận diện bài hát kiểu Shazam
* Danh sách phát cộng tác
* Giai điệu chung
* Đề xuất thông minh bằng AI
* Podcast nâng cao

## 5. Điều hướng chính của ứng dụng

Thanh điều hướng dưới gồm 4 mục:

* Trang chủ
* Tìm kiếm
* Thư viện
* Tạo

Quy tắc:

* Khi bấm Trang chủ, bộ lọc phía trên luôn reset về Tất cả
* Nút Tạo luôn mở bottom sheet dù đang đứng ở tab nào
* Mini player luôn hiển thị phía trên thanh điều hướng dưới khi đang có nội dung phát

## 6. Chiến lược dữ liệu demo

### 6.1. Mục tiêu dữ liệu

* Có khoảng 100 bài hát để demo thư viện
* Trong đó 10–15 bài có thể phát local để demo an toàn khi mạng yếu hoặc mất mạng

### 6.2. Nguyên tắc lưu trữ

* Database lưu metadata và quan hệ
* Supabase Storage lưu file online
* Flutter assets lưu 10–15 bài offline demo

### 6.3. Quy tắc nguồn phát

* Nếu bài có `audio_source_type = asset` thì phát từ local assets
* Nếu bài có `audio_source_type = storage` thì phát từ Supabase Storage

## 7. Công nghệ chốt cho bản đầu

* Flutter
* Supabase Auth
* Supabase Postgres
* Supabase Storage

## 8. Danh sách bảng dữ liệu core cho MVP

* profiles
* artists
* albums
* songs
* song_artists
* song_lyric_lines
* playlists
* playlist_items
* liked_songs
* followed_artists
* listening_history
* recent_contents
* search_history

## 9. Thứ tự triển khai

1. Khóa scope MVP
2. Dựng project Flutter khung
3. Tạo Supabase project
4. Tạo schema database core
5. Chuẩn bị 100 bài demo và 10–15 bài offline
6. Làm UI chính: Home / Search / Library / Create
7. Nối dữ liệu thật
8. Làm mini player / full player / background playback / lyrics
9. Test end-to-end bản demo

## 10. Định nghĩa hoàn thành bản demo đầu tiên

Bản demo được xem là hoàn thành khi có thể trình bày trọn vẹn luồng sau:

1. Đăng nhập
2. Vào Trang chủ
3. Mở bài hát
4. Mini player hiển thị đúng
5. Mở full player
6. Xem lyrics
7. Like bài hát
8. Follow nghệ sĩ
9. Tạo playlist
10. Thêm bài hát vào playlist
11. Mở Thư viện và nhìn thấy playlist vừa tạo
12. Nhạc vẫn tiếp tục phát khi chuyển app hoặc tắt màn hình
