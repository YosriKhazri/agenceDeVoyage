class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Please enter a valid price greater than 0';
    }
    return null;
  }

  static String? validateRating(int? value) {
    if (value == null) {
      return 'Rating is required';
    }
    if (value < 1 || value > 5) {
      return 'Rating must be between 1 and 5';
    }
    return null;
  }

  static String? validateNumberOfGuests(String? value) {
    if (value == null || value.isEmpty) {
      return 'Number of guests is required';
    }
    final guests = int.tryParse(value);
    if (guests == null || guests < 1) {
      return 'Please enter a valid number of guests (at least 1)';
    }
    return null;
  }

  static String? validateDate(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  static String? validateDateRange(String? departureDate, String? returnDate) {
    if (departureDate == null || returnDate == null) {
      return null;
    }
    try {
      final departure = DateTime.parse(departureDate);
      final returnDateParsed = DateTime.parse(returnDate);
      if (returnDateParsed.isBefore(departure) || returnDateParsed.isAtSameMomentAs(departure)) {
        return 'Return date must be after departure date';
      }
      return null;
    } catch (e) {
      return 'Please enter valid dates';
    }
  }
}

