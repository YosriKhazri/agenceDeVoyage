class DatabaseConstants {
  // Database
  static const String databaseName = 'travel_agency.db';
  static const int databaseVersion = 3;

  // Table Names
  static const String tableDestinations = 'destinations';
  static const String tableClients = 'clients';
  static const String tableReservations = 'reservations';
  static const String tableReviews = 'reviews';
  static const String tableAdditionalServices = 'additional_services';
  static const String tableReservationServices = 'reservation_services';

  // Common Columns
  static const String columnId = 'id';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  // Destinations Table Columns
  static const String columnDestinationName = 'name';
  static const String columnDestinationCountry = 'country';
  static const String columnDestinationCity = 'city';
  static const String columnDestinationImageUrl = 'image_url';
  static const String columnDestinationDescription = 'description';
  static const String columnDestinationBasePrice = 'base_price';

  // Clients Table Columns
  static const String columnClientFirstName = 'first_name';
  static const String columnClientLastName = 'last_name';
  static const String columnClientEmail = 'email';
  static const String columnClientUsername = 'username';
  static const String columnClientPassword = 'password';
  static const String columnClientRole = 'role';
  static const String columnClientAuthToken = 'auth_token';
  static const String columnClientPassportNumber = 'passport_number';
  static const String columnClientPhone = 'phone';
  static const String columnClientAddress = 'address';

  // Reservations Table Columns
  static const String columnReservationClientId = 'client_id';
  static const String columnReservationDestinationId = 'destination_id';
  static const String columnReservationDepartureDate = 'departure_date';
  static const String columnReservationReturnDate = 'return_date';
  static const String columnReservationNumberOfGuests = 'number_of_guests';
  static const String columnReservationTotalPrice = 'total_price';
  static const String columnReservationStatus = 'status';
  static const String columnReservationNotes = 'notes';

  // Reviews Table Columns
  static const String columnReviewDestinationId = 'destination_id';
  static const String columnReviewClientId = 'client_id';
  static const String columnReviewRating = 'rating';
  static const String columnReviewComment = 'comment';

  // Additional Services Table Columns
  static const String columnServiceName = 'name';
  static const String columnServiceDescription = 'description';
  static const String columnServicePrice = 'price';
  static const String columnServiceCategory = 'category';

  // Reservation Services Junction Table Columns
  static const String columnReservationServiceReservationId = 'reservation_id';
  static const String columnReservationServiceServiceId = 'service_id';

  // Create Table Statements
  static const String createTableDestinations = '''
    CREATE TABLE $tableDestinations (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnDestinationName TEXT NOT NULL,
      $columnDestinationCountry TEXT NOT NULL,
      $columnDestinationCity TEXT,
      $columnDestinationImageUrl TEXT,
      $columnDestinationDescription TEXT,
      $columnDestinationBasePrice REAL NOT NULL,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL
    )
  ''';

  static const String createTableClients = '''
    CREATE TABLE $tableClients (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnClientFirstName TEXT NOT NULL,
      $columnClientLastName TEXT NOT NULL,
      $columnClientEmail TEXT NOT NULL UNIQUE,
      $columnClientUsername TEXT NOT NULL UNIQUE,
      $columnClientPassword TEXT NOT NULL,
      $columnClientRole TEXT NOT NULL DEFAULT 'user',
      $columnClientAuthToken TEXT,
      $columnClientPassportNumber TEXT NOT NULL UNIQUE,
      $columnClientPhone TEXT,
      $columnClientAddress TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL
    )
  ''';

  static const String createTableReservations = '''
    CREATE TABLE $tableReservations (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnReservationClientId INTEGER NOT NULL,
      $columnReservationDestinationId INTEGER NOT NULL,
      $columnReservationDepartureDate TEXT NOT NULL,
      $columnReservationReturnDate TEXT NOT NULL,
      $columnReservationNumberOfGuests INTEGER NOT NULL DEFAULT 1,
      $columnReservationTotalPrice REAL NOT NULL,
      $columnReservationStatus TEXT NOT NULL DEFAULT 'pending',
      $columnReservationNotes TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      FOREIGN KEY ($columnReservationClientId) REFERENCES $tableClients($columnId) ON DELETE CASCADE,
      FOREIGN KEY ($columnReservationDestinationId) REFERENCES $tableDestinations($columnId) ON DELETE CASCADE
    )
  ''';

  static const String createTableReviews = '''
    CREATE TABLE $tableReviews (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnReviewDestinationId INTEGER NOT NULL,
      $columnReviewClientId INTEGER NOT NULL,
      $columnReviewRating INTEGER NOT NULL CHECK($columnReviewRating >= 1 AND $columnReviewRating <= 5),
      $columnReviewComment TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      FOREIGN KEY ($columnReviewDestinationId) REFERENCES $tableDestinations($columnId) ON DELETE CASCADE,
      FOREIGN KEY ($columnReviewClientId) REFERENCES $tableClients($columnId) ON DELETE CASCADE,
      UNIQUE($columnReviewDestinationId, $columnReviewClientId)
    )
  ''';

  static const String createTableAdditionalServices = '''
    CREATE TABLE $tableAdditionalServices (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnServiceName TEXT NOT NULL,
      $columnServiceDescription TEXT,
      $columnServicePrice REAL NOT NULL,
      $columnServiceCategory TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL
    )
  ''';

  static const String createTableReservationServices = '''
    CREATE TABLE $tableReservationServices (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnReservationServiceReservationId INTEGER NOT NULL,
      $columnReservationServiceServiceId INTEGER NOT NULL,
      FOREIGN KEY ($columnReservationServiceReservationId) REFERENCES $tableReservations($columnId) ON DELETE CASCADE,
      FOREIGN KEY ($columnReservationServiceServiceId) REFERENCES $tableAdditionalServices($columnId) ON DELETE CASCADE,
      UNIQUE($columnReservationServiceReservationId, $columnReservationServiceServiceId)
    )
  ''';
}

