import 'package:advisor_ui/module/reset_pasword.dart';
import 'package:advisor_ui/pages/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:advisor_ui/module/home/presentation/home_screen.dart';

import '../../detailed_pages/detailed_root.dart';
import '../../pages/budget_page.dart';
import '../../pages/create_budge_page.dart';
import '../../pages/customer_portal.dart';
import '../../pages/daily_page.dart';

import '../../pages/notification_screen.dart';

import '../../pages/note.dart';

import '../../pages/profile_page.dart';
import '../../pages/root_app.dart';
import '../../pages/stats_page.dart';
import '/core/route/app_route_name.dart';
import '../../pages/premium.dart';
import '../../pages/payment.dart';

class AppRoute {
  static Route<dynamic>? generate(RouteSettings settings) {
    switch (settings.name) {
      case AppRouteName.home:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(),
          settings: settings,
        );

      case AppRouteName.budget:
        final arguments = settings.arguments as Map<String, dynamic>;
        final accessToken = arguments['accessToken'];
        return MaterialPageRoute(
          builder: (_) => BudgetPage(accessToken: accessToken),
          settings: settings,
        );

      case AppRouteName.payment:
        return MaterialPageRoute(
          builder: (_) => CardFromScreen(),
          settings: settings,
        );

      case AppRouteName.reset:
        return MaterialPageRoute(
          builder: (_) => resetpasswordPage(),
          settings: settings,
        );

      case AppRouteName.note:
        final arguments = settings.arguments as Map<String, dynamic>;
        final accessToken = arguments['accessToken'];
        return MaterialPageRoute(
          builder: (_) => NotePage(accessToken: accessToken),
          settings: settings,
        );
      case AppRouteName.customer:
        return MaterialPageRoute(
          builder: (_) => SubscriptionView(),
          settings: settings,
        );

      case AppRouteName.premium:
        final arguments = settings.arguments as Map<String, dynamic>;
        final accessToken = arguments['accessToken'];
        return MaterialPageRoute(
          builder: (_) => PremiumPage(accessToken: accessToken),
          settings: settings,
        );
      case AppRouteName.settings:
        final arguments = settings.arguments as Map<String, dynamic>;
        final accessToken = arguments['accessToken'];
        return MaterialPageRoute(
          builder: (_) => SettingsPage(accessToken: accessToken),
          settings: settings,
        );
      case AppRouteName.createbudget:
        final arguments = settings.arguments as Map<String, dynamic>;
        final accessToken = arguments['accessToken'];

        return MaterialPageRoute(
          builder: (_) => CreatBudgetPage(accessToken: accessToken),
          settings: settings,
        );

      case AppRouteName.daily:
        final arguments = settings.arguments as Map<String, dynamic>;
        final accessToken = arguments['accessToken'];
        return MaterialPageRoute(
          builder: (_) => DailyPage(accessToken: accessToken),
          settings: settings,
        );

      case AppRouteName.profile:
        final arguments = settings.arguments as Map<String, dynamic>;
        final accessToken = arguments['accessToken'];
        final responseData = arguments['responseData'];

        return MaterialPageRoute(
          builder: (_) => ProfilePage(
            accessToken: accessToken,
            responseData: responseData,
          ),
          settings: settings,
        );

      // case AppRouteName.root:
      // var arguments = settings.arguments;
      // if (arguments != null && arguments is Map && arguments.containsKey('accessToken')) {
      //   var accessToken = arguments['accessToken'];
      //   return MaterialPageRoute(
      //     builder: (_) => RootApp(accessToken: accessToken),
      //     settings: settings,
      //   );
      // }
      // // Handle the case when arguments are missing or not in the expected format
      // return null;
      case AppRouteName.root:
        (context) {
          final accessToken =
              ModalRoute.of(context)!.settings.arguments as String;
          return RootApp(accessToken: accessToken);
        };
        return null;

      case AppRouteName.stats:
        final arguments = settings.arguments as Map<String, dynamic>;
        final accessToken = arguments['accessToken'];
        return MaterialPageRoute(
          builder: (_) => StatsPage(accessToken: accessToken),
          settings: settings,
        );

      case AppRouteName.details:
        final arguments = settings.arguments as Map<String, dynamic>;
        final accessToken = arguments['accessToken'];
        return MaterialPageRoute(
            builder: (_) => DetailedRoot(accessToken: accessToken));

      // Notification center
      case AppRouteName.notification:
        return MaterialPageRoute(
          builder: (_) => const NotificationScreen(),
          settings: settings,
        );
    }

    return null;
  }
}
