class TreatmentOrder {
  String id;
  final String patientFirstName;
  final String patientLastName;
  final String medicine;
  final bool isOrderFinished;
  final String bedNumber;

  TreatmentOrder({
    this.id = '',
    required this.patientFirstName,
    required this.patientLastName,
    required this.medicine,
    required this.isOrderFinished,
    required this.bedNumber,
  });

  static TreatmentOrder fromJson(Map<String, dynamic> json) => TreatmentOrder(
        id: json['id'],
        patientFirstName: json['patientFirstName'],
        patientLastName: json['patientLastName'],
        medicine: json['medicine'],
        isOrderFinished: json['isOrderFinished'],
        bedNumber: json['bedNumber'],
      );
}
