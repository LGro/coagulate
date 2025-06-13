// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get edit => 'edit';

  @override
  String get add => 'add';

  @override
  String get cancel => 'cancel';

  @override
  String get save => 'save';

  @override
  String get name => 'name';

  @override
  String get names => 'names';

  @override
  String get phone => 'phone';

  @override
  String get phoneNumber => 'phone number';

  @override
  String get phones => 'phones';

  @override
  String get emails => 'emails';

  @override
  String get emailAddress => 'e-mail address';

  @override
  String get addresses => 'addresses';

  @override
  String get address => 'address';

  @override
  String get websites => 'websites';

  @override
  String get website => 'website';

  @override
  String get organizations => 'organizations';

  @override
  String get organization => 'organization';

  @override
  String get pictures => 'pictures';

  @override
  String get newCircle => 'new circle';

  @override
  String get sharedWith => 'shared with';

  @override
  String get contact => 'contact';

  @override
  String get contacts => 'contacts';

  @override
  String get circles => 'circles';

  @override
  String get welcomeAppTitle => 'Welcome to Coagulate';

  @override
  String get welcomeHeadline => 'Welcome!\nWhat\'s your name?';

  @override
  String get welcomeText =>
      'This is the first bit of personal information that you can selectively share with others in a moment.';

  @override
  String get welcomeCallToActionButton => 'Let\'s coagulate';

  @override
  String get welcomeErrorNameMissing => 'Please enter your name.';

  @override
  String get profileHeadline => 'Profile information';

  @override
  String profileAddHeadline(Object type) {
    return 'Add $type';
  }

  @override
  String profileEditHeadline(Object type) {
    return 'Edit $type';
  }

  @override
  String get profileAndShareWithHeadline => 'and share with circles';

  @override
  String get profilePictureExplainer =>
      'You can set one picture per circle. Contacts that belong to several circles that have a picture will see the one picture belonging to the smallest circle.';
}
