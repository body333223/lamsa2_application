import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/locale_service.dart';

class AppStrings {
  final BuildContext context;
  AppStrings(this.context);

  bool get isArabic => context.watch<LocaleService>().isArabic;

  // ── App ──────────────────────────────────────────────
  String get appName => isArabic ? 'لمسة' : 'Lamsa';
  String get appTagline => isArabic
      ? 'وجهتك للجمال والاسترخاء'
      : 'Your beauty & relaxation destination';

  // ── Auth ─────────────────────────────────────────────
  String get welcome => isArabic ? 'أهلاً فيك' : 'Welcome';
  String get login => isArabic ? 'تسجيل الدخول' : 'Login';
  String get register => isArabic ? 'إنشاء حساب' : 'Create Account';
  String get email => isArabic ? 'البريد الإلكتروني' : 'Email';
  String get password => isArabic ? 'كلمة المرور' : 'Password';
  String get confirmPassword =>
      isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password';
  String get name => isArabic ? 'الاسم' : 'Name';
  String get language => isArabic ? 'English' : 'العربية';
  String get loginSubtitle => isArabic
      ? 'أدخلي رقم هاتفك عشان نرسل لك رمز التحقق'
      : 'Enter your phone number to receive a verification code';
  String get registerSubtitle => isArabic
      ? 'أدخلي بياناتك عشان تنشئي حساب جديد'
      : 'Enter your details to create a new account';
  String get noAccount => isArabic ? 'ما عندك حساب؟' : "Don't have an account?";
  String get haveAccount =>
      isArabic ? 'عندك حساب؟' : 'Already have an account?';
  String get createAccount => isArabic ? 'إنشاء حساب' : 'Create Account';
  String get signIn => isArabic ? 'تسجيل الدخول' : 'Sign In';
  String get privacyText => isArabic
      ? 'بالمتابعة، أنتِ توافقين على شروط الاستخدام وسياسة الخصوصية'
      : 'By continuing, you agree to the Terms of Use and Privacy Policy';
  String get enterEmail => isArabic ? 'أدخلي الإيميل' : 'Enter your email';
  String get invalidEmail => isArabic ? 'الإيميل غير صحيح' : 'Invalid email';
  String get enterPassword =>
      isArabic ? 'أدخلي كلمة المرور' : 'Enter your password';
  String get passwordTooShort => isArabic
      ? 'كلمة المرور لازم تكون 6 أحرف على الأقل'
      : 'Password must be at least 6 characters';
  String get enterName => isArabic ? 'أدخلي الاسم' : 'Enter your name';
  String get shortName => isArabic ? 'الاسم قصير' : 'Name is too short';
  String get enterConfirmPassword =>
      isArabic ? 'أدخلي تأكيد كلمة المرور' : 'Enter password confirmation';
  String get passwordNotMatch =>
      isArabic ? 'كلمة المرور ما تطابقت' : 'Passwords do not match';

  // ── Phone Auth ───────────────────────────────────────
  String get phoneNumber => isArabic ? 'رقم الهاتف' : 'Phone Number';
  String get enterPhoneNumber =>
      isArabic ? 'أدخلي رقم الهاتف' : 'Enter your phone number';
  String get invalidPhoneNumber =>
      isArabic ? 'رقم الهاتف غير صحيح' : 'Invalid phone number';
  String get sendOtp => isArabic ? 'إرسال رمز التحقق' : 'Send OTP';
  String get otpVerification =>
      isArabic ? 'التحقق من الرمز' : 'OTP Verification';
  String get enterOtp =>
      isArabic ? 'أدخلي رمز التحقق' : 'Enter verification code';
  String get otpSentTo => isArabic ? 'تم إرسال الرمز إلى' : 'Code sent to';
  String get verifyOtp => isArabic ? 'تحقق' : 'Verify';
  String get resendOtp => isArabic ? 'إعادة إرسال الرمز' : 'Resend Code';
  String get otpExpired => isArabic ? 'انتهت صلاحية الرمز' : 'Code expired';
  String get phoneRegisterSubtitle => isArabic
      ? 'أدخلي رقم هاتفك عشان نرسل لك رمز التحقق'
      : 'Enter your phone number to receive a verification code';
  String get secondsRemaining => isArabic ? 'ثانية' : 'seconds';
  String get didNotReceiveCode =>
      isArabic ? 'ما وصلك الرمز؟' : "Didn't receive the code?";

  // ── Navigation ───────────────────────────────────────
  String get home => isArabic ? 'الرئيسية' : 'Home';
  String get myBookings => isArabic ? 'حجوزاتي' : 'My Bookings';
  String get myAccount => isArabic ? 'حسابي' : 'My Account';
  String get back => isArabic ? 'رجوع' : 'Back';

