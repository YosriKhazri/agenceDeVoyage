import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/destinations/destinations_list_screen.dart';
import '../../screens/destinations/destination_form_screen.dart';
import '../../screens/destinations/destination_detail_screen.dart';
import '../../screens/clients/clients_list_screen.dart';
import '../../screens/clients/client_form_screen.dart';
import '../../screens/clients/client_detail_screen.dart';
import '../../screens/reservations/reservations_list_screen.dart';
import '../../screens/reservations/reservation_form_screen.dart';
import '../../screens/reviews/reviews_list_screen.dart';
import '../../screens/reviews/review_form_screen.dart';
import '../../screens/services/services_list_screen.dart';
import '../../screens/services/service_form_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../core/models/destination.dart';
import '../../core/models/client.dart';
import '../../core/models/reservation.dart';
import '../../core/models/additional_service.dart';

class AppRouter {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/';
  static const String destinations = '/destinations';
  static const String destinationForm = '/destinations/form';
  static const String destinationDetail = '/destinations/detail';
  static const String clients = '/clients';
  static const String clientForm = '/clients/form';
  static const String clientDetail = '/clients/detail';
  static const String reservations = '/reservations';
  static const String reservationForm = '/reservations/form';
  static const String reviews = '/reviews';
  static const String reviewForm = '/reviews/form';
  static const String services = '/services';
  static const String serviceForm = '/services/form';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case destinations:
        return MaterialPageRoute(builder: (_) => const DestinationsListScreen());

      case destinationForm:
        return MaterialPageRoute(
          builder: (_) => DestinationFormScreen(
            destination: args is Destination ? args : null,
          ),
        );

      case destinationDetail:
        return MaterialPageRoute(
          builder: (_) => DestinationDetailScreen(
            destinationId: args is int ? args : (args as Map)['id'] as int,
          ),
        );

      case clients:
        return MaterialPageRoute(builder: (_) => const ClientsListScreen());

      case clientForm:
        return MaterialPageRoute(
          builder: (_) => ClientFormScreen(
            client: args is Client ? args : null,
          ),
        );

      case clientDetail:
        return MaterialPageRoute(
          builder: (_) => ClientDetailScreen(
            clientId: args is int ? args : (args as Map)['id'] as int,
          ),
        );

      case reservations:
        return MaterialPageRoute(builder: (_) => const ReservationsListScreen());

      case reservationForm:
        return MaterialPageRoute(
          builder: (_) => ReservationFormScreen(
            reservation: args is Reservation ? args : null,
          ),
        );

      case reviews:
        return MaterialPageRoute(builder: (_) => const ReviewsListScreen());

      case reviewForm:
        return MaterialPageRoute(builder: (_) => const ReviewFormScreen());

      case services:
        return MaterialPageRoute(builder: (_) => const ServicesListScreen());

      case serviceForm:
        return MaterialPageRoute(
          builder: (_) => ServiceFormScreen(
            service: args is AdditionalService ? args : null,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Navigation helper methods
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    final result = await Navigator.pushNamed<dynamic>(
      context,
      routeName,
      arguments: arguments,
    );
    return result is T ? result : null;
  }

  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  // Specific navigation methods
  static Future<bool?> navigateToDestinationForm(
    BuildContext context, {
    Destination? destination,
  }) async {
    try {
      return await push<bool>(
        context,
        destinationForm,
        arguments: destination,
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      return null;
    }
  }

  static Future<void> navigateToDestinationDetail(
    BuildContext context,
    int destinationId,
  ) async {
    await push(
      context,
      destinationDetail,
      arguments: destinationId,
    );
  }

  static Future<bool?> navigateToClientForm(
    BuildContext context, {
    Client? client,
  }) async {
    try {
      return await push<bool>(
        context,
        clientForm,
        arguments: client,
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      return null;
    }
  }

  static Future<void> navigateToClientDetail(
    BuildContext context,
    int clientId,
  ) async {
    await push(
      context,
      clientDetail,
      arguments: clientId,
    );
  }

  static Future<bool?> navigateToReservationForm(
    BuildContext context, {
    Reservation? reservation,
  }) async {
    try {
      return await push<bool>(
        context,
        reservationForm,
        arguments: reservation,
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      return null;
    }
  }

  static Future<bool?> navigateToReviewForm(BuildContext context) async {
    try {
      return await push<bool>(context, reviewForm);
    } catch (e) {
      debugPrint('Navigation error: $e');
      return null;
    }
  }

  static Future<bool?> navigateToServiceForm(
    BuildContext context, {
    AdditionalService? service,
  }) async {
    try {
      return await push<bool>(
        context,
        serviceForm,
        arguments: service,
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      return null;
    }
  }
}

