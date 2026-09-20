class Artisan {
  final String id;
  final String name;
  final String craft;
  final String location;
  final String state;
  final String registrationId;
  final String avatarUrl;
  final bool isVerified;

  const Artisan({
    required this.id,
    required this.name,
    required this.craft,
    required this.location,
    required this.state,
    required this.registrationId,
    this.avatarUrl = '',
    this.isVerified = true,
  });
}
