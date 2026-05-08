class Worker {
  String id;
  String name;
  String position; // Puesto (ej. Vendedor, Técnico)
  String phone;

  Worker({required this.id, required this.name, required this.position, required this.phone});

  Map<String, dynamic> toMap() => {
    'name': name,
    'position': position,
    'phone': phone,
  };
}