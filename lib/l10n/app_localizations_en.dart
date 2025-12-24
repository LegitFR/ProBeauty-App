// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get decisionGreeting => 'Hello!';

  @override
  String get decisionSubtitle =>
      'Create your account or login in to book and manage your appointments.';

  @override
  String get loginButton => 'Login';

  @override
  String get signupButton => 'Sign Up';

  @override
  String get signInWith => 'Sign in with';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get loginWelcomeBack => 'Welcome back,';

  @override
  String get loginSubtitle => 'Log in!';

  @override
  String get loginEmailHint => 'Email or Phone number';

  @override
  String get loginPasswordHint => 'Password';

  @override
  String get loginEmptyFieldsError => 'Please enter email/phone and password';

  @override
  String get loginSuccessMessage => 'Login successful!';

  @override
  String get loginFailedMessage => 'Login failed';

  @override
  String loginErrorMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get signupWelcome => 'Welcome,';

  @override
  String get signupSubtitle => 'Sign up!';

  @override
  String get signupFirstNameHint => 'First Name';

  @override
  String get signupLastNameHint => 'Last Name';

  @override
  String get signupContactHint => 'Email or Phone number';

  @override
  String get signupPasswordHint => 'Password';

  @override
  String get signupGetOtpButton => 'Get OTP';

  @override
  String get signupLoginButton => 'Login';

  @override
  String get signupAlreadyMember => 'Already a member?';

  @override
  String get signupOrText => 'OR';

  @override
  String get signupWithText => 'Sign up with';

  @override
  String get signupEmptyFieldsError => 'Please fill all fields';

  @override
  String get signupSuccessMessage => 'Signup successful!';

  @override
  String get signupFailedMessage => 'Signup failed';

  @override
  String signupErrorMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get bottomNavHome => 'My Precut';

  @override
  String get bottomNavExplore => 'Explore';

  @override
  String get bottomNavShop => 'Shop';

  @override
  String get bottomNavAppointments => 'Appointments';

  @override
  String get bottomNavProfile => 'Profile';

  @override
  String get homeSpecialOffers => 'Special Offers';

  @override
  String get homeRecommended => 'Recommended';

  @override
  String get categoryHaircut => 'Haircut';

  @override
  String get categorySpa => 'Spa';

  @override
  String get categoryNails => 'Nails';

  @override
  String get categoryFacial => 'Facial';

  @override
  String get homeSalonLabel => 'Salon';

  @override
  String homeSaveUpto(String percent) {
    return 'Save up to $percent%';
  }

  @override
  String homeReviewCount(int count) {
    return '($count)';
  }

  @override
  String get exploreTitle => 'Explore';

  @override
  String get exploreSearchHint => 'Any treatment or venue';

  @override
  String get exploreAnyDate => 'Any date';

  @override
  String get exploreAnyTime => 'Any time';

  @override
  String get exploreSearchButton => 'Search Probeauty';

  @override
  String get exploreMorning => 'Morning';

  @override
  String get exploreAfternoon => 'Afternoon';

  @override
  String get exploreEvening => 'Evening';

  @override
  String get exploreSort => 'Sort';

  @override
  String get exploreMaxPrice => 'Max price';

  @override
  String get exploreVenueType => 'Venue type';

  @override
  String exploreAppointmentsBooked(String count) {
    return '$count appointments booked today';
  }

  @override
  String get exploreServices => 'Services';

  @override
  String get exploreSortByTitle => 'Sort by';

  @override
  String get exploreSortRecommended => 'Recommended';

  @override
  String get exploreSortTopRated => 'Top-rated';

  @override
  String get exploreSortNearest => 'Nearest';

  @override
  String get exploreMaximumPrice => 'Maximum price';

  @override
  String get exploreVenueEveryone => 'Everyone';

  @override
  String get exploreVenueMaleOnly => 'Male only';

  @override
  String get exploreVenueFemaleOnly => 'Female only';

  @override
  String get exploreFiltersTitle => 'Filters';

  @override
  String get exploreClearAll => 'Clear all';

  @override
  String get exploreApply => 'Apply';

  @override
  String get exploreDetectingLocation => 'Detecting location...';

  @override
  String get shopSearchHint => 'Search';

  @override
  String get shopCategoryShampoo => 'Shampoo';

  @override
  String get shopCategoryHairColour => 'Hair Colour';

  @override
  String get shopCategoryConditioner => 'Conditioner';

  @override
  String get shopCategoryHairOil => 'Hair Oil';

  @override
  String get shopSpecialOffers => 'Special offers';

  @override
  String get shopNoProducts => 'No products available.';

  @override
  String get shopLoadingSalon => 'Loading...';

  @override
  String get shopButton => 'Shop';

  @override
  String get appointmentsTitle => 'Appointments';

  @override
  String get appointmentsLoading => 'Loading...';

  @override
  String get appointmentsEmpty => 'No bookings found';

  @override
  String get appointmentsConfirmedTitle => 'Confirmed';

  @override
  String get appointmentsPreviousTitle => 'Previous';

  @override
  String get appointmentsUnknownSalon => 'Unknown Salon';

  @override
  String get appointmentsGetDirections => 'Get directions';

  @override
  String get appointmentsBookAgain => 'Book Again';

  @override
  String appointmentsDurationPriceService(
      int minutes, String price, String service) {
    return '$minutes mins | ₹$price | $service';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileDefaultUser => 'User';

  @override
  String get profileMenuFavourites => 'Favourites';

  @override
  String get profileMenuSavedAddresses => 'Saved addresses';

  @override
  String get profileMenuOrders => 'Orders';

  @override
  String get profileMenuPaymentMethods => 'Payment methods';

  @override
  String get profileMenuGiftCard => 'Gift card';

  @override
  String get profileMenuNotifications => 'Notifications';

  @override
  String get profileMenuSettings => 'Settings';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get profileSupport => 'Support';

  @override
  String get profileLogout => 'Logout';

  @override
  String get profileEditTitle => 'Edit profile details';

  @override
  String get profileFirstNameLabel => 'First Name';

  @override
  String get profileLastNameLabel => 'Last Name';

  @override
  String get profileMobileLabel => 'Mobile number';

  @override
  String get profileEmailLabel => 'Email Address';

  @override
  String get profileDobLabel => 'Date of birth';

  @override
  String get profileFirstNameRequired => 'First name required';

  @override
  String get profileInvalidPhone => 'Invalid phone number';

  @override
  String get profileUserNotLoggedIn => 'User not logged in';

  @override
  String get profileUpdateSuccess => 'Profile updated successfully!';

  @override
  String get profileUpdateFailed => 'Update failed';

  @override
  String profileUpdateError(String error) {
    return 'Error: $error';
  }

  @override
  String get profileDayHint => 'Day';

  @override
  String get profileMonthHint => 'Month';

  @override
  String get profileYearHint => 'Year';

  @override
  String get profileEmailOptionLabel => 'Select Option';

  @override
  String get profileSaveButton => 'Save';

  @override
  String get profileLoading => 'Saving...';

  @override
  String get favouritesTitle => 'Favourites';

  @override
  String get favouritesLoginRequired => 'Please login to view favourites';

  @override
  String get favouritesLoadFailed => 'Failed to load favourites';

  @override
  String get favouritesEmpty => 'No favourites yet';

  @override
  String get favouritesRemovedSuccess => 'Removed from favourites';

  @override
  String get favouritesRemoveFailed => 'Failed to remove favourite';

  @override
  String get favouritesAddToCart => 'Add to cart';

  @override
  String get favouritesAddedToCart => 'Added to cart';

  @override
  String get favouritesAddToCartFailed => 'Failed to add to cart';

  @override
  String get favouritesLoginToAddCart => 'Please login to add items to cart';

  @override
  String favouritesError(String error) {
    return 'Error: $error';
  }

  @override
  String get savedAddressTitle => 'Saved addresses';

  @override
  String get savedAddressHomeLabel => 'Home';

  @override
  String get savedAddressAddNew => 'Add new address';

  @override
  String get savedAddressHouseLabel => 'House No & Floor *';

  @override
  String get savedAddressBuildingLabel => 'Building Name & Block no*';

  @override
  String get savedAddressLandmarkLabel => 'Area & Landmark *';

  @override
  String get savedAddressCityLabel => 'City *';

  @override
  String get savedAddressDistrictLabel => 'District *';

  @override
  String get savedAddressPincodeLabel => 'Pincode*';

  @override
  String get savedAddressSaveAs => 'Save this address as';

  @override
  String get savedAddressTypeHome => 'Home';

  @override
  String get savedAddressTypeWork => 'Work';

  @override
  String get savedAddressTypeOthers => 'Others';

  @override
  String get savedAddressSaveButton => 'Save';

  @override
  String get savedAddressUpdateButton => 'Update Address';

  @override
  String get savedAddressSavedSuccess => 'Address saved successfully!';

  @override
  String get savedAddressUpdatedSuccess => 'Address updated successfully!';

  @override
  String savedAddressFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get ordersTitle => 'Orders';

  @override
  String get ordersActiveTitle => 'Active Orders';

  @override
  String get ordersLoading => 'Loading...';

  @override
  String get ordersEmpty => 'No active orders';

  @override
  String ordersOrderLabel(Object id) {
    return 'Order #$id';
  }

  @override
  String get ordersDeliveryOn => 'Delivery on —';

  @override
  String ordersItemPrice(num price, int quantity) {
    return '₹$price ($quantity item)';
  }

  @override
  String get ordersTrackButton => 'Track';

  @override
  String get ordersCancelButton => 'Cancel Order';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String notificationsUnreadCount(int count) {
    return 'Unread ($count)';
  }

  @override
  String get notificationAppointmentSuccessTitle => 'Appointment Success';

  @override
  String get notificationAppointmentScheduledMessage =>
      'Your appointment has been successfully scheduled with Dr. Meera at 4:30 PM...';

  @override
  String get notificationAppointmentConfirmedMessage =>
      'Your appointment has been successfully confirmed for tomorrow...';

  @override
  String get notificationTimeJustNow => 'Just now';

  @override
  String get notificationSettingsTitle => 'Notification Settings';

  @override
  String get notificationSettingAppointmentTitle => 'Text message appointment';

  @override
  String get notificationSettingAppointmentDesc =>
      'Receive texts based on your sender’s settings';

  @override
  String get notificationSettingEmailTitle => 'Email Marketing';

  @override
  String get notificationSettingEmailDesc =>
      'Receive offers and news via email';

  @override
  String get notificationSettingOrderSupportTitle => 'Order and Support';

  @override
  String get notificationSettingOrderSupportDesc =>
      'Receive notifications related to your order status, payments and support communications';

  @override
  String get notificationSettingWhatsappTitle => 'WhatsApp Messages';

  @override
  String get notificationSettingWhatsappDesc =>
      'Get updates from us on WhatsApp';

  @override
  String get appointmentInfoSalonTitle => 'Essensuals by Toni & Guy';

  @override
  String get appointmentStatusConfirmed => 'Confirmed';

  @override
  String appointmentDateTime(String date, String time) {
    return '$date at\n$time';
  }

  @override
  String appointmentDuration(int hours) {
    return '$hours hour duration';
  }

  @override
  String get appointmentActionAddCalendar => 'Add to Calendar';

  @override
  String get appointmentActionAddCalendarDesc => 'Set yourself a reminder';

  @override
  String get appointmentActionManage => 'Manage appointment';

  @override
  String get appointmentActionManageDesc => 'Reschedule or Cancel';

  @override
  String get appointmentActionGettingThere => 'Getting there';

  @override
  String appointmentActionGettingThereDesc(String location) {
    return '$location';
  }

  @override
  String get appointmentActionVenueDetails => 'Venue details';

  @override
  String appointmentActionVenueDetailsDesc(String venueName) {
    return '$venueName';
  }

  @override
  String get appointmentOverviewTitle => 'Overview';

  @override
  String appointmentServiceName(Object serviceName) {
    return '$serviceName';
  }

  @override
  String appointmentServicePrice(String currency, num price) {
    return '$currency$price';
  }

  @override
  String appointmentServiceDuration(int duration) {
    return '$duration hour';
  }

  @override
  String get appointmentTaxes => 'Taxes';

  @override
  String get appointmentTotal => 'Total';

  @override
  String get appointmentPayAtVenue => 'Pay at venue';

  @override
  String salonOpenUntil(String time) {
    return 'Open until $time';
  }

  @override
  String get salonTabServices => 'SERVICES';

  @override
  String get salonTabReviews => 'REVIEWS';

  @override
  String get salonTabTeam => 'TEAM';

  @override
  String get salonTabGiftCards => 'GIFT CARDS';

  @override
  String get salonTabDetails => 'DETAILS';

  @override
  String salonServiceDuration(int minutes) {
    return '$minutes mins';
  }

  @override
  String salonServicesAvailable(int count) {
    return '$count services available';
  }

  @override
  String get salonBookNow => 'Book now';

  @override
  String get salonBookButton => 'BOOK';

  @override
  String get reviewsTabServices => 'SERVICES';

  @override
  String get reviewsTabReviews => 'REVIEWS';

  @override
  String get reviewsTabTeam => 'TEAM';

  @override
  String get reviewsTabGiftCards => 'GIFT CARDS';

  @override
  String get reviewsTabDetails => 'DETAILS';

  @override
  String get reviewsUnableToLoad => 'Unable to load reviews';

  @override
  String get reviewsTitle => 'Reviews';

  @override
  String reviewsTotalCount(int count) {
    return '$count reviews';
  }

  @override
  String get reviewsVerifiedUser => 'Verified precut user';

  @override
  String get reviewsInfoNote =>
      'Precut guarantees that reviews with \"verified precut user\" tag have been added by registered precut users who have had an appointment with the provider. A registered precut user can add a review only after the service has been provided.';

  @override
  String reviewsServiceLabel(String service) {
    return 'Service: $service';
  }

  @override
  String get reviewsBookNow => 'Book now';

  @override
  String get reviewsReport => 'Report';

  @override
  String get reviewsUserFallback => 'User';

  @override
  String get reviewsServiceFallback => 'Service';

  @override
  String get reviewsMonthJan => 'Jan';

  @override
  String get reviewsMonthFeb => 'Feb';

  @override
  String get reviewsMonthMar => 'Mar';

  @override
  String get reviewsMonthApr => 'Apr';

  @override
  String get reviewsMonthMay => 'May';

  @override
  String get reviewsMonthJun => 'Jun';

  @override
  String get reviewsMonthJul => 'Jul';

  @override
  String get reviewsMonthAug => 'Aug';

  @override
  String get reviewsMonthSep => 'Sep';

  @override
  String get reviewsMonthOct => 'Oct';

  @override
  String get reviewsMonthNov => 'Nov';

  @override
  String get reviewsMonthDec => 'Dec';

  @override
  String get selectServicesTitle => 'Select Services';

  @override
  String get selectServicesFeaturedCategory => 'Featured';

  @override
  String get selectServicesContinue => 'Continue';

  @override
  String selectServicesDuration(int minutes) {
    return '$minutes mins';
  }

  @override
  String selectServicesPrice(num price) {
    return '₹$price';
  }

  @override
  String get selectProfessionalTitle => 'Select professional';

  @override
  String get selectProfessionalFallbackName => 'Staff';

  @override
  String get bookAppointmentTitle => 'Book an appointment';

  @override
  String bookAppointmentMonthYear(String monthYear) {
    return '$monthYear';
  }

  @override
  String get bookAppointmentLoadingSlots => 'Loading slots...';

  @override
  String get bookAppointmentWeekMon => 'Mo';

  @override
  String get bookAppointmentWeekTue => 'Tu';

  @override
  String get bookAppointmentWeekWed => 'We';

  @override
  String get bookAppointmentWeekThu => 'Th';

  @override
  String get bookAppointmentWeekFri => 'Fr';

  @override
  String get bookAppointmentWeekSat => 'Sa';

  @override
  String get bookAppointmentWeekSun => 'Su';

  @override
  String firstVisitTitle(String salonName) {
    return 'Is this your first visit to\n$salonName?';
  }

  @override
  String get firstVisitYesTitle => 'Yes';

  @override
  String get firstVisitYesSubtitle => 'This is my first visit';

  @override
  String get firstVisitNoTitle => 'No';

  @override
  String get firstVisitNoSubtitle => 'I\'ve visited before';

  @override
  String get reviewConfirmTitle => 'Review and Confirm';

  @override
  String get reviewConfirmBookingSuccess => 'Booking confirmed successfully 🎉';

  @override
  String get reviewConfirmGenericError =>
      'Something went wrong. Please try again.';

  @override
  String get reviewConfirmAuthError => 'User not authenticated';

  @override
  String get reviewConfirmStaffUnavailable =>
      'Selected staff is not available at this time. Please choose another slot.';

  @override
  String get reviewConfirmSalonAddress => 'Anna Nagar, Chennai';

  @override
  String reviewConfirmTimeRange(String startTime, String endTime) {
    return '$startTime - $endTime';
  }

  @override
  String reviewConfirmDate(String date) {
    return '$date';
  }

  @override
  String reviewConfirmServiceDuration(int minutes) {
    return '$minutes mins';
  }

  @override
  String get reviewConfirmTaxes => 'Taxes';

  @override
  String get reviewConfirmTotal => 'Total';

  @override
  String get reviewConfirmPayNow => 'Pay now';

  @override
  String get reviewConfirmPayAtVenue => 'Pay at venue';

  @override
  String reviewConfirmBottomSummary(String currency, int amount, int count) {
    return '$currency$amount\n$count service';
  }

  @override
  String get reviewConfirmConfirmButton => 'Confirm';

  @override
  String get reviewConfirmBookingFailed => 'Booking failed';
}