  // ── Home ─────────────────────────────────────────────
  String get goodMorning => isArabic ? 'صباح الخير' : 'Good morning';
  String get searchHint =>
      isArabic ? 'وش تبحثين عنه اليوم؟' : 'What are you looking for today?';
  String get services => isArabic ? 'الخدمات' : 'Services';
  String get popularServices => isArabic ? 'الأكثر طلباً' : 'Most Popular';
  String get noCategories =>
      isArabic ? 'ما في تصنيفات حالياً' : 'No categories available';

  // ── Search ───────────────────────────────────────────
  String get search => isArabic ? 'بحث' : 'Search';
  String get searchPlaceholder =>
      isArabic ? 'ابحثي عن خدمة...' : 'Search for a service...';
  String get noResults => isArabic ? 'ما في نتائج' : 'No Results';
  String get tryDifferentSearch =>
      isArabic ? 'جربي كلمة بحث ثانية' : 'Try a different search term';
  String get all => isArabic ? 'الكل' : 'All';
  String get massage => isArabic ? 'مساج' : 'Massage';
  String get moroccanBath => isArabic ? 'حمام مغربي' : 'Moroccan Bath';
  String get pedicureManicure =>
      isArabic ? 'بادكير ومنكير' : 'Pedicure & Manicure';
  String get packages => isArabic ? 'الباقات' : 'Packages';
  String get bookNow => isArabic ? 'احجزي' : 'Book';

  // ── Service Details ───────────────────────────────────
  String get serviceDescription =>
      isArabic ? 'وصف الخدمة' : 'Service Description';
  String get whatsIncluded => isArabic ? 'وش يشمل الحجز' : "What's Included";
  String get certifiedSpecialist =>
      isArabic ? 'متخصصة معتمدة ومدربة' : 'Certified specialist';
  String get premiumProducts =>
      isArabic ? 'منتجات عالية الجودة' : 'Premium quality products';
  String get atHomeOrCenter =>
      isArabic ? 'الخدمة توصلك لبيتك' : 'Service delivered to your home';
  String get totalPrice => isArabic ? 'السعر الإجمالي' : 'Total Price';
  String get bookNowFull => isArabic ? 'احجزي الحين' : 'Book Now';
  String get reviews => isArabic ? 'تقييم' : 'reviews';

  // ── Booking ───────────────────────────────────────────
  String get chooseDate => isArabic ? 'اختاري التاريخ' : 'Choose Date';
  String get chooseTime => isArabic ? 'اختاري الوقت' : 'Choose Time';
  String get proceedToPayment =>
      isArabic ? 'متابعة الدفع' : 'Proceed to Payment';
  String get price => isArabic ? 'السعر' : 'Price';
  String get bookingDetails => isArabic ? 'تفاصيل الحجز' : 'Booking Details';
  String get bookingNumber => isArabic ? 'رقم الحجز' : 'Booking #';
  String get date => isArabic ? 'التاريخ' : 'Date';
  String get time => isArabic ? 'الوقت' : 'Time';
  String get location => isArabic ? 'الموقع' : 'Location';
  String get notes => isArabic ? 'ملاحظات' : 'Notes';
  String get cancelBooking => isArabic ? 'إلغاء الحجز' : 'Cancel Booking';
  String get contactSupport => isArabic ? 'تواصلي مع الدعم' : 'Contact Support';
  String get confirmCancelTitle =>
      isArabic ? 'طلب إلغاء الحجز' : 'Cancel Booking';
  String get confirmCancelBody => isArabic
      ? 'متأكدة تبين تلغين الحجز؟'
      : 'Are you sure you want to cancel?';
  String get noBookingsYet => isArabic ? 'ما في حجوزات بعد' : 'No bookings yet';
  String get bookYourFavorite =>
      isArabic ? 'احجزي خدمتك المفضلة الحين' : 'Book your favorite service now';

  // ── Booking Status ────────────────────────────────────
  String get statusConfirmed => isArabic ? 'مؤكد' : 'Confirmed';
  String get statusPending => isArabic ? 'قيد الانتظار' : 'Pending';
  String get statusCancelled => isArabic ? 'ملغي' : 'Cancelled';
  String get statusCompleted => isArabic ? 'مكتمل' : 'Completed';

  // ── Payment ───────────────────────────────────────────
  String get payment => isArabic ? 'الدفع' : 'Payment';
  String get bookingSummary => isArabic ? 'ملخص الحجز' : 'Booking Summary';
  String get paymentMethod => isArabic ? 'طريقة الدفع' : 'Payment Method';
  String get creditCard => isArabic ? 'بطاقة ائتمان' : 'Credit Card';
  String get digitalWallet => isArabic ? 'المحفظة الرقمية' : 'Digital Wallet';
  String get payNow => isArabic ? 'ادفعي الحين' : 'Pay Now';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get total => isArabic ? 'الإجمالي' : 'Total';
  String get paymentSuccess =>
      isArabic ? 'تم الدفع وتأكيد الحجز 🎉' : 'Payment confirmed 🎉';

