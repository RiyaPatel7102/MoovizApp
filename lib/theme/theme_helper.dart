import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'custom_text_styles.dart';

DarkCodeColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class ThemeHelper {
  final Map<String, DarkCodeColors> _supportedCustomColor = {
    'darkCode': DarkCodeColors()
  };

  DarkCodeColors _getThemeColors() {
    return _supportedCustomColor['darkCode'] ?? DarkCodeColors();
  }

  ThemeData _getThemeData() {
    return ThemeData(
      scaffoldBackgroundColor: appTheme.black,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      fontFamily: CustomTextStyles.fontFamily,
      primarySwatch: Colors.blue,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: appTheme.primary,
        selectionColor: appTheme.primary.withOpacity(0.2),
        selectionHandleColor: appTheme.primary,
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(appTheme.white),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return appTheme.primary;
          }
          return appTheme.white;
        }),
        side: WidgetStateBorderSide.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.selected)
                ? appTheme.primary
                : appTheme.greyInactive,
          ),
        ),
        visualDensity: const VisualDensity(
          vertical: -4,
          horizontal: -4,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appTheme.black,
        elevation: 0,
        titleTextStyle: CustomTextStyles.onDarkRegular28w700,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
    );
  }

  DarkCodeColors themeColor() => _getThemeColors();
  ThemeData themeData() => _getThemeData();
}

class DarkCodeColors {
  Color get primary => Color(0xFFE50914);
  Color get primaryShade1 => Color(0xFFB81D13);
  Color get primaryShade2 => Color(0xFFE50914);
  Color get primaryShade3 => Color(0xFFF40612);
  Color get primaryShade4 => Color(0xFFFF6B6B);
  Color get primaryShade50 => Color(0xFF2A0E0E);

  Color get grey1 => Color(0xFF141414);
  Color get grey2 => Color(0xFF221F1F);
  Color get greyInactive => Color(0xFF777777);
  Color get grey3 => Color(0xFF333333);
  Color get grey4 => Color(0xFF444444);
  Color get grey100 => Color(0xFF666666);

  Color get nutral => Color(0xFF777777);
  Color get neutral100 => Color(0xFF666666);
  Color get neutral400 => Color(0xFF888888);
  Color get neutral600 => Color(0xFF555555);
  Color get neutral900 => Color(0xFF000000);
  Color get neutral800 => Color(0xFF141414);
  Color get white => Color(0xFFFFFFFF);
  Color get black => Color(0xFF000000);
  Color get backgroundDark => Color(0xFF000000);
  Color get backgroundLight => Color(0xFFFFFFFF);
  Color get sheetDark => Color(0xFF141414);
  Color get borderGrey => Color(0xFF333333);
  Color get grey300 => Color(0xFF666666);
  Color get grey200 => Color(0xFF777777);

  Color get onDarkRegular => Color(0xFFFFFFFF);
  Color get onDarkSecondary => Color(0xFFCCCCCC);
  Color get onDarkTertiary => Color(0xFF999999);

  Color get onLightRegular => Color(0xFF000000);
  Color get onLightSecondary => Color(0xFF333333);
  Color get onLightTertiary => Color(0xFF666666);

  Color get onPrimaryRegular => Color(0xFFFFFFFF);
  Color get onPrimarySecondary => Color(0xFFE0E0E0);
  Color get onPrimaryTertiary => Color(0xFFCCCCCC);

  Color get primaryFillColor => Color(0xFF2A0E0E);
  Color get primary950 => Color(0xFF1A0A0A);

  Color get divider => Color(0xFF333333);

  Color get success => Color(0xFF00B000);
  Color get error => Color(0xFFE50914);
  Color get warning => Color(0xFFFFD20C);
}
