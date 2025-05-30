// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get edit => 'bearbeiten';

  @override
  String get add => 'hinzufügen';

  @override
  String get cancel => 'abbrechen';

  @override
  String get save => 'speichern';

  @override
  String get name => 'Name';

  @override
  String get names => 'Namen';

  @override
  String get phone => 'Telefonnummer';

  @override
  String get phoneNumber => 'Telefonnummer';

  @override
  String get phones => 'Telefonnummern';

  @override
  String get emails => 'E-Mails';

  @override
  String get emailAddress => 'E-Mail Adresse';

  @override
  String get addresses => 'Adressen';

  @override
  String get address => 'Adresse';

  @override
  String get websites => 'Webseiten';

  @override
  String get website => 'Webseite';

  @override
  String get pictures => 'Bild';

  @override
  String get newCircle => 'neuer Kreis';

  @override
  String get sharedWith => 'geteilt mit';

  @override
  String get contact => 'Kontakt';

  @override
  String get contacts => 'Kontakten';

  @override
  String get circles => 'Kreise';

  @override
  String get welcomeAppTitle => 'Willkommen bei Coagulate';

  @override
  String get welcomeHeadline => 'Willkommen!\nWie heißt du?';

  @override
  String get welcomeText =>
      'Das ist die erste Information über dich, die du gleich selektiv mit anderen teilen kannst.';

  @override
  String get welcomeCallToActionButton => 'Los geht\'s';

  @override
  String get welcomeErrorNameMissing => 'Bitte gib deinen Namen ein.';

  @override
  String get profileHeadline => 'Profilinformationen';

  @override
  String profileAddHeadline(Object type) {
    return '$type hinzufügen';
  }

  @override
  String profileEditHeadline(Object type) {
    return '$type bearbeiten';
  }

  @override
  String get profileAndShareWithHeadline => 'und mit folgenden Kreisen teilen';

  @override
  String get profilePictureExplainer =>
      'Hier kannst du pro Kreis ein Bild auswählen. Falls ein Kontakt mehreren Kreisen mit einem Bild zugeordnet ist, sieht dein Kontakt das Bild des kleinsten Kreises.';
}