  // ── Confirmation ──────────────────────────────────────
  String get bookingSuccess =>
      isArabic ? 'تم الحجز بنجاح! 🎉' : 'Booking Confirmed! 🎉';
  String get waitingAtLamsa =>
      isArabic ? 'ننتظرك في لمسة' : 'We\'re waiting for you at Lamsa';
  String get service => isArabic ? 'الخدمة' : 'Service';
  String get therapist => isArabic ? 'المختصة' : 'Therapist';
  String get backToHome => isArabic ? 'الرجوع للرئيسية' : 'Back to Home';
  String get shareBooking => isArabic ? 'شاركي الحجز' : 'Share Booking';

  // ── Profile ───────────────────────────────────────────
  String get editProfile => isArabic ? 'تعديل الملف الشخصي' : 'Edit Profile';
  String get editName => isArabic ? 'تعديل الاسم' : 'Edit Name';
  String get yourName => isArabic ? 'اسمك' : 'Your name';
  String get save => isArabic ? 'حفظ' : 'Save';
  String get profileSection => isArabic ? 'الملف الشخصي' : 'Profile';
  String get servicesAndBenefits =>
      isArabic ? 'الخدمات والمزايا' : 'Services & Benefits';
  String get supportAndAlerts =>
      isArabic ? 'الدعم والتنبيهات' : 'Support & Alerts';
  String get myCoupons => isArabic ? 'كوبوناتي وعروضي' : 'My Coupons & Offers';
  String get notifications => isArabic ? 'الإشعارات' : 'Notifications';
  String get helpAndSupport => isArabic ? 'المساعدة والدعم' : 'Help & Support';
  String get logout => isArabic ? 'تسجيل الخروج' : 'Logout';
  String get logoutConfirmTitle => isArabic ? 'تسجيل الخروج' : 'Logout';
  String get logoutConfirmBody => isArabic
      ? 'متأكدة تبين تسجلين خروج؟'
      : 'Are you sure you want to logout?';
  String get yes => isArabic ? 'إي' : 'Yes';
  String get no => isArabic ? 'لا' : 'No';
  String get bookingsCount => isArabic ? 'الحجوزات' : 'Bookings';
  String get favorites => isArabic ? 'المفضلة' : 'Favorites';
  String get guest => isArabic ? 'ضيفة' : 'Guest';
  String get noFavorites =>
      isArabic ? 'ما في خدمات مفضلة' : 'No favorite services';
  String get addFavoritesHint => isArabic
      ? 'أضيفي خدماتك المفضلة من صفحة الخدمات'
      : 'Add your favorite services from the services page';

  // ── Notifications ─────────────────────────────────────
  String get noNotifications => isArabic ? 'ما في إشعارات' : 'No notifications';
  String get loginFirst => isArabic ? 'سجّلي دخولك أول' : 'Please login first';

  // ── Support ───────────────────────────────────────────
  String get support => isArabic ? 'الدعم' : 'Support';
  String get typeMessage => isArabic ? 'اكتبي رسالة...' : 'Type a message...';

  // ── Offers ────────────────────────────────────────────
  String get couponsAndOffers =>
      isArabic ? 'كوبوناتي وعروضي' : 'My Coupons & Offers';
  String get myCouponsTab => isArabic ? 'كوبوناتي' : 'My Coupons';
  String get offersTab => isArabic ? 'العروض' : 'Offers';
  String get noCoupons =>
      isArabic ? 'ما في كوبونات حالياً' : 'No coupons available';
  String get noOffers => isArabic ? 'ما في عروض حالياً' : 'No offers available';
  String get available => isArabic ? 'متاح' : 'Available';
  String get expired => isArabic ? 'منتهي' : 'Expired';
  String get copy => isArabic ? 'نسخ' : 'Copy';
  String get useOffer => isArabic ? 'استخدمي العرض' : 'Use Offer';
  String copiedCoupon(String code) =>
      isArabic ? 'تم نسخ الكوبون: $code' : 'Coupon copied: $code';

  // ── Common ────────────────────────────────────────────
  String get minutes => isArabic ? 'دقيقة' : 'min';
  String get sar => isArabic ? 'ر.س' : 'SAR';
  String get egp => isArabic ? 'ر.س' : 'SAR'; // kept for backward compat
  String get currency => isArabic ? 'ر.س' : 'SAR';
  String get useLanguage => isArabic ? 'تغيير اللغة' : 'Change Language';
  String get loadingError => isArabic ? 'صار خطأ في التحميل' : 'Loading error';
  String get retry => isArabic ? 'إعادة المحاولة' : 'Retry';
  String get errorOccurred => isArabic ? 'صار خطأ' : 'An error occurred';
  String get cancelledSuccess =>
      isArabic ? 'تم إلغاء الحجز' : 'Booking cancelled';
  String get bookingNotificationHint => isArabic
      ? 'بنرسل لك إشعار عند أي تحديث للحجز'
      : 'You\'ll be notified of any booking updates';
  String get expiresOn => isArabic ? 'ينتهي في' : 'Expires on';
  String get totalAmount => isArabic ? 'المبلغ الإجمالي' : 'Total Amount';
}
