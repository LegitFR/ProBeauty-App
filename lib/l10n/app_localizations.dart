import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt')
  ];

  /// No description provided for @decisionGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get decisionGreeting;

  /// No description provided for @decisionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account or login in to book and manage your appointments.'**
  String get decisionSubtitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @signupButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signupButton;

  /// No description provided for @signInWith.
  ///
  /// In en, this message translates to:
  /// **'Sign in with'**
  String get signInWith;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get loginWelcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in!'**
  String get loginSubtitle;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone number'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordHint;

  /// No description provided for @loginEmptyFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please enter email/phone and password'**
  String get loginEmptyFieldsError;

  /// No description provided for @loginSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccessMessage;

  /// No description provided for @loginFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailedMessage;

  /// Shown when an unexpected login error occurs
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String loginErrorMessage(String error);

  /// No description provided for @signupWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get signupWelcome;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up!'**
  String get signupSubtitle;

  /// No description provided for @signupFirstNameHint.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get signupFirstNameHint;

  /// No description provided for @signupLastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get signupLastNameHint;

  /// No description provided for @signupContactHint.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone number'**
  String get signupContactHint;

  /// No description provided for @signupPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signupPasswordHint;

  /// No description provided for @signupGetOtpButton.
  ///
  /// In en, this message translates to:
  /// **'Get OTP'**
  String get signupGetOtpButton;

  /// No description provided for @signupLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get signupLoginButton;

  /// No description provided for @signupAlreadyMember.
  ///
  /// In en, this message translates to:
  /// **'Already a member?'**
  String get signupAlreadyMember;

  /// No description provided for @signupOrText.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get signupOrText;

  /// No description provided for @signupWithText.
  ///
  /// In en, this message translates to:
  /// **'Sign up with'**
  String get signupWithText;

  /// No description provided for @signupEmptyFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get signupEmptyFieldsError;

  /// No description provided for @signupSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Signup successful!'**
  String get signupSuccessMessage;

  /// No description provided for @signupFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Signup failed'**
  String get signupFailedMessage;

  /// Shown when signup fails due to an unexpected error
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String signupErrorMessage(String error);

  /// No description provided for @bottomNavHome.
  ///
  /// In en, this message translates to:
  /// **'My Precut'**
  String get bottomNavHome;

  /// No description provided for @bottomNavExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get bottomNavExplore;

  /// No description provided for @bottomNavShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get bottomNavShop;

  /// No description provided for @bottomNavAppointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get bottomNavAppointments;

  /// No description provided for @bottomNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get bottomNavProfile;

  /// No description provided for @homeSpecialOffers.
  ///
  /// In en, this message translates to:
  /// **'Special Offers'**
  String get homeSpecialOffers;

  /// No description provided for @homeRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get homeRecommended;

  /// No description provided for @categoryHaircut.
  ///
  /// In en, this message translates to:
  /// **'Haircut'**
  String get categoryHaircut;

  /// No description provided for @categorySpa.
  ///
  /// In en, this message translates to:
  /// **'Spa'**
  String get categorySpa;

  /// No description provided for @categoryNails.
  ///
  /// In en, this message translates to:
  /// **'Nails'**
  String get categoryNails;

  /// No description provided for @categoryFacial.
  ///
  /// In en, this message translates to:
  /// **'Facial'**
  String get categoryFacial;

  /// No description provided for @homeSalonLabel.
  ///
  /// In en, this message translates to:
  /// **'Salon'**
  String get homeSalonLabel;

  /// Discount label shown on salon cards
  ///
  /// In en, this message translates to:
  /// **'Save up to {percent}%'**
  String homeSaveUpto(String percent);

  /// Number of reviews shown in parentheses
  ///
  /// In en, this message translates to:
  /// **'({count})'**
  String homeReviewCount(int count);

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTitle;

  /// No description provided for @exploreSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Any treatment or venue'**
  String get exploreSearchHint;

  /// No description provided for @exploreAnyDate.
  ///
  /// In en, this message translates to:
  /// **'Any date'**
  String get exploreAnyDate;

  /// No description provided for @exploreAnyTime.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get exploreAnyTime;

  /// No description provided for @exploreSearchButton.
  ///
  /// In en, this message translates to:
  /// **'Search Probeauty'**
  String get exploreSearchButton;

  /// No description provided for @exploreMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get exploreMorning;

  /// No description provided for @exploreAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get exploreAfternoon;

  /// No description provided for @exploreEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get exploreEvening;

  /// No description provided for @exploreSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get exploreSort;

  /// No description provided for @exploreMaxPrice.
  ///
  /// In en, this message translates to:
  /// **'Max price'**
  String get exploreMaxPrice;

  /// No description provided for @exploreVenueType.
  ///
  /// In en, this message translates to:
  /// **'Venue type'**
  String get exploreVenueType;

  /// Shows number of appointments booked today
  ///
  /// In en, this message translates to:
  /// **'{count} appointments booked today'**
  String exploreAppointmentsBooked(String count);

  /// No description provided for @exploreServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get exploreServices;

  /// No description provided for @exploreSortByTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get exploreSortByTitle;

  /// No description provided for @exploreSortRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get exploreSortRecommended;

  /// No description provided for @exploreSortTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top-rated'**
  String get exploreSortTopRated;

  /// No description provided for @exploreSortNearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get exploreSortNearest;

  /// No description provided for @exploreMaximumPrice.
  ///
  /// In en, this message translates to:
  /// **'Maximum price'**
  String get exploreMaximumPrice;

  /// No description provided for @exploreVenueEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get exploreVenueEveryone;

  /// No description provided for @exploreVenueMaleOnly.
  ///
  /// In en, this message translates to:
  /// **'Male only'**
  String get exploreVenueMaleOnly;

  /// No description provided for @exploreVenueFemaleOnly.
  ///
  /// In en, this message translates to:
  /// **'Female only'**
  String get exploreVenueFemaleOnly;

  /// No description provided for @exploreFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get exploreFiltersTitle;

  /// No description provided for @exploreClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get exploreClearAll;

  /// No description provided for @exploreApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get exploreApply;

  /// No description provided for @exploreDetectingLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get exploreDetectingLocation;

  /// No description provided for @shopSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get shopSearchHint;

  /// No description provided for @shopCategoryShampoo.
  ///
  /// In en, this message translates to:
  /// **'Shampoo'**
  String get shopCategoryShampoo;

  /// No description provided for @shopCategoryHairColour.
  ///
  /// In en, this message translates to:
  /// **'Hair Colour'**
  String get shopCategoryHairColour;

  /// No description provided for @shopCategoryConditioner.
  ///
  /// In en, this message translates to:
  /// **'Conditioner'**
  String get shopCategoryConditioner;

  /// No description provided for @shopCategoryHairOil.
  ///
  /// In en, this message translates to:
  /// **'Hair Oil'**
  String get shopCategoryHairOil;

  /// No description provided for @shopSpecialOffers.
  ///
  /// In en, this message translates to:
  /// **'Special offers'**
  String get shopSpecialOffers;

  /// No description provided for @shopNoProducts.
  ///
  /// In en, this message translates to:
  /// **'No products available.'**
  String get shopNoProducts;

  /// No description provided for @shopLoadingSalon.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get shopLoadingSalon;

  /// No description provided for @shopButton.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopButton;

  /// No description provided for @appointmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointmentsTitle;

  /// No description provided for @appointmentsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get appointmentsLoading;

  /// No description provided for @appointmentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bookings found'**
  String get appointmentsEmpty;

  /// No description provided for @appointmentsConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get appointmentsConfirmedTitle;

  /// No description provided for @appointmentsPreviousTitle.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get appointmentsPreviousTitle;

  /// No description provided for @appointmentsUnknownSalon.
  ///
  /// In en, this message translates to:
  /// **'Unknown Salon'**
  String get appointmentsUnknownSalon;

  /// No description provided for @appointmentsGetDirections.
  ///
  /// In en, this message translates to:
  /// **'Get directions'**
  String get appointmentsGetDirections;

  /// No description provided for @appointmentsBookAgain.
  ///
  /// In en, this message translates to:
  /// **'Book Again'**
  String get appointmentsBookAgain;

  /// Shows service duration, price and service name
  ///
  /// In en, this message translates to:
  /// **'{minutes} mins | ₹{price} | {service}'**
  String appointmentsDurationPriceService(
      int minutes, String price, String service);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEdit;

  /// No description provided for @profileDefaultUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get profileDefaultUser;

  /// No description provided for @profileMenuFavourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get profileMenuFavourites;

  /// No description provided for @profileMenuSavedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Saved addresses'**
  String get profileMenuSavedAddresses;

  /// No description provided for @profileMenuOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get profileMenuOrders;

  /// No description provided for @profileMenuPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get profileMenuPaymentMethods;

  /// No description provided for @profileMenuGiftCard.
  ///
  /// In en, this message translates to:
  /// **'Gift card'**
  String get profileMenuGiftCard;

  /// No description provided for @profileMenuNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileMenuNotifications;

  /// No description provided for @profileMenuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileMenuSettings;

  /// No description provided for @profileLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileLanguageEnglish;

  /// No description provided for @profileSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSupport;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile details'**
  String get profileEditTitle;

  /// No description provided for @profileFirstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get profileFirstNameLabel;

  /// No description provided for @profileLastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get profileLastNameLabel;

  /// No description provided for @profileMobileLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get profileMobileLabel;

  /// No description provided for @profileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get profileEmailLabel;

  /// No description provided for @profileDobLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get profileDobLabel;

  /// No description provided for @profileFirstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name required'**
  String get profileFirstNameRequired;

  /// No description provided for @profileInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get profileInvalidPhone;

  /// No description provided for @profileUserNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in'**
  String get profileUserNotLoggedIn;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdateSuccess;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get profileUpdateFailed;

  /// Shown when profile update API throws an error
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String profileUpdateError(String error);

  /// No description provided for @profileDayHint.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get profileDayHint;

  /// No description provided for @profileMonthHint.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get profileMonthHint;

  /// No description provided for @profileYearHint.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get profileYearHint;

  /// No description provided for @profileEmailOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Option'**
  String get profileEmailOptionLabel;

  /// No description provided for @profileSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSaveButton;

  /// No description provided for @profileLoading.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get profileLoading;

  /// No description provided for @favouritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favouritesTitle;

  /// No description provided for @favouritesLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please login to view favourites'**
  String get favouritesLoginRequired;

  /// No description provided for @favouritesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load favourites'**
  String get favouritesLoadFailed;

  /// No description provided for @favouritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No favourites yet'**
  String get favouritesEmpty;

  /// No description provided for @favouritesRemovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Removed from favourites'**
  String get favouritesRemovedSuccess;

  /// No description provided for @favouritesRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove favourite'**
  String get favouritesRemoveFailed;

  /// No description provided for @favouritesAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get favouritesAddToCart;

  /// No description provided for @favouritesAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get favouritesAddedToCart;

  /// No description provided for @favouritesAddToCartFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add to cart'**
  String get favouritesAddToCartFailed;

  /// No description provided for @favouritesLoginToAddCart.
  ///
  /// In en, this message translates to:
  /// **'Please login to add items to cart'**
  String get favouritesLoginToAddCart;

  /// Shown when an unexpected error occurs in favourites screen
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String favouritesError(String error);

  /// No description provided for @savedAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved addresses'**
  String get savedAddressTitle;

  /// No description provided for @savedAddressHomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get savedAddressHomeLabel;

  /// No description provided for @savedAddressAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add new address'**
  String get savedAddressAddNew;

  /// No description provided for @savedAddressHouseLabel.
  ///
  /// In en, this message translates to:
  /// **'House No & Floor *'**
  String get savedAddressHouseLabel;

  /// No description provided for @savedAddressBuildingLabel.
  ///
  /// In en, this message translates to:
  /// **'Building Name & Block no*'**
  String get savedAddressBuildingLabel;

  /// No description provided for @savedAddressLandmarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Area & Landmark *'**
  String get savedAddressLandmarkLabel;

  /// No description provided for @savedAddressCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City *'**
  String get savedAddressCityLabel;

  /// No description provided for @savedAddressDistrictLabel.
  ///
  /// In en, this message translates to:
  /// **'District *'**
  String get savedAddressDistrictLabel;

  /// No description provided for @savedAddressPincodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pincode*'**
  String get savedAddressPincodeLabel;

  /// No description provided for @savedAddressSaveAs.
  ///
  /// In en, this message translates to:
  /// **'Save this address as'**
  String get savedAddressSaveAs;

  /// No description provided for @savedAddressTypeHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get savedAddressTypeHome;

  /// No description provided for @savedAddressTypeWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get savedAddressTypeWork;

  /// No description provided for @savedAddressTypeOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get savedAddressTypeOthers;

  /// No description provided for @savedAddressSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get savedAddressSaveButton;

  /// No description provided for @savedAddressUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update Address'**
  String get savedAddressUpdateButton;

  /// No description provided for @savedAddressSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address saved successfully!'**
  String get savedAddressSavedSuccess;

  /// No description provided for @savedAddressUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address updated successfully!'**
  String get savedAddressUpdatedSuccess;

  /// Shown when saving or updating address fails
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String savedAddressFailed(String error);

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @ordersActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get ordersActiveTitle;

  /// No description provided for @ordersLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get ordersLoading;

  /// No description provided for @ordersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No active orders'**
  String get ordersEmpty;

  /// No description provided for @ordersOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String ordersOrderLabel(Object id);

  /// No description provided for @ordersDeliveryOn.
  ///
  /// In en, this message translates to:
  /// **'Delivery on —'**
  String get ordersDeliveryOn;

  /// Shows total price and item count in an order
  ///
  /// In en, this message translates to:
  /// **'₹{price} ({quantity} item)'**
  String ordersItemPrice(num price, int quantity);

  /// No description provided for @ordersTrackButton.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get ordersTrackButton;

  /// No description provided for @ordersCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get ordersCancelButton;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// Shows number of unread notifications
  ///
  /// In en, this message translates to:
  /// **'Unread ({count})'**
  String notificationsUnreadCount(int count);

  /// No description provided for @notificationAppointmentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment Success'**
  String get notificationAppointmentSuccessTitle;

  /// No description provided for @notificationAppointmentScheduledMessage.
  ///
  /// In en, this message translates to:
  /// **'Your appointment has been successfully scheduled with Dr. Meera at 4:30 PM...'**
  String get notificationAppointmentScheduledMessage;

  /// No description provided for @notificationAppointmentConfirmedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your appointment has been successfully confirmed for tomorrow...'**
  String get notificationAppointmentConfirmedMessage;

  /// No description provided for @notificationTimeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notificationTimeJustNow;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettingsTitle;

  /// No description provided for @notificationSettingAppointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Text message appointment'**
  String get notificationSettingAppointmentTitle;

  /// No description provided for @notificationSettingAppointmentDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive texts based on your sender’s settings'**
  String get notificationSettingAppointmentDesc;

  /// No description provided for @notificationSettingEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Marketing'**
  String get notificationSettingEmailTitle;

  /// No description provided for @notificationSettingEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive offers and news via email'**
  String get notificationSettingEmailDesc;

  /// No description provided for @notificationSettingOrderSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Order and Support'**
  String get notificationSettingOrderSupportTitle;

  /// No description provided for @notificationSettingOrderSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications related to your order status, payments and support communications'**
  String get notificationSettingOrderSupportDesc;

  /// No description provided for @notificationSettingWhatsappTitle.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Messages'**
  String get notificationSettingWhatsappTitle;

  /// No description provided for @notificationSettingWhatsappDesc.
  ///
  /// In en, this message translates to:
  /// **'Get updates from us on WhatsApp'**
  String get notificationSettingWhatsappDesc;

  /// No description provided for @appointmentInfoSalonTitle.
  ///
  /// In en, this message translates to:
  /// **'Essensuals by Toni & Guy'**
  String get appointmentInfoSalonTitle;

  /// No description provided for @appointmentStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get appointmentStatusConfirmed;

  /// Shows appointment date and time
  ///
  /// In en, this message translates to:
  /// **'{date} at\n{time}'**
  String appointmentDateTime(String date, String time);

  /// Shows appointment duration in hours
  ///
  /// In en, this message translates to:
  /// **'{hours} hour duration'**
  String appointmentDuration(int hours);

  /// No description provided for @appointmentActionAddCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to Calendar'**
  String get appointmentActionAddCalendar;

  /// No description provided for @appointmentActionAddCalendarDesc.
  ///
  /// In en, this message translates to:
  /// **'Set yourself a reminder'**
  String get appointmentActionAddCalendarDesc;

  /// No description provided for @appointmentActionManage.
  ///
  /// In en, this message translates to:
  /// **'Manage appointment'**
  String get appointmentActionManage;

  /// No description provided for @appointmentActionManageDesc.
  ///
  /// In en, this message translates to:
  /// **'Reschedule or Cancel'**
  String get appointmentActionManageDesc;

  /// No description provided for @appointmentActionGettingThere.
  ///
  /// In en, this message translates to:
  /// **'Getting there'**
  String get appointmentActionGettingThere;

  /// Location of the salon
  ///
  /// In en, this message translates to:
  /// **'{location}'**
  String appointmentActionGettingThereDesc(String location);

  /// No description provided for @appointmentActionVenueDetails.
  ///
  /// In en, this message translates to:
  /// **'Venue details'**
  String get appointmentActionVenueDetails;

  /// Salon or venue name
  ///
  /// In en, this message translates to:
  /// **'{venueName}'**
  String appointmentActionVenueDetailsDesc(String venueName);

  /// No description provided for @appointmentOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get appointmentOverviewTitle;

  /// No description provided for @appointmentServiceName.
  ///
  /// In en, this message translates to:
  /// **'{serviceName}'**
  String appointmentServiceName(Object serviceName);

  /// Service price
  ///
  /// In en, this message translates to:
  /// **'{currency}{price}'**
  String appointmentServicePrice(String currency, num price);

  /// Service duration
  ///
  /// In en, this message translates to:
  /// **'{duration} hour'**
  String appointmentServiceDuration(int duration);

  /// No description provided for @appointmentTaxes.
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get appointmentTaxes;

  /// No description provided for @appointmentTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get appointmentTotal;

  /// No description provided for @appointmentPayAtVenue.
  ///
  /// In en, this message translates to:
  /// **'Pay at venue'**
  String get appointmentPayAtVenue;

  /// Shows salon closing time
  ///
  /// In en, this message translates to:
  /// **'Open until {time}'**
  String salonOpenUntil(String time);

  /// No description provided for @salonTabServices.
  ///
  /// In en, this message translates to:
  /// **'SERVICES'**
  String get salonTabServices;

  /// No description provided for @salonTabReviews.
  ///
  /// In en, this message translates to:
  /// **'REVIEWS'**
  String get salonTabReviews;

  /// No description provided for @salonTabTeam.
  ///
  /// In en, this message translates to:
  /// **'TEAM'**
  String get salonTabTeam;

  /// No description provided for @salonTabGiftCards.
  ///
  /// In en, this message translates to:
  /// **'GIFT CARDS'**
  String get salonTabGiftCards;

  /// No description provided for @salonTabDetails.
  ///
  /// In en, this message translates to:
  /// **'DETAILS'**
  String get salonTabDetails;

  /// Service duration in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} mins'**
  String salonServiceDuration(int minutes);

  /// Shows number of services available in a salon
  ///
  /// In en, this message translates to:
  /// **'{count} services available'**
  String salonServicesAvailable(int count);

  /// No description provided for @salonBookNow.
  ///
  /// In en, this message translates to:
  /// **'Book now'**
  String get salonBookNow;

  /// No description provided for @salonBookButton.
  ///
  /// In en, this message translates to:
  /// **'BOOK'**
  String get salonBookButton;

  /// No description provided for @reviewsTabServices.
  ///
  /// In en, this message translates to:
  /// **'SERVICES'**
  String get reviewsTabServices;

  /// No description provided for @reviewsTabReviews.
  ///
  /// In en, this message translates to:
  /// **'REVIEWS'**
  String get reviewsTabReviews;

  /// No description provided for @reviewsTabTeam.
  ///
  /// In en, this message translates to:
  /// **'TEAM'**
  String get reviewsTabTeam;

  /// No description provided for @reviewsTabGiftCards.
  ///
  /// In en, this message translates to:
  /// **'GIFT CARDS'**
  String get reviewsTabGiftCards;

  /// No description provided for @reviewsTabDetails.
  ///
  /// In en, this message translates to:
  /// **'DETAILS'**
  String get reviewsTabDetails;

  /// No description provided for @reviewsUnableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load reviews'**
  String get reviewsUnableToLoad;

  /// No description provided for @reviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsTitle;

  /// Shows total number of reviews
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String reviewsTotalCount(int count);

  /// No description provided for @reviewsVerifiedUser.
  ///
  /// In en, this message translates to:
  /// **'Verified precut user'**
  String get reviewsVerifiedUser;

  /// No description provided for @reviewsInfoNote.
  ///
  /// In en, this message translates to:
  /// **'Precut guarantees that reviews with \"verified precut user\" tag have been added by registered precut users who have had an appointment with the provider. A registered precut user can add a review only after the service has been provided.'**
  String get reviewsInfoNote;

  /// Shows reviewed service name
  ///
  /// In en, this message translates to:
  /// **'Service: {service}'**
  String reviewsServiceLabel(String service);

  /// No description provided for @reviewsBookNow.
  ///
  /// In en, this message translates to:
  /// **'Book now'**
  String get reviewsBookNow;

  /// No description provided for @reviewsReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reviewsReport;

  /// No description provided for @reviewsUserFallback.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get reviewsUserFallback;

  /// No description provided for @reviewsServiceFallback.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get reviewsServiceFallback;

  /// No description provided for @reviewsMonthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get reviewsMonthJan;

  /// No description provided for @reviewsMonthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get reviewsMonthFeb;

  /// No description provided for @reviewsMonthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get reviewsMonthMar;

  /// No description provided for @reviewsMonthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get reviewsMonthApr;

  /// No description provided for @reviewsMonthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get reviewsMonthMay;

  /// No description provided for @reviewsMonthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get reviewsMonthJun;

  /// No description provided for @reviewsMonthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get reviewsMonthJul;

  /// No description provided for @reviewsMonthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get reviewsMonthAug;

  /// No description provided for @reviewsMonthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get reviewsMonthSep;

  /// No description provided for @reviewsMonthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get reviewsMonthOct;

  /// No description provided for @reviewsMonthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get reviewsMonthNov;

  /// No description provided for @reviewsMonthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get reviewsMonthDec;

  /// No description provided for @selectServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Services'**
  String get selectServicesTitle;

  /// No description provided for @selectServicesFeaturedCategory.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get selectServicesFeaturedCategory;

  /// No description provided for @selectServicesContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get selectServicesContinue;

  /// Service duration in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} mins'**
  String selectServicesDuration(int minutes);

  /// Service price
  ///
  /// In en, this message translates to:
  /// **'₹{price}'**
  String selectServicesPrice(num price);

  /// No description provided for @selectProfessionalTitle.
  ///
  /// In en, this message translates to:
  /// **'Select professional'**
  String get selectProfessionalTitle;

  /// No description provided for @selectProfessionalFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get selectProfessionalFallbackName;

  /// No description provided for @bookAppointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Book an appointment'**
  String get bookAppointmentTitle;

  /// Displayed month and year above the calendar
  ///
  /// In en, this message translates to:
  /// **'{monthYear}'**
  String bookAppointmentMonthYear(String monthYear);

  /// No description provided for @bookAppointmentLoadingSlots.
  ///
  /// In en, this message translates to:
  /// **'Loading slots...'**
  String get bookAppointmentLoadingSlots;

  /// No description provided for @bookAppointmentWeekMon.
  ///
  /// In en, this message translates to:
  /// **'Mo'**
  String get bookAppointmentWeekMon;

  /// No description provided for @bookAppointmentWeekTue.
  ///
  /// In en, this message translates to:
  /// **'Tu'**
  String get bookAppointmentWeekTue;

  /// No description provided for @bookAppointmentWeekWed.
  ///
  /// In en, this message translates to:
  /// **'We'**
  String get bookAppointmentWeekWed;

  /// No description provided for @bookAppointmentWeekThu.
  ///
  /// In en, this message translates to:
  /// **'Th'**
  String get bookAppointmentWeekThu;

  /// No description provided for @bookAppointmentWeekFri.
  ///
  /// In en, this message translates to:
  /// **'Fr'**
  String get bookAppointmentWeekFri;

  /// No description provided for @bookAppointmentWeekSat.
  ///
  /// In en, this message translates to:
  /// **'Sa'**
  String get bookAppointmentWeekSat;

  /// No description provided for @bookAppointmentWeekSun.
  ///
  /// In en, this message translates to:
  /// **'Su'**
  String get bookAppointmentWeekSun;

  /// Asks user if this is their first visit to the salon
  ///
  /// In en, this message translates to:
  /// **'Is this your first visit to\n{salonName}?'**
  String firstVisitTitle(String salonName);

  /// No description provided for @firstVisitYesTitle.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get firstVisitYesTitle;

  /// No description provided for @firstVisitYesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is my first visit'**
  String get firstVisitYesSubtitle;

  /// No description provided for @firstVisitNoTitle.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get firstVisitNoTitle;

  /// No description provided for @firstVisitNoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I\'ve visited before'**
  String get firstVisitNoSubtitle;

  /// No description provided for @reviewConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Review and Confirm'**
  String get reviewConfirmTitle;

  /// No description provided for @reviewConfirmBookingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed successfully 🎉'**
  String get reviewConfirmBookingSuccess;

  /// No description provided for @reviewConfirmGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get reviewConfirmGenericError;

  /// No description provided for @reviewConfirmAuthError.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get reviewConfirmAuthError;

  /// No description provided for @reviewConfirmStaffUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Selected staff is not available at this time. Please choose another slot.'**
  String get reviewConfirmStaffUnavailable;

  /// No description provided for @reviewConfirmSalonAddress.
  ///
  /// In en, this message translates to:
  /// **'Anna Nagar, Chennai'**
  String get reviewConfirmSalonAddress;

  /// Shows appointment start and end time
  ///
  /// In en, this message translates to:
  /// **'{startTime} - {endTime}'**
  String reviewConfirmTimeRange(String startTime, String endTime);

  /// Shows selected appointment date
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String reviewConfirmDate(String date);

  /// Service duration in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} mins'**
  String reviewConfirmServiceDuration(int minutes);

  /// No description provided for @reviewConfirmTaxes.
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get reviewConfirmTaxes;

  /// No description provided for @reviewConfirmTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get reviewConfirmTotal;

  /// No description provided for @reviewConfirmPayNow.
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get reviewConfirmPayNow;

  /// No description provided for @reviewConfirmPayAtVenue.
  ///
  /// In en, this message translates to:
  /// **'Pay at venue'**
  String get reviewConfirmPayAtVenue;

  /// Bottom bar total price and service count
  ///
  /// In en, this message translates to:
  /// **'{currency}{amount}\n{count} service'**
  String reviewConfirmBottomSummary(String currency, int amount, int count);

  /// No description provided for @reviewConfirmConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get reviewConfirmConfirmButton;

  /// No description provided for @reviewConfirmBookingFailed.
  ///
  /// In en, this message translates to:
  /// **'Booking failed'**
  String get reviewConfirmBookingFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
