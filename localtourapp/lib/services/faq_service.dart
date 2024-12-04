
import '../models/faq_model.dart';

class FAQService {
  final Map<String, List<FAQ>> _faqData = {
    'en': [
      FAQ(
        question: 'How to create a schedule?',
        answer: 'To create a schedule, navigate to the "Planned" section and tap on "Create Schedule". Follow the prompts to add your events and destinations.',
      ),
      FAQ(
        question: 'How to use the map?',
        answer: 'Access the map from the main navigation bar. You can search for places, view your current location, and explore nearby attractions.',
      ),
      FAQ(
        question: 'How to find a place?',
        answer: 'Use the search bar in the map or home screen to enter the name or type of place you are looking for. The app will display matching results.',
      ),
      FAQ(
        question: 'How to bookmark a place?',
        answer: 'On the place details page, tap the bookmark icon to save the place to your bookmarks. You can access your bookmarks from the "Bookmark" section.',
      ),
      FAQ(
        question: 'How to create my post?',
        answer: 'Go to the "Account" section and tap on "Create Post". Enter your content, add images if desired, and submit your post for others to see.',
      ),
      FAQ(
        question: 'How to see other people\'s posts and schedules?',
        answer: 'Navigate to the "View Profile" section to view posts and schedules shared by other users. You can like, comment, or follow their profiles.',
      ),
      FAQ(
        question: 'How to report a place/person?',
        answer: 'On the place or user profile page, tap the "Report" button. Provide the necessary details, and our team will review your report promptly.',
      ),
      FAQ(
        question: 'How to see the weather?',
        answer: 'Access the "Weather" section from the main navigation bar to view current weather conditions and forecasts for your selected locations.',
      ),
    ],
    'vi': [
      FAQ (
        question: 'Làm thế nào để tạo lịch trình?',
        answer: 'Để tạo lịch trình, hãy điều hướng đến phần "Đã lên kế hoạch" và chạm vào "Tạo lịch trình". Làm theo lời nhắc để thêm sự kiện và điểm đến của bạn.',
      ),
      FAQ (
        question: 'Làm thế nào để sử dụng bản đồ?',
        answer: 'Truy cập bản đồ từ thanh điều hướng chính. Bạn có thể tìm kiếm địa điểm, xem vị trí hiện tại của mình và khám phá các điểm tham quan gần đó.',
      ),
      FAQ (
        question: 'Làm thế nào để tìm một địa điểm?',
        answer: 'Sử dụng thanh tìm kiếm trên bản đồ hoặc màn hình chính để nhập tên hoặc loại địa điểm bạn đang tìm kiếm. Ứng dụng sẽ hiển thị kết quả phù hợp.',
      ),
      FAQ (
        question: 'Làm thế nào để đánh dấu một địa điểm?',
        answer: 'Trên trang chi tiết địa điểm, hãy chạm vào biểu tượng dấu trang để lưu địa điểm vào dấu trang của bạn. Bạn có thể truy cập dấu trang của mình từ phần "Dấu trang".',
      ),
      FAQ (
        question: 'Làm thế nào để tạo bài đăng của tôi?',
        answer: 'Đi tới phần "Tài khoản" và chạm vào "Tạo bài đăng". Nhập nội dung của bạn, thêm hình ảnh nếu muốn và gửi bài đăng của bạn để mọi người xem.',
      ),
      FAQ (
        question: 'Làm thế nào để xem bài đăng và lịch trình của người khác?',
        answer: 'Điều hướng đến phần "Xem hồ sơ" để xem các bài đăng và lịch trình do người dùng khác chia sẻ. Bạn có thể thích, bình luận hoặc theo dõi hồ sơ của họ.',
      ),
      FAQ (
        question: 'Làm thế nào để báo cáo một địa điểm/người?',
        answer: 'Trên trang hồ sơ địa điểm hoặc người dùng, chạm vào nút "Báo cáo". Cung cấp các thông tin chi tiết cần thiết và nhóm của chúng tôi sẽ xem xét báo cáo của bạn ngay lập tức.',
      ),
      FAQ (
        question: 'Làm thế nào để xem thời tiết?',
        answer: 'Truy cập phần "Thời tiết" từ thanh điều hướng chính để xem điều kiện thời tiết hiện tại và dự báo cho các địa điểm bạn đã chọn.',
      ),
    ],
  };

  List<FAQ> getFAQs(String languageCode) {
    return _faqData[languageCode] ?? _faqData['en']!;
  }
}
