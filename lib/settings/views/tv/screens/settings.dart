import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:invidious/app/states/app.dart';
import 'package:invidious/extensions.dart';
import 'package:invidious/router.dart';
import 'package:invidious/utils.dart';
import 'package:invidious/utils/views/tv/components/tv_overscan.dart';
import 'package:locale_names/locale_names.dart';
import 'package:logging/logging.dart';

import '../../../../globals.dart';
import '../../../states/settings.dart';

var log = Logger('TvSettings');

@RoutePage()
class TVSettingsScreen extends StatelessWidget {
  const TVSettingsScreen({super.key});

  openSelectCountry(BuildContext context) {
    AppLocalizations locals = AppLocalizations.of(context)!;
    var cubit = context.read<SettingsCubit>();
    var countryNames = countryCodes.map((e) => e.name).toList();
    countryNames.sort();
    AutoRouter.of(context).push(TvSelectFromListRoute(
      title: locals.selectBrowsingCountry,
      options: countryNames,
      selected: cubit.state.country.name,
      onSelect: cubit.selectCountry,
    ));
  }

  List<String> getCategories(BuildContext context) {
    var locals = AppLocalizations.of(context)!;
    return [
      locals.popular,
      locals.trending,
      locals.subscriptions,
      locals.playlists
    ];
  }

  openManageServers(BuildContext context) {
    AutoRouter.of(context).push(const TvSettingsManageServersRoute());
  }

  openSponsorBlockSettings(BuildContext context) {
    AutoRouter.of(context).push(const TvSponsorBlockSettingsRoute());
  }

  openDearrowSettings(BuildContext context) {
    AutoRouter.of(context).push(const TvDearrowSettingsRoute());
  }

  openSearchHistorySettings(BuildContext context) {
    AutoRouter.of(context).push(const TvSearchHistorySettingsRoute());
  }

  openAppLayout(BuildContext context) {
    AutoRouter.of(context).push(const TvAppLayoutSettingsRoute());
  }

  showSelectLanguage(BuildContext context) {
    var localsList = AppLocalizations.supportedLocales;
    var localsStrings =
        localsList.map((e) => e.nativeDisplayLanguageScript ?? '').toList();
    var locals = AppLocalizations.of(context)!;
    var cubit = context.read<SettingsCubit>();

    List<String>? localeString = cubit.state.locale?.split('_');
    Locale? selected = localeString != null
        ? Locale.fromSubtags(
            languageCode: localeString[0],
            scriptCode: localeString.length >= 2 ? localeString[1] : null)
        : null;

    AutoRouter.of(context).push(TvSelectFromListRoute(
      title: locals.appLanguage,
      options: [locals.followSystem, ...localsStrings],
      selected: selected?.nativeDisplayLanguageScript ?? locals.followSystem,
      onSelect: (String selected) {
        if (selected == locals.followSystem) {
          cubit.setLocale(localsList, localsStrings, null);
        } else {
          cubit.setLocale(localsList, localsStrings, selected);
        }
      },
    ));
  }

