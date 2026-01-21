import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/destination_controller.dart';
import '../../controllers/client_controller.dart';
import '../../controllers/reservation_controller.dart';
import '../../controllers/review_controller.dart';
import '../../controllers/additional_service_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common/statistics_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../core/router/app_router.dart';
import '../destinations/destinations_list_screen.dart';
import '../clients/clients_list_screen.dart';
import '../reservations/reservations_list_screen.dart';
import '../reviews/reviews_list_screen.dart';
import '../services/services_list_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  List<Widget> _buildScreens(bool isAdmin) {
    if (isAdmin) {
      return [
        const DashboardTab(),
        const DestinationsListScreen(),
        const ClientsListScreen(),
        const ReservationsListScreen(),
        const ReviewsListScreen(),
        const ServicesListScreen(),
      ];
    } else {
      return [
        const DestinationsListScreen(),
        const ProfileScreen(),
        const ReservationsListScreen(),
        const ReviewsListScreen(),
        const ServicesListScreen(),
      ];
    }
  }

  List<NavigationDestination> _buildDestinations(bool isAdmin) {
    if (isAdmin) {
      return const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.place_outlined),
          selectedIcon: Icon(Icons.place),
          label: 'Destinations',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outlined),
          selectedIcon: Icon(Icons.people),
          label: 'Clients',
        ),
        NavigationDestination(
          icon: Icon(Icons.book_outlined),
          selectedIcon: Icon(Icons.book),
          label: 'Reservations',
        ),
        NavigationDestination(
          icon: Icon(Icons.star_outlined),
          selectedIcon: Icon(Icons.star),
          label: 'Reviews',
        ),
        NavigationDestination(
          icon: Icon(Icons.room_service_outlined),
          selectedIcon: Icon(Icons.room_service),
          label: 'Services',
        ),
      ];
    } else {
      return const [
        NavigationDestination(
          icon: Icon(Icons.place_outlined),
          selectedIcon: Icon(Icons.place),
          label: 'Destinations',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outlined),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
        NavigationDestination(
          icon: Icon(Icons.book_outlined),
          selectedIcon: Icon(Icons.book),
          label: 'Reservations',
        ),
        NavigationDestination(
          icon: Icon(Icons.star_outlined),
          selectedIcon: Icon(Icons.star),
          label: 'Reviews',
        ),
        NavigationDestination(
          icon: Icon(Icons.room_service_outlined),
          selectedIcon: Icon(Icons.room_service),
          label: 'Services',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        final isAdmin = authController.isAdmin;
        final screens = _buildScreens(isAdmin);
        
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'img/agenceDeVoyageLogo.png',
                    height: 32,
                    width: 32,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Travel Agency Management',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () async {
                  await authController.logout();
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed(AppRouter.login);
                  }
                },
              ),
            ],
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: screens[_currentIndex],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: _buildDestinations(isAdmin),
          ),
        );
      },
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardController>().loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardController>(
      builder: (context, controller, child) {
        if (controller.isLoading && controller.statistics == null) {
          return const LoadingIndicator(message: 'Loading statistics...');
        }

        final stats = controller.statistics ?? {};

        return RefreshIndicator(
          onRefresh: () => controller.loadStatistics(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    StatisticsCard(
                      title: 'Destinations',
                      value: '${stats['totalDestinations'] ?? 0}',
                      icon: Icons.place,
                      color: Colors.blue,
                    ),
                    StatisticsCard(
                      title: 'Clients',
                      value: '${stats['totalClients'] ?? 0}',
                      icon: Icons.people,
                      color: Colors.green,
                    ),
                    StatisticsCard(
                      title: 'Reservations',
                      value: '${stats['totalReservations'] ?? 0}',
                      icon: Icons.book,
                      color: Colors.orange,
                    ),
                    StatisticsCard(
                      title: 'Reviews',
                      value: '${stats['totalReviews'] ?? 0}',
                      icon: Icons.star,
                      color: Colors.amber,
                    ),
                    StatisticsCard(
                      title: 'Total Revenue',
                      value: '\$${(stats['totalRevenue'] ?? 0.0).toStringAsFixed(2)}',
                      icon: Icons.attach_money,
                      color: Colors.teal,
                    ),
                    StatisticsCard(
                      title: 'Avg Rating',
                      value: '${(stats['averageRating'] ?? 0.0).toStringAsFixed(1)}',
                      icon: Icons.star_rate,
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildQuickActionButton(
                      context,
                      'Add Destination',
                      Icons.add_location,
                      Colors.blue,
                      () async {
                        final result = await AppRouter.navigateToDestinationForm(context);
                        if (result == true && mounted) {
                          context.read<DestinationController>().loadDestinations();
                        }
                      },
                    ),
                    _buildQuickActionButton(
                      context,
                      'Add Client',
                      Icons.person_add,
                      Colors.green,
                      () async {
                        final result = await AppRouter.navigateToClientForm(context);
                        if (result == true && mounted) {
                          context.read<ClientController>().loadClients();
                        }
                      },
                    ),
                    _buildQuickActionButton(
                      context,
                      'New Reservation',
                      Icons.book_online,
                      Colors.orange,
                      () async {
                        final result = await AppRouter.navigateToReservationForm(context);
                        if (result == true && mounted) {
                          context.read<ReservationController>().loadReservations();
                        }
                      },
                    ),
                    _buildQuickActionButton(
                      context,
                      'Add Review',
                      Icons.rate_review,
                      Colors.amber,
                      () async {
                        final result = await AppRouter.navigateToReviewForm(context);
                        if (result == true && mounted) {
                          context.read<ReviewController>().loadReviews();
                        }
                      },
                    ),
                    _buildQuickActionButton(
                      context,
                      'Add Service',
                      Icons.add_business,
                      Colors.teal,
                      () async {
                        final result = await AppRouter.navigateToServiceForm(context);
                        if (result == true && mounted) {
                          context.read<AdditionalServiceController>().loadServices();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        try {
          onTap();
        } catch (e) {
          debugPrint('Error in quick action button: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

