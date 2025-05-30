import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'add'**
  String get add;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'save'**
  String get save;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'name'**
  String get name;

  /// No description provided for @names.
  ///
  /// In en, this message translates to:
  /// **'names'**
  String get names;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'phone'**
  String get phone;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'phone number'**
  String get phoneNumber;

  /// No description provided for @phones.
  ///
  /// In en, this message translates to:
  /// **'phones'**
  String get phones;

  /// No description provided for @emails.
  ///
  /// In en, this message translates to:
  /// **'emails'**
  String get emails;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'e-mail address'**
  String get emailAddress;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'addresses'**
  String get addresses;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'address'**
  String get address;

  /// No description provided for @websites.
  ///
  /// In en, this message translates to:
  /// **'websites'**
  String get websites;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'website'**
  String get website;

  /// No description provided for @pictures.
  ///
  /// In en, this message translates to:
  /// **'pictures'**
  String get pictures;

  /// No description provided for @newCircle.
  ///
  /// In en, this message translates to:
  /// **'new circle'**
  String get newCircle;

  /// No description provided for @sharedWith.
  ///
  /// In en, this message translates to:
  /// **'shared with'**
  String get sharedWith;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'contact'**
  String get contact;

  /// No description provided for @contacts.
  ///
  /// In en, this message translates to:
  /// **'contacts'**
  String get contacts;

  /// No description provided for @circles.
  ///
  /// In en, this message translates to:
  /// **'circles'**
  String get circles;

  /// App title for welcome screen.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Coagulate'**
  String get welcomeAppTitle;

  /// No description provided for @welcomeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Welcome!\nWhat\'s your name?'**
  String get welcomeHeadline;

  /// No description provided for @welcomeText.
  ///
  /// In en, this message translates to:
  /// **'This is the first bit of personal information that you can selectively share with others in a moment.'**
  String get welcomeText;

  /// No description provided for @welcomeCallToActionButton.
  ///
  /// In en, this message translates to:
  /// **'Let\'s coagulate'**
  String get welcomeCallToActionButton;

  /// No description provided for @welcomeErrorNameMissing.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get welcomeErrorNameMissing;

  /// No description provided for @profileHeadline.
  ///
  /// In en, this message translates to:
  /// **'Profile information'**
  String get profileHeadline;

  /// No description provided for @profileAddHeadline.
  ///
  /// In en, this message translates to:
  /// **'Add {type}'**
  String profileAddHeadline(Object type);

  /// No description provided for @profileEditHeadline.
  ///
  /// In en, this message translates to:
  /// **'Edit {type}'**
  String profileEditHeadline(Object type);

  /// No description provided for @profileAndShareWithHeadline.
  ///
  /// In en, this message translates to:
  /// **'and share with circles'**
  String get profileAndShareWithHeadline;

  /// No description provided for @profilePictureExplainer.
  ///
  /// In en, this message translates to:
  /// **'You can set one picture per circle. Contacts that belong to several circles that have a picture will see the one picture belonging to the smallest circle.'**
  String get profilePictureExplainer;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
