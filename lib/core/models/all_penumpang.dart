import 'package:kiosk/core/models/penumpang.dart';

Penumpang combinePenumpangData(
  String companyName,
  String header,
  List<Penumpang> penumpangList,
) {
  // Pastikan list tidak kosong
  if (penumpangList.isEmpty) {
    throw ArgumentError("penumpangList cannot be empty");
  }

  // Gabungkan semua atribut list secara dinamis
  List<String> combineAttribute(List<String> Function(Penumpang) selector) {
    return penumpangList.expand(selector).toList();
  }

  return Penumpang(
    companyName: companyName, // Menggunakan nilai yang sama untuk semua
    header: header, // Menggunakan nilai yang sama untuk semua
    ticketNo: combineAttribute((p) => p.ticketNo),
    qrCode: combineAttribute((p) => p.qrCode),
    penumpang: combineAttribute((p) => p.penumpang),
    passengerName: combineAttribute((p) => p.passengerName),
    pergi: combineAttribute((p) => p.pergi),
    departureDate: combineAttribute((p) => p.departureDate),
    scheduleCode: combineAttribute((p) => p.scheduleCode),
    pickUp: combineAttribute((p) => p.pickUp),
    departure: combineAttribute((p) => p.departure),
    departurePoolName: combineAttribute((p) => p.departurePoolName),
    departureTime: combineAttribute((p) => p.departureTime),
    kursi: combineAttribute((p) => p.kursi),
    seatNo: combineAttribute((p) => p.seatNo),
    dropOff: combineAttribute((p) => p.dropOff),
    destination: combineAttribute((p) => p.destination),
    destinationPoolName: combineAttribute((p) => p.destinationPoolName),
    ticketPrice: combineAttribute((p) => p.ticketPrice),
    transactionTime: combineAttribute((p) => p.transactionTime),
  );
}
