// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get decisionGreeting => 'Olá!';

  @override
  String get decisionSubtitle =>
      'Crie sua conta ou faça login para reservar e gerenciar seus compromissos.';

  @override
  String get loginButton => 'Entrar';

  @override
  String get signupButton => 'Cadastrar';

  @override
  String get signInWith => 'Entrar com';

  @override
  String get continueAsGuest => 'Continuar como convidado';

  @override
  String get loginWelcomeBack => 'Bem-vindo de volta,';

  @override
  String get loginSubtitle => 'Entrar!';

  @override
  String get loginEmailHint => 'E-mail ou número de telefone';

  @override
  String get loginPasswordHint => 'Senha';

  @override
  String get loginEmptyFieldsError =>
      'Por favor, insira e-mail/telefone e senha';

  @override
  String get loginSuccessMessage => 'Login realizado com sucesso!';

  @override
  String get loginFailedMessage => 'Falha no login';

  @override
  String loginErrorMessage(String error) {
    return 'Erro: $error';
  }

  @override
  String get signupWelcome => 'Bem-vindo,';

  @override
  String get signupSubtitle => 'Cadastrar!';

  @override
  String get signupFirstNameHint => 'Nome';

  @override
  String get signupLastNameHint => 'Sobrenome';

  @override
  String get signupContactHint => 'E-mail ou número de telefone';

  @override
  String get signupPasswordHint => 'Senha';

  @override
  String get signupGetOtpButton => 'Obter OTP';

  @override
  String get signupLoginButton => 'Entrar';

  @override
  String get signupAlreadyMember => 'Já é membro?';

  @override
  String get signupOrText => 'OU';

  @override
  String get signupWithText => 'Cadastre-se com';

  @override
  String get signupEmptyFieldsError => 'Por favor, preencha todos os campos';

  @override
  String get signupSuccessMessage => 'Cadastro realizado com sucesso!';

  @override
  String get signupFailedMessage => 'Falha no cadastro';

  @override
  String signupErrorMessage(String error) {
    return 'Erro: $error';
  }

  @override
  String get bottomNavHome => 'Meu Precut';

  @override
  String get bottomNavExplore => 'Explorar';

  @override
  String get bottomNavShop => 'Loja';

  @override
  String get bottomNavAppointments => 'Compromissos';

  @override
  String get bottomNavProfile => 'Perfil';

  @override
  String get homeSpecialOffers => 'Ofertas especiais';

  @override
  String get homeRecommended => 'Recomendado';

  @override
  String get categoryHaircut => 'Corte de cabelo';

  @override
  String get categorySpa => 'Spa';

  @override
  String get categoryNails => 'Unhas';

  @override
  String get categoryFacial => 'Facial';

  @override
  String get homeSalonLabel => 'Salão';

  @override
  String homeSaveUpto(String percent) {
    return 'Economize até $percent%';
  }

  @override
  String homeReviewCount(int count) {
    return '($count)';
  }

  @override
  String get exploreTitle => 'Explorar';

  @override
  String get exploreSearchHint => 'Qualquer tratamento ou local';

  @override
  String get exploreAnyDate => 'Qualquer data';

  @override
  String get exploreAnyTime => 'Qualquer horário';

  @override
  String get exploreSearchButton => 'Buscar Probeauty';

  @override
  String get exploreMorning => 'Manhã';

  @override
  String get exploreAfternoon => 'Tarde';

  @override
  String get exploreEvening => 'Noite';

  @override
  String get exploreSort => 'Ordenar';

  @override
  String get exploreMaxPrice => 'Preço máximo';

  @override
  String get exploreVenueType => 'Tipo de local';

  @override
  String exploreAppointmentsBooked(String count) {
    return '$count compromissos reservados hoje';
  }

  @override
  String get exploreServices => 'Serviços';

  @override
  String get exploreSortByTitle => 'Ordenar por';

  @override
  String get exploreSortRecommended => 'Recomendado';

  @override
  String get exploreSortTopRated => 'Mais bem avaliados';

  @override
  String get exploreSortNearest => 'Mais próximos';

  @override
  String get exploreMaximumPrice => 'Preço máximo';

  @override
  String get exploreVenueEveryone => 'Todos';

  @override
  String get exploreVenueMaleOnly => 'Somente homens';

  @override
  String get exploreVenueFemaleOnly => 'Somente mulheres';

  @override
  String get exploreFiltersTitle => 'Filtros';

  @override
  String get exploreClearAll => 'Limpar tudo';

  @override
  String get exploreApply => 'Aplicar';

  @override
  String get exploreDetectingLocation => 'Detectando localização...';

  @override
  String get shopSearchHint => 'Pesquisar';

  @override
  String get shopCategoryShampoo => 'Shampoo';

  @override
  String get shopCategoryHairColour => 'Tintura de cabelo';

  @override
  String get shopCategoryConditioner => 'Condicionador';

  @override
  String get shopCategoryHairOil => 'Óleo capilar';

  @override
  String get shopSpecialOffers => 'Ofertas especiais';

  @override
  String get shopNoProducts => 'Nenhum produto disponível.';

  @override
  String get shopLoadingSalon => 'Carregando...';

  @override
  String get shopButton => 'Comprar';

  @override
  String get appointmentsTitle => 'Compromissos';

  @override
  String get appointmentsLoading => 'Carregando...';

  @override
  String get appointmentsEmpty => 'Nenhuma reserva encontrada';

  @override
  String get appointmentsConfirmedTitle => 'Confirmados';

  @override
  String get appointmentsPreviousTitle => 'Anteriores';

  @override
  String get appointmentsUnknownSalon => 'Salão desconhecido';

  @override
  String get appointmentsGetDirections => 'Obter direções';

  @override
  String get appointmentsBookAgain => 'Reservar novamente';

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
  String get profileDefaultUser => 'Usuário';

  @override
  String get profileMenuFavourites => 'Favoritos';

  @override
  String get profileMenuSavedAddresses => 'Endereços salvos';

  @override
  String get profileMenuOrders => 'Pedidos';

  @override
  String get profileMenuPaymentMethods => 'Métodos de pagamento';

  @override
  String get profileMenuGiftCard => 'Cartão presente';

  @override
  String get profileMenuNotifications => 'Notificações';

  @override
  String get profileMenuSettings => 'Configurações';

  @override
  String get profileLanguageEnglish => 'Inglês';

  @override
  String get profileSupport => 'Suporte';

  @override
  String get profileLogout => 'Sair';

  @override
  String get profileEditTitle => 'Editar detalhes do perfil';

  @override
  String get profileFirstNameLabel => 'Nome';

  @override
  String get profileLastNameLabel => 'Sobrenome';

  @override
  String get profileMobileLabel => 'Número de celular';

  @override
  String get profileEmailLabel => 'Endereço de e-mail';

  @override
  String get profileDobLabel => 'Data de nascimento';

  @override
  String get profileFirstNameRequired => 'Nome é obrigatório';

  @override
  String get profileInvalidPhone => 'Número de telefone inválido';

  @override
  String get profileUserNotLoggedIn => 'Usuário não autenticado';

  @override
  String get profileUpdateSuccess => 'Perfil atualizado com sucesso!';

  @override
  String get profileUpdateFailed => 'Falha na atualização';

  @override
  String profileUpdateError(String error) {
    return 'Erro: $error';
  }

  @override
  String get profileDayHint => 'Dia';

  @override
  String get profileMonthHint => 'Mês';

  @override
  String get profileYearHint => 'Ano';

  @override
  String get profileEmailOptionLabel => 'Selecionar opção';

  @override
  String get profileSaveButton => 'Salvar';

  @override
  String get profileLoading => 'Salvando...';

  @override
  String get favouritesTitle => 'Favoritos';

  @override
  String get favouritesLoginRequired => 'Faça login para ver os favoritos';

  @override
  String get favouritesLoadFailed => 'Falha ao carregar favoritos';

  @override
  String get favouritesEmpty => 'Nenhum favorito ainda';

  @override
  String get favouritesRemovedSuccess => 'Removido dos favoritos';

  @override
  String get favouritesRemoveFailed => 'Falha ao remover favorito';

  @override
  String get favouritesAddToCart => 'Adicionar ao carrinho';

  @override
  String get favouritesAddedToCart => 'Adicionado ao carrinho';

  @override
  String get favouritesAddToCartFailed => 'Falha ao adicionar ao carrinho';

  @override
  String get favouritesLoginToAddCart =>
      'Faça login para adicionar itens ao carrinho';

  @override
  String favouritesError(String error) {
    return 'Erro: $error';
  }

  @override
  String get savedAddressTitle => 'Endereços salvos';

  @override
  String get savedAddressHomeLabel => 'Casa';

  @override
  String get savedAddressAddNew => 'Adicionar novo endereço';

  @override
  String get savedAddressHouseLabel => 'Número da casa e andar *';

  @override
  String get savedAddressBuildingLabel => 'Nome do prédio e bloco *';

  @override
  String get savedAddressLandmarkLabel => 'Área e ponto de referência *';

  @override
  String get savedAddressCityLabel => 'Cidade *';

  @override
  String get savedAddressDistrictLabel => 'Distrito *';

  @override
  String get savedAddressPincodeLabel => 'CEP *';

  @override
  String get savedAddressSaveAs => 'Salvar este endereço como';

  @override
  String get savedAddressTypeHome => 'Casa';

  @override
  String get savedAddressTypeWork => 'Trabalho';

  @override
  String get savedAddressTypeOthers => 'Outros';

  @override
  String get savedAddressSaveButton => 'Salvar';

  @override
  String get savedAddressUpdateButton => 'Atualizar endereço';

  @override
  String get savedAddressSavedSuccess => 'Endereço salvo com sucesso!';

  @override
  String get savedAddressUpdatedSuccess => 'Endereço atualizado com sucesso!';

  @override
  String savedAddressFailed(String error) {
    return 'Falha: $error';
  }

  @override
  String get ordersTitle => 'Pedidos';

  @override
  String get ordersActiveTitle => 'Pedidos ativos';

  @override
  String get ordersLoading => 'Carregando...';

  @override
  String get ordersEmpty => 'Nenhum pedido ativo';

  @override
  String ordersOrderLabel(Object id) {
    return 'Pedido #$id';
  }

  @override
  String get ordersDeliveryOn => 'Entrega em —';

  @override
  String ordersItemPrice(num price, int quantity) {
    return '₹$price ($quantity item)';
  }

  @override
  String get ordersTrackButton => 'Rastrear';

  @override
  String get ordersCancelButton => 'Cancelar pedido';

  @override
  String get notificationsTitle => 'Notificações';

  @override
  String notificationsUnreadCount(int count) {
    return 'Não lidas ($count)';
  }

  @override
  String get notificationAppointmentSuccessTitle => 'Compromisso confirmado';

  @override
  String get notificationAppointmentScheduledMessage =>
      'Seu compromisso foi agendado com sucesso com a Dra. Meera às 16:30...';

  @override
  String get notificationAppointmentConfirmedMessage =>
      'Seu compromisso foi confirmado com sucesso para amanhã...';

  @override
  String get notificationTimeJustNow => 'Agora mesmo';

  @override
  String get notificationSettingsTitle => 'Configurações de notificações';

  @override
  String get notificationSettingAppointmentTitle =>
      'Mensagem de texto de compromisso';

  @override
  String get notificationSettingAppointmentDesc =>
      'Receba mensagens de texto com base nas configurações do remetente';

  @override
  String get notificationSettingEmailTitle => 'Marketing por e-mail';

  @override
  String get notificationSettingEmailDesc =>
      'Receba ofertas e novidades por e-mail';

  @override
  String get notificationSettingOrderSupportTitle => 'Pedidos e suporte';

  @override
  String get notificationSettingOrderSupportDesc =>
      'Receba notificações sobre status do pedido, pagamentos e suporte';

  @override
  String get notificationSettingWhatsappTitle => 'Mensagens do WhatsApp';

  @override
  String get notificationSettingWhatsappDesc =>
      'Receba atualizações pelo WhatsApp';

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
