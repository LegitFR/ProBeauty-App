// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get decisionGreeting => 'Bonjour !';

  @override
  String get decisionSubtitle =>
      'Créez votre compte ou connectez-vous pour réserver et gérer vos rendez-vous.';

  @override
  String get loginButton => 'Connexion';

  @override
  String get signupButton => 'S\'inscrire';

  @override
  String get signInWith => 'Se connecter avec';

  @override
  String get continueAsGuest => 'Continuer en tant qu\'invité';

  @override
  String get loginWelcomeBack => 'Bon retour,';

  @override
  String get loginSubtitle => 'Connexion !';

  @override
  String get loginEmailHint => 'E-mail ou numéro de téléphone';

  @override
  String get loginPasswordHint => 'Mot de passe';

  @override
  String get loginEmptyFieldsError =>
      'Veuillez saisir l’e-mail/le téléphone et le mot de passe';

  @override
  String get loginSuccessMessage => 'Connexion réussie !';

  @override
  String get loginFailedMessage => 'Échec de la connexion';

  @override
  String loginErrorMessage(String error) {
    return 'Erreur : $error';
  }

  @override
  String get signupWelcome => 'Bienvenue,';

  @override
  String get signupSubtitle => 'Inscription !';

  @override
  String get signupFirstNameHint => 'Prénom';

  @override
  String get signupLastNameHint => 'Nom';

  @override
  String get signupContactHint => 'E-mail ou numéro de téléphone';

  @override
  String get signupPasswordHint => 'Mot de passe';

  @override
  String get signupGetOtpButton => 'Obtenir le code OTP';

  @override
  String get signupLoginButton => 'Connexion';

  @override
  String get signupAlreadyMember => 'Déjà membre ?';

  @override
  String get signupOrText => 'OU';

  @override
  String get signupWithText => 'S\'inscrire avec';

  @override
  String get signupEmptyFieldsError => 'Veuillez remplir tous les champs';

  @override
  String get signupSuccessMessage => 'Inscription réussie !';

  @override
  String get signupFailedMessage => 'Échec de l\'inscription';

  @override
  String signupErrorMessage(String error) {
    return 'Erreur : $error';
  }

  @override
  String get bottomNavHome => 'Mon Precut';

  @override
  String get bottomNavExplore => 'Explorer';

  @override
  String get bottomNavShop => 'Boutique';

  @override
  String get bottomNavAppointments => 'Rendez-vous';

  @override
  String get bottomNavProfile => 'Profil';

  @override
  String get homeSpecialOffers => 'Offres spéciales';

  @override
  String get homeRecommended => 'Recommandé';

  @override
  String get categoryHaircut => 'Coupe de cheveux';

  @override
  String get categorySpa => 'Spa';

  @override
  String get categoryNails => 'Ongles';

  @override
  String get categoryFacial => 'Soin du visage';

  @override
  String get homeSalonLabel => 'Salon';

  @override
  String homeSaveUpto(String percent) {
    return 'Économisez jusqu’à $percent %';
  }

  @override
  String homeReviewCount(int count) {
    return '($count)';
  }

  @override
  String get exploreTitle => 'Explorer';

  @override
  String get exploreSearchHint => 'Tout soin ou établissement';

  @override
  String get exploreAnyDate => 'N\'importe quelle date';

  @override
  String get exploreAnyTime => 'N\'importe quelle heure';

  @override
  String get exploreSearchButton => 'Rechercher sur Probeauty';

  @override
  String get exploreMorning => 'Matin';

  @override
  String get exploreAfternoon => 'Après-midi';

  @override
  String get exploreEvening => 'Soir';

  @override
  String get exploreSort => 'Trier';

  @override
  String get exploreMaxPrice => 'Prix maximum';

  @override
  String get exploreVenueType => 'Type d’établissement';

  @override
  String exploreAppointmentsBooked(String count) {
    return '$count rendez-vous réservés aujourd\'hui';
  }

  @override
  String get exploreServices => 'Services';

  @override
  String get exploreSortByTitle => 'Trier par';

  @override
  String get exploreSortRecommended => 'Recommandé';

  @override
  String get exploreSortTopRated => 'Les mieux notés';

  @override
  String get exploreSortNearest => 'Les plus proches';

  @override
  String get exploreMaximumPrice => 'Prix maximum';

  @override
  String get exploreVenueEveryone => 'Tout le monde';

  @override
  String get exploreVenueMaleOnly => 'Hommes uniquement';

  @override
  String get exploreVenueFemaleOnly => 'Femmes uniquement';

  @override
  String get exploreFiltersTitle => 'Filtres';

  @override
  String get exploreClearAll => 'Tout effacer';

  @override
  String get exploreApply => 'Appliquer';

  @override
  String get exploreDetectingLocation => 'Détection de la localisation...';

  @override
  String get shopSearchHint => 'Rechercher';

  @override
  String get shopCategoryShampoo => 'Shampooing';

  @override
  String get shopCategoryHairColour => 'Coloration';

  @override
  String get shopCategoryConditioner => 'Après-shampooing';

  @override
  String get shopCategoryHairOil => 'Huile capillaire';

  @override
  String get shopSpecialOffers => 'Offres spéciales';

  @override
  String get shopNoProducts => 'Aucun produit disponible.';

  @override
  String get shopLoadingSalon => 'Chargement...';

  @override
  String get shopButton => 'Acheter';

  @override
  String get appointmentsTitle => 'Rendez-vous';

  @override
  String get appointmentsLoading => 'Chargement...';

  @override
  String get appointmentsEmpty => 'Aucune réservation trouvée';

  @override
  String get appointmentsConfirmedTitle => 'Confirmé';

  @override
  String get appointmentsPreviousTitle => 'Précédent';

  @override
  String get appointmentsUnknownSalon => 'Salon inconnu';

  @override
  String get appointmentsGetDirections => 'Obtenir l’itinéraire';

  @override
  String get appointmentsBookAgain => 'Réserver à nouveau';

  @override
  String appointmentsDurationPriceService(
      int minutes, String price, String service) {
    return '$minutes min | ₹$price | $service';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileEdit => 'Modifier le profil';

  @override
  String get profileDefaultUser => 'Utilisateur';

  @override
  String get profileMenuFavourites => 'Favoris';

  @override
  String get profileMenuSavedAddresses => 'Adresses enregistrées';

  @override
  String get profileMenuOrders => 'Commandes';

  @override
  String get profileMenuPaymentMethods => 'Moyens de paiement';

  @override
  String get profileMenuGiftCard => 'Carte cadeau';

  @override
  String get profileMenuNotifications => 'Notifications';

  @override
  String get profileMenuSettings => 'Paramètres';

  @override
  String get profileLanguageEnglish => 'Anglais';

  @override
  String get profileSupport => 'Support';

  @override
  String get profileLogout => 'Déconnexion';

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
  String get savedAddressTitle => 'Adresses enregistrées';

  @override
  String get savedAddressHomeLabel => 'Home';

  @override
  String get savedAddressAddNew => 'Ajouter une nouvelle adresse';

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
  String get ordersTitle => 'Commandes';

  @override
  String get ordersActiveTitle => 'Commandes actives';

  @override
  String get ordersLoading => 'Chargement...';

  @override
  String get ordersEmpty => 'Aucune commande active';

  @override
  String ordersOrderLabel(Object id) {
    return 'Commande n°$id';
  }

  @override
  String get ordersDeliveryOn => 'Livraison le —';

  @override
  String ordersItemPrice(num price, int quantity) {
    return '₹$price ($quantity article)';
  }

  @override
  String get ordersTrackButton => 'Suivre';

  @override
  String get ordersCancelButton => 'Annuler la commande';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String notificationsUnreadCount(int count) {
    return 'Non lues ($count)';
  }

  @override
  String get notificationAppointmentSuccessTitle => 'Rendez-vous réussi';

  @override
  String get notificationAppointmentScheduledMessage =>
      'Votre rendez-vous a été programmé avec succès avec le Dr Meera à 16h30...';

  @override
  String get notificationAppointmentConfirmedMessage =>
      'Votre rendez-vous a été confirmé avec succès pour demain...';

  @override
  String get notificationTimeJustNow => 'À l\'instant';

  @override
  String get notificationSettingsTitle => 'Paramètres des notifications';

  @override
  String get notificationSettingAppointmentTitle => 'Rendez-vous par SMS';

  @override
  String get notificationSettingAppointmentDesc =>
      'Recevez des messages selon les paramètres de l’expéditeur';

  @override
  String get notificationSettingEmailTitle => 'Marketing par e-mail';

  @override
  String get notificationSettingEmailDesc =>
      'Recevez des offres et des actualités par e-mail';

  @override
  String get notificationSettingOrderSupportTitle => 'Commandes et support';

  @override
  String get notificationSettingOrderSupportDesc =>
      'Recevez des notifications concernant vos commandes, paiements et communications de support';

  @override
  String get notificationSettingWhatsappTitle => 'Messages WhatsApp';

  @override
  String get notificationSettingWhatsappDesc =>
      'Recevez des mises à jour via WhatsApp';

  @override
  String get appointmentInfoSalonTitle => 'Essensuals by Toni & Guy';

  @override
  String get appointmentStatusConfirmed => 'Confirmé';

  @override
  String appointmentDateTime(String date, String time) {
    return '$date at\n$time';
  }

  @override
  String appointmentDuration(int hours) {
    return '$hours hour duration';
  }

  @override
  String get appointmentActionAddCalendar => 'Ajouter au calendrier';

  @override
  String get appointmentActionAddCalendarDesc => 'Définir un rappel';

  @override
  String get appointmentActionManage => 'Gérer le rendez-vous';

  @override
  String get appointmentActionManageDesc => 'Reprogrammer ou annuler';

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
  String get appointmentOverviewTitle => 'Aperçu';

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
  String get appointmentPayAtVenue => 'Payer sur place';

  @override
  String salonOpenUntil(String time) {
    return 'Ouvert jusqu’à $time';
  }

  @override
  String get salonTabServices => 'SERVICES';

  @override
  String get salonTabReviews => 'AVIS';

  @override
  String get salonTabTeam => 'ÉQUIPE';

  @override
  String get salonTabGiftCards => 'CARTES CADEAUX';

  @override
  String get salonTabDetails => 'DÉTAILS';

  @override
  String salonServiceDuration(int minutes) {
    return '$minutes mins';
  }

  @override
  String salonServicesAvailable(int count) {
    return '$count services disponibles';
  }

  @override
  String get salonBookNow => 'Réserver maintenant';

  @override
  String get salonBookButton => 'RÉSERVER';

  @override
  String get reviewsTabServices => 'SERVICES';

  @override
  String get reviewsTabReviews => 'AVIS';

  @override
  String get reviewsTabTeam => 'ÉQUIPE';

  @override
  String get reviewsTabGiftCards => 'CARTES CADEAUX';

  @override
  String get reviewsTabDetails => 'DÉTAILS';

  @override
  String get reviewsUnableToLoad => 'Impossible de charger les avis';

  @override
  String get reviewsTitle => 'Avis';

  @override
  String reviewsTotalCount(int count) {
    return '$count avis';
  }

  @override
  String get reviewsVerifiedUser => 'Utilisateur Precut vérifié';

  @override
  String get reviewsInfoNote =>
      'Precut guarantees that reviews with \"verified precut user\" tag have been added by registered precut users who have had an appointment with the provider. A registered precut user can add a review only after the service has been provided.';

  @override
  String reviewsServiceLabel(String service) {
    return 'Service: $service';
  }

  @override
  String get reviewsBookNow => 'Réserver maintenant';

  @override
  String get reviewsReport => 'Signaler';

  @override
  String get reviewsUserFallback => 'Utilisateur';

  @override
  String get reviewsServiceFallback => 'Service';

  @override
  String get reviewsMonthJan => 'Jan';

  @override
  String get reviewsMonthFeb => 'Fév';

  @override
  String get reviewsMonthMar => 'Mar';

  @override
  String get reviewsMonthApr => 'Avr';

  @override
  String get reviewsMonthMay => 'Mai';

  @override
  String get reviewsMonthJun => 'Juin';

  @override
  String get reviewsMonthJul => 'Juil';

  @override
  String get reviewsMonthAug => 'Août';

  @override
  String get reviewsMonthSep => 'Sep';

  @override
  String get reviewsMonthOct => 'Oct';

  @override
  String get reviewsMonthNov => 'Nov';

  @override
  String get reviewsMonthDec => 'Déc';

  @override
  String get selectServicesTitle => 'Sélectionner des services';

  @override
  String get selectServicesFeaturedCategory => 'En vedette';

  @override
  String get selectServicesContinue => 'Continuer';

  @override
  String selectServicesDuration(int minutes) {
    return '$minutes min';
  }

  @override
  String selectServicesPrice(num price) {
    return '₹$price';
  }

  @override
  String get selectProfessionalTitle => 'Sélectionner un professionnel';

  @override
  String get selectProfessionalFallbackName => 'Personnel';

  @override
  String get bookAppointmentTitle => 'Prendre un rendez-vous';

  @override
  String bookAppointmentMonthYear(String monthYear) {
    return '$monthYear';
  }

  @override
  String get bookAppointmentLoadingSlots => 'Chargement des créneaux...';

  @override
  String get bookAppointmentWeekMon => 'Lu';

  @override
  String get bookAppointmentWeekTue => 'Ma';

  @override
  String get bookAppointmentWeekWed => 'Me';

  @override
  String get bookAppointmentWeekThu => 'Je';

  @override
  String get bookAppointmentWeekFri => 'Ve';

  @override
  String get bookAppointmentWeekSat => 'Sa';

  @override
  String get bookAppointmentWeekSun => 'Di';

  @override
  String firstVisitTitle(String salonName) {
    return 'Est-ce votre première visite chez\n$salonName ?';
  }

  @override
  String get firstVisitYesTitle => 'Oui';

  @override
  String get firstVisitYesSubtitle => 'C’est ma première visite';

  @override
  String get firstVisitNoTitle => 'Non';

  @override
  String get firstVisitNoSubtitle => 'J’y suis déjà allé(e)';

  @override
  String get reviewConfirmTitle => 'Vérifier et confirmer';

  @override
  String get reviewConfirmBookingSuccess =>
      'Réservation confirmée avec succès 🎉';

  @override
  String get reviewConfirmGenericError =>
      'Une erreur s’est produite. Veuillez réessayer.';

  @override
  String get reviewConfirmAuthError => 'Utilisateur non authentifié';

  @override
  String get reviewConfirmStaffUnavailable =>
      'Le professionnel sélectionné n’est pas disponible à ce créneau. Veuillez choisir un autre horaire.';

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
    return '$minutes min';
  }

  @override
  String get reviewConfirmTaxes => 'Taxes';

  @override
  String get reviewConfirmTotal => 'Total';

  @override
  String get reviewConfirmPayNow => 'Payer maintenant';

  @override
  String get reviewConfirmPayAtVenue => 'Payer sur place';

  @override
  String reviewConfirmBottomSummary(String currency, int amount, int count) {
    return '$currency$amount\n$count service';
  }

  @override
  String get reviewConfirmConfirmButton => 'Confirmer';

  @override
  String get reviewConfirmBookingFailed => 'Échec de la réservation';

  @override
  String get reviewsAddYourReview => 'Add your review';

  @override
  String get reviewsWriteHere => 'Write your experience...';

  @override
  String get reviewsSubmit => 'Submit review';

  @override
  String get reviewsThankYou => 'Thanks for your feedback!';

  @override
  String get appointmentsSeeAll => 'See all';

  @override
  String get appointmentsShowLess => 'Show less';
}