  selectTheme(BuildContext context) {
    var locals = AppLocalizations.of(context)!;
    var cubit = context.read<SettingsCubit>();
    AutoRouter.of(context).push(TvSelectFromListRoute(
      title: locals.themeBrightness,
      options:
          ThemeMode.values.map((e) => cubit.getThemeLabel(locals, e)).toList(),
      selected: cubit.getThemeLabel(locals, cubit.state.themeMode),
      onSelect: (String selected) {
        ThemeMode? theme = ThemeMode.values.firstWhereOrNull(
            (element) => cubit.getThemeLabel(locals, element) == selected);
        cubit.setThemeMode(theme);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations locals = AppLocalizations.of(context)!;

    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: TvOverscan(
        child: BlocBuilder<SettingsCubit, SettingsState>(builder: (context, _) {
          var cubit = context.read<SettingsCubit>();
          return DefaultTextStyle(
            style: textTheme.bodyLarge!,
            child: ListView(
              children: [
                SettingsTitle(title: locals.browsing),
                SettingsTile(
                  title: locals.customizeAppLayout,
                  description:
                      _.appLayout.map((e) => e.getLabel(locals)).join(", "),
                  onSelected: (context) => openAppLayout(context),
                ),
                SettingsTile(
                  title: locals.country,
                  description: _.country.name,
                  onSelected: (context) => openSelectCountry(context),
                ),
                SettingsTile(
                  title: locals.appLanguage,
                  description:
                      cubit.getLocaleDisplayName() ?? locals.followSystem,
                  onSelected: (context) => showSelectLanguage(context),
                ),
                SettingsTile(
                  title: 'Return YouTube Dislike',
                  description: locals.returnYoutubeDislikeDescription,
                  onSelected: (context) => cubit
                      .toggleReturnYoutubeDislike(!_.useReturnYoutubeDislike),
                  trailing: Switch(
                      onChanged: (value) {}, value: _.useReturnYoutubeDislike),
                ),
                SettingsTile(
                  title: locals.searchHistory,
                  description: locals.searchHistoryDescription,
                  onSelected: openSearchHistorySettings,
                ),
                SettingsTile(
                  title: 'DeArrow',
                  description: _.dearrow
                      ? locals.enabled
                      : locals.deArrowSettingDescription,
                  onSelected: openDearrowSettings,
                ),
                SettingsTile(
                  title: locals.videoFilters,
                  description: locals.videoFiltersSettingTileDescriptions,
                  onSelected: (context) => AutoRouter.of(context)
                      .push(const TvFilterListSettingsRoute()),
                ),
                SettingsTitle(title: locals.servers),
                BlocBuilder<AppCubit, AppState>(
                    buildWhen: (previous, current) =>
                        previous.server != current.server,
                    builder: (context, app) {
                      return SettingsTile(
                          title: locals.manageServers,
                          description: app.server != null
                              ? locals.currentServer(app.server!.url)
                              : "",
                          onSelected: openManageServers);
                    }),
                SettingsTitle(title: locals.videoPlayer),
                SettingsTile(
                  title: locals.useDash,
                  description: locals.useDashDescription,
                  onSelected: (context) => cubit.toggleDash(!_.useDash),
                  trailing: Switch(onChanged: (value) {}, value: _.useDash),
                ),
                SettingsTile(
                  title: locals.useProxy,
                  description: locals.useProxyDescription,
                  onSelected: (context) => cubit.toggleProxy(!_.useProxy),
                  trailing: Switch(onChanged: (value) {}, value: _.useProxy),
                ),
                AdjustmentSettingTile(
                  title: locals.skipStep,
                  value: _.skipStep.floor(),
                  description: locals.skipStepDescription,
                  possibleValues: skipSteps,
                  onNewValue: cubit.setSkipStep,
                ),
                SettingsTile(
                  title: locals.exponentialSkip,
                  description: locals.exponentialSkipDescription,
                  onSelected: (context) =>
                      cubit.setSkipExponentially(!_.skipExponentially),
                  trailing:
                      Switch(onChanged: (value) {}, value: _.skipExponentially),
                ),
                AdjustmentSettingTile(
                  title: locals.subtitleFontSize,
                  value: _.subtitleSize.floor(),
                  step: 1,
                  description: locals.subtitleFontSizeDescription,
                  onNewValue: cubit.setSubtitleSize,
                ),
                SettingsTile(
                  title: locals.subtitlesBackground,
                  description: locals.subtitlesBackgroundDescription,
                  onSelected: (context) =>
                      cubit.setSubtitlesBackground(!_.subtitlesBackground),
                  trailing: Switch(
                      onChanged: (value) {}, value: _.subtitlesBackground),
                ),
                SettingsTile(
                  title: locals.rememberSubtitleLanguage,
                  description: locals.rememberSubtitleLanguageDescription,
                  onSelected: (context) =>
                      cubit.toggleRememberSubtitles(!_.rememberSubtitles),
                  trailing:
                      Switch(onChanged: (value) {}, value: _.rememberSubtitles),
                ),
                SettingsTile(
                  title: locals.rememberPlaybackSpeed,
                  description: locals.rememberPlaybackSpeedDescription,
                  onSelected: (context) => cubit
                      .toggleRememberPlaybackSpeed(!_.rememberPlayBackSpeed),
                  trailing: Switch(
                      onChanged: (value) {}, value: _.rememberPlayBackSpeed),
                ),
                SettingsTile(
                  title: 'SponsorBlock',
                  description: locals.sponsorBlockDescription,
                  onSelected: openSponsorBlockSettings,
                ),
                SettingsTitle(title: locals.appearance),
                SettingsTile(
                  title: locals.themeBrightness,
                  description: cubit.getThemeLabel(locals, _.themeMode),
                  onSelected: (context) => selectTheme(context),
                ),
                SettingsTile(
                  title: locals.blackBackground,
                  description: locals.blackBackgroundDescription,
                  onSelected: (context) =>
                      cubit.toggleBlackBackground(!_.blackBackground),
                  trailing:
                      Switch(onChanged: (value) {}, value: _.blackBackground),
                ),
                SettingsTitle(title: locals.about),
                SettingsTile(
                  title: '${locals.name}: ${_.packageInfo.appName}',
                  description:
                      '${locals.package}: ${_.packageInfo.packageName}',
                  onSelected: (context) {},
                ),
                SettingsTile(
                  title: '${locals.version}: ${_.packageInfo.version}',
                  description: '${locals.build}: ${_.packageInfo.buildNumber}',
                  onSelected: (context) {},
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}

class SettingsTitle extends StatelessWidget {
  final String title;

  const SettingsTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        top: 32,
      ),
      child: Text(
        title,
        style: textTheme.titleMedium,
      ),
    );
  }
}

class AdjustmentSettingTile extends StatelessWidget {
  final String title;
  final int value;
  final int? step;
  final List<int>? possibleValues;
  final String? description;
  final Function(int) onNewValue;

  const AdjustmentSettingTile(
      {super.key,
      required this.onNewValue,
      required this.title,
      this.description,
      required this.value,
      this.possibleValues,
      this.step})
      : assert(step == null || possibleValues == null,
            'Can\' have both step and possible values');

  onKeyEvent(FocusNode node, KeyEvent event, BuildContext ctx) {
    if (event is KeyUpEvent) {
      log.fine('onTvSelect, ${event.logicalKey}, $event');
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (step != null) {
          onNewValue(value - step!);
        } else if (possibleValues != null) {
          int index = possibleValues!.indexOf(value);
          if (index > 0) {
            onNewValue(possibleValues![index - 1]);
          }
        }
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (step != null) {
          onNewValue(value + step!);
        } else if (possibleValues != null) {
          int index = possibleValues!.indexOf(value);
          if (index < possibleValues!.length - 1) {
            onNewValue(possibleValues![index + 1]);
          }
        }
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return SettingsTile(
      title: title,
      description: description,
      onKeyEvent: onKeyEvent,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.chevron_left),
            ),
          ),
          Text(
            value.floor().toString(),
            style: textTheme.bodyLarge,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final bool? autofocus;
  final String title;
  final bool? enabled;
  final String? description;
  final Function(BuildContext context)? onSelected;
  final Widget? trailing;
  final Widget? leading;
  final Function(FocusNode, KeyEvent, BuildContext)? onKeyEvent;

  const SettingsTile(
      {super.key,
      required this.title,
      this.description,
      this.onSelected,
      this.trailing,
      this.autofocus,
      this.leading,
      this.enabled,
      this.onKeyEvent});

  @override
  Widget build(BuildContext context) {
    ColorScheme colors = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Focus(
        canRequestFocus: enabled,
        autofocus: autofocus ?? false,
        onKeyEvent: (node, event) => onKeyEvent != null
            ? onKeyEvent!(node, event, context)
            : onTvSelect(event, context,
                onSelected != null ? onSelected! : (context) {}),
        child: Builder(builder: (ctx) {
          final FocusNode focusNode = Focus.of(ctx);
          final bool hasFocus = focusNode.hasFocus;
          return ListTile(
            enabled: enabled ?? true,
            leading: leading,
            trailing: trailing,
            selectedTileColor: colors.secondaryContainer.withOpacity(0.5),
            selected: hasFocus,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.headlineSmall!.copyWith(
                      color: enabled ?? true
                          ? colors.primary
                          : colors.primary.withOpacity(0.5)),
                ),
                description != null
                    ? Text(
                        description ?? '',
                        style: textTheme.bodyLarge!
                            .copyWith(color: colors.secondary),
                      )
                    : const SizedBox.shrink()
              ],
            ),
          );
        }));
  }
}
