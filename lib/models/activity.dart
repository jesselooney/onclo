class Activity {
  final String name;

  List<String> get words => name.split(' ');

  Activity(String name)
    : this.name = name.trim().replaceAll(RegExp(r'\s+'), ' ');

  @override
  bool operator ==(Object other) =>
      other is Activity &&
      other.runtimeType == runtimeType &&
      other.name == name;

  @override
  int get hashCode => name.hashCode;
}
