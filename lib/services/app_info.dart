/// App identity and version information shown on the About screen.
///
/// The version and build are the values in `pubspec.yaml`; there is no
/// generated constant in this project, and a test asserts the two stay in
/// step.
class AppInfo {
  const AppInfo._();

  static const name = 'Fox';
  static const version = '2.1.1';
  static const buildNumber = '20';
  static const repositoryUrl = 'https://github.com/teamsuperpanda/fox';
  static const licenseName = 'PolyForm Noncommercial 1.0.0';
  static const teamName = 'Team Super Panda';
}
