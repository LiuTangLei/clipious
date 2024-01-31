import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invidious/app/views/screens/main.dart';
import 'package:invidious/app/views/tv/screens/tv_home.dart';
import 'package:invidious/player/states/player.dart';
import 'package:invidious/player/views/tv/screens/tv_player_view.dart';
import 'package:invidious/playlists/models/playlist.dart';
import 'package:invidious/playlists/views/screens/playlist.dart';
import 'package:invidious/playlists/views/tv/screens/playlist.dart';
import 'package:invidious/playlists/views/tv/screens/playlist_grid.dart';
import 'package:invidious/search/views/screens/search.dart';
import 'package:invidious/search/views/tv/screens/search.dart';
import 'package:invidious/settings/models/db/server.dart';
import 'package:invidious/settings/models/db/video_filter.dart';
import 'package:invidious/settings/views/screens/app_logs.dart';
import 'package:invidious/settings/views/screens/appearance.dart';
import 'package:invidious/settings/views/screens/browsing.dart';
import 'package:invidious/settings/views/screens/dearrow.dart';
import 'package:invidious/settings/views/screens/manage_servers.dart';
import 'package:invidious/settings/views/screens/manage_single_server.dart';
import 'package:invidious/settings/views/screens/notifications.dart';
import 'package:invidious/settings/views/screens/search_history_settings.dart';
import 'package:invidious/settings/views/screens/settings.dart';
import 'package:invidious/settings/views/screens/sponsor_block_settings.dart';
import 'package:invidious/settings/views/screens/video_filter.dart';
import 'package:invidious/settings/views/screens/video_filter_setup.dart';
import 'package:invidious/settings/views/screens/video_player.dart';
import 'package:invidious/settings/views/tv/screens/app_layout.dart';
import 'package:invidious/settings/views/tv/screens/dearrow_settings.dart';
import 'package:invidious/settings/views/tv/screens/filter_edit.dart';
import 'package:invidious/settings/views/tv/screens/filter_list.dart';
import 'package:invidious/settings/views/tv/screens/manage_servers.dart';
import 'package:invidious/settings/views/tv/screens/manage_single_server.dart';
import 'package:invidious/settings/views/tv/screens/search_history_settings.dart';
import 'package:invidious/settings/views/tv/screens/settings.dart';
import 'package:invidious/settings/views/tv/screens/sponsor_block_settings.dart';
import 'package:invidious/subscription_management/view/screens/manage_subscriptions.dart';
import 'package:invidious/utils/models/paginated_list.dart';
import 'package:invidious/utils/views/tv/components/select_from_list.dart';
import 'package:invidious/utils/views/tv/components/tv_plain_text.dart';
import 'package:invidious/utils/views/tv/components/tv_text_field.dart';
import 'package:invidious/utils/views/tv/components/tv_time_picker.dart';
import 'package:invidious/videos/models/base_video.dart';
import 'package:invidious/videos/models/video_in_list.dart';
import 'package:invidious/videos/views/screens/subscriptions.dart';
import 'package:invidious/videos/views/screens/video.dart';
import 'package:invidious/videos/views/tv/screens/video.dart';
import 'package:invidious/videos/views/tv/screens/video_grid_view.dart';
import 'package:invidious/welcome_wizard/views/screens/welcome_wizard.dart';
import 'package:invidious/welcome_wizard/views/tv/screens/welcome_wizard.dart';
import 'package:logging/logging.dart';

import 'channels/views/screens/channel.dart';
import 'channels/views/tv/screens/channel.dart';
import 'db_reset/views/screen/reset.dart';
import 'downloads/views/screens/download_manager.dart';
import 'home/views/screens/edit_layout.dart';
import 'home/views/screens/home.dart';
import 'main.dart';

part 'router.gr.dart';

const pathManageSingleServerFromWizard = '/wizard/manage-single-server';
const pathManageSingleServerFromSettings = 'manage-single-server';

late AppRouter appRouter;

