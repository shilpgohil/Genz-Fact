class MediaAlbum {
  const MediaAlbum({
    required this.id,
    required this.name,
    required this.count,
    this.coverId,
    this.isAll = false,
    this.isFromDevice = true,
  });

  final String id;
  final String name;
  final int count;
  final String? coverId;
  final bool isAll;
  final bool isFromDevice;
}
