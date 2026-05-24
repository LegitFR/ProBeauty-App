// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get decisionGreeting => '¡Hola!';

  @override
  String get decisionSubtitle =>
      'Crea tu cuenta o inicia sesión para reservar y gestionar tus citas.';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get signupButton => 'Registrarse';

  @override
  String get signInWith => 'Iniciar sesión con';

  @override
  String get continueAsGuest => 'Continuar como invitado';

  @override
  String get loginWelcomeBack => 'Bienvenido de nuevo,';

  @override
  String get loginSubtitle => '¡Inicia sesión!';

  @override
  String get loginEmailHint => 'Correo electrónico o número de teléfono';

  @override
  String get loginPasswordHint => 'Contraseña';

  @override
  String get loginEmptyFieldsError =>
      'Por favor ingresa correo/teléfono y contraseña';

  @override
  String get loginSuccessMessage => '¡Inicio de sesión exitoso!';

  @override
  String get loginFailedMessage => 'Error al iniciar sesión';

  @override
  String loginErrorMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get signupWelcome => 'Bienvenido,';

  @override
  String get signupSubtitle => '¡Regístrate!';

  @override
  String get signupFirstNameHint => 'Nombre';

  @override
  String get signupLastNameHint => 'Apellido';

  @override
  String get signupContactHint => 'Correo electrónico o número de teléfono';

  @override
  String get signupPasswordHint => 'Contraseña';

  @override
  String get signupGetOtpButton => 'Obtener OTP';

  @override
  String get signupLoginButton => 'Iniciar sesión';

  @override
  String get signupAlreadyMember => '¿Ya eres miembro?';

  @override
  String get signupOrText => 'O';

  @override
  String get signupWithText => 'Regístrate con';

  @override
  String get signupEmptyFieldsError => 'Por favor completa todos los campos';

  @override
  String get signupSuccessMessage => '¡Registro exitoso!';

  @override
  String get signupFailedMessage => 'Error en el registro';

  @override
  String signupErrorMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get bottomNavHome => 'Mi Precut';

  @override
  String get bottomNavExplore => 'Explorar';

  @override
  String get bottomNavShop => 'Tienda';

  @override
  String get bottomNavAppointments => 'Citas';

  @override
  String get bottomNavProfile => 'Perfil';

  @override
  String get homeSpecialOffers => 'Ofertas especiales';

  @override
  String get homeRecommended => 'Recomendado';

  @override
  String get categoryHaircut => 'Corte de cabello';

  @override
  String get categorySpa => 'Spa';

  @override
  String get categoryNails => 'Uñas';

  @override
  String get categoryFacial => 'Facial';

  @override
  String get homeSalonLabel => 'Salón';

  @override
  String homeSaveUpto(String percent) {
    return 'Ahorra hasta $percent%';
  }

  @override
  String homeReviewCount(int count) {
    return '($count)';
  }

  @override
  String get exploreTitle => 'Explorar';

  @override
  String get exploreSearchHint => 'Cualquier tratamiento o lugar';

  @override
  String get exploreAnyDate => 'Cualquier fecha';

  @override
  String get exploreAnyTime => 'Cualquier hora';

  @override
  String get exploreSearchButton => 'Buscar Probeauty';

  @override
  String get exploreMorning => 'Mañana';

  @override
  String get exploreAfternoon => 'Tarde';

  @override
  String get exploreEvening => 'Noche';

  @override
  String get exploreSort => 'Ordenar';

  @override
  String get exploreMaxPrice => 'Precio máximo';

  @override
  String get exploreVenueType => 'Tipo de lugar';

  @override
  String exploreAppointmentsBooked(String count) {
    return '$count citas reservadas hoy';
  }

  @override
  String get exploreServices => 'Servicios';

  @override
  String get exploreSortByTitle => 'Ordenar por';

  @override
  String get exploreSortRecommended => 'Recomendado';

  @override
  String get exploreSortTopRated => 'Mejor valorado';

  @override
  String get exploreSortNearest => 'Más cercano';

  @override
  String get exploreMaximumPrice => 'Precio máximo';

  @override
  String get exploreVenueEveryone => 'Todos';

  @override
  String get exploreVenueMaleOnly => 'Solo hombres';

  @override
  String get exploreVenueFemaleOnly => 'Solo mujeres';

  @override
  String get exploreFiltersTitle => 'Filtros';

  @override
  String get exploreClearAll => 'Borrar todo';

  @override
  String get exploreApply => 'Aplicar';

  @override
  String get exploreDetectingLocation => 'Detectando ubicación...';

  @override
  String get shopSearchHint => 'Buscar';

  @override
  String get shopCategoryShampoo => 'Champú';

  @override
  String get shopCategoryHairColour => 'Color de cabello';

  @override
  String get shopCategoryConditioner => 'Acondicionador';

  @override
  String get shopCategoryHairOil => 'Aceite capilar';

  @override
  String get shopSpecialOffers => 'Ofertas especiales';

  @override
  String get shopNoProducts => 'No hay productos disponibles.';

  @override
  String get shopLoadingSalon => 'Cargando...';

  @override
  String get shopButton => 'Comprar';

  @override
  String get appointmentsTitle => 'Citas';

  @override
  String get appointmentsLoading => 'Cargando...';

  @override
  String get appointmentsEmpty => 'No se encontraron reservas';

  @override
  String get appointmentsConfirmedTitle => 'Confirmadas';

  @override
  String get appointmentsPreviousTitle => 'Anteriores';

  @override
  String get appointmentsUnknownSalon => 'Salón desconocido';

  @override
  String get appointmentsGetDirections => 'Obtener direcciones';

  @override
  String get appointmentsBookAgain => 'Reservar de nuevo';

  @override
  String appointmentsDurationPriceService(
      int minutes, String price, String service) {
    return '$minutes min | ₹$price | $service';
  }

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileEdit => 'Editar perfil';

  @override
  String get profileDefaultUser => 'Usuario';

  @override
  String get profileMenuFavourites => 'Favoritos';

  @override
  String get profileMenuSavedAddresses => 'Direcciones guardadas';

  @override
  String get profileMenuOrders => 'Pedidos';

  @override
  String get profileMenuPaymentMethods => 'Métodos de pago';

  @override
  String get profileMenuGiftCard => 'Tarjeta regalo';

  @override
  String get profileMenuNotifications => 'Notificaciones';

  @override
  String get profileMenuSettings => 'Configuración';

  @override
  String get profileLanguageEnglish => 'Inglés';

  @override
  String get profileSupport => 'Soporte';

  @override
  String get profileLogout => 'Cerrar sesión';

  @override
  String get profileEditTitle => 'Editar detalles del perfil';

  @override
  String get profileFirstNameLabel => 'Nombre';

  @override
  String get profileLastNameLabel => 'Apellido';

  @override
  String get profileMobileLabel => 'Número de móvil';

  @override
  String get profileEmailLabel => 'Correo electrónico';

  @override
  String get profileDobLabel => 'Fecha de nacimiento';

  @override
  String get profileFirstNameRequired => 'Nombre requerido';

  @override
  String get profileInvalidPhone => 'Número de teléfono inválido';

  @override
  String get profileUserNotLoggedIn => 'Usuario no autenticado';

  @override
  String get profileUpdateSuccess => '¡Perfil actualizado con éxito!';

  @override
  String get profileUpdateFailed => 'Error al actualizar';

  @override
  String profileUpdateError(String error) {
    return 'Error: $error';
  }

  @override
  String get profileDayHint => 'Día';

  @override
  String get profileMonthHint => 'Mes';

  @override
  String get profileYearHint => 'Año';

  @override
  String get profileEmailOptionLabel => 'Seleccionar opción';

  @override
  String get profileSaveButton => 'Guardar';

  @override
  String get profileLoading => 'Guardando...';

  @override
  String get favouritesTitle => 'Favoritos';

  @override
  String get favouritesLoginRequired => 'Inicia sesión para ver favoritos';

  @override
  String get favouritesLoadFailed => 'Error al cargar favoritos';

  @override
  String get favouritesEmpty => 'Aún no hay favoritos';

  @override
  String get favouritesRemovedSuccess => 'Eliminado de favoritos';

  @override
  String get favouritesRemoveFailed => 'Error al eliminar favorito';

  @override
  String get favouritesAddToCart => 'Añadir al carrito';

  @override
  String get favouritesAddedToCart => 'Añadido al carrito';

  @override
  String get favouritesAddToCartFailed => 'Error al añadir al carrito';

  @override
  String get favouritesLoginToAddCart => 'Inicia sesión para añadir al carrito';

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

  @override
  String get salonAddedToFavourites => 'Añadido a favoritos';

  @override
  String get salonAddToFavouritesFailed => 'Error al añadir a favoritos';
}