final log = Logger('Router');

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends _$AppRouter {
  final bool needsDbMigration;
  final bool hasServer;

  AppRouter({required this.needsDbMigration, required this.hasServer});

  @override
  List<AutoRoute> get routes {
    return isTv
        ? [
            AutoRoute(
              page: TvHomeRoute.page,
              initial: !needsDbMigration && hasServer,
            ),
            AutoRoute(
                page: TvWelcomeWizardRoute.page,
                initial: !needsDbMigration && !hasServer),
            AutoRoute(page: TvChannelRoute.page),
            AutoRoute(page: TvGridRoute.page),
            AutoRoute(page: TvVideoRoute.page),
            AutoRoute(page: TvSearchRoute.page),
            AutoRoute(page: TvPlayerRoute.page),
            AutoRoute(page: TvPlaylistGridRoute.page),
            AutoRoute(page: TvPlaylistRoute.page),
            AutoRoute(page: TVSettingsRoute.page),
            AutoRoute(page: TvSettingsManageServersRoute.page),
            AutoRoute(page: TvSearchHistorySettingsRoute.page),
            AutoRoute(page: TvSponsorBlockSettingsRoute.page),
            AutoRoute(page: TvManageSingleServerRoute.page),
            AutoRoute(page: TvSelectFromListRoute.page),
            AutoRoute(page: TvTextFieldRoute.page),
            AutoRoute(page: TvDearrowSettingsRoute.page),
            AutoRoute(page: TvAppLayoutSettingsRoute.page),
            AutoRoute(page: TvFilterEditSettingsRoute.page),
            AutoRoute(page: TvFilterListSettingsRoute.page),
            AutoRoute(page: TvTimePickerRoute.page),
            AutoRoute(page: TvPlainTextRoute.page),
            AutoRoute(page: ResetRoute.page, initial: needsDbMigration)
          ]
        : [
            AutoRoute(
              page: MainRoute.page,
              initial: !needsDbMigration && hasServer,
              children: [
                AutoRoute(page: HomeRoute.page, initial: true),
                AutoRoute(page: VideoRoute.page),
                AutoRoute(page: ChannelRoute.page),
                AutoRoute(page: DownloadManagerRoute.page),
                AutoRoute(page: SearchRoute.page),
                AutoRoute(page: EditHomeLayoutRoute.page),
                AutoRoute(page: SettingsRoute.page),
                AutoRoute(page: BrowsingSettingsRoute.page),
                AutoRoute(page: ManageServersRoute.page),
                AutoRoute(
                    page: ManageSingleServerRoute.page,
                    path: pathManageSingleServerFromSettings),
                AutoRoute(page: VideoPlayerSettingsRoute.page),
                AutoRoute(page: AppearanceSettingsRoute.page),
                AutoRoute(page: SearchHistorySettingsRoute.page),
                AutoRoute(page: VideoFilterSettingsRoute.page),
                AutoRoute(page: VideoFilterSetupRoute.page),
                AutoRoute(page: SponsorBlockSettingsRoute.page),
                AutoRoute(page: NotificationSettingsRoute.page),
                AutoRoute(page: ManageSubscriptionsRoute.page),
                AutoRoute(page: AppLogsRoute.page),
                AutoRoute(page: PlaylistViewRoute.page),
                AutoRoute(page: SubscriptionRoute.page),
                AutoRoute(page: DeArrowSettingsRoute.page),
              ],
            ),
            AutoRoute(page: ResetRoute.page, initial: needsDbMigration),
            AutoRoute(
                page: ManageSingleServerRoute.page,
                path: pathManageSingleServerFromWizard),
            AutoRoute(
                page: WelcomeWizardRoute.page,
                initial: !needsDbMigration && !hasServer)
          ];
  }
}

class MyRouteObserver extends AutoRouterObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    log.fine(
        'New route pushed: ${route.settings.name}, ${route.runtimeType}, previous route: ${previousRoute?.settings.name}, ${previousRoute.runtimeType}');
    log.fine('current route: ${appRouter.current.name}');
    if (route.settings.name != null) {
      route.navigator?.context.read<PlayerCubit>().showMiniPlayer();
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    log.fine(
        'New route popped: ${route.settings.name}, ${route.runtimeType}, previous route: ${previousRoute?.settings.name}, ${previousRoute.runtimeType}');
    log.fine('current route: ${appRouter.current.name}');
    super.didPop(route, previousRoute);
  }

/*
  // only override to observer tab routes
  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {
    print('Tab route visited: ${route.name}');
  }

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {
    print('Tab route re-visited: ${route.name}');
  }
*/
}
