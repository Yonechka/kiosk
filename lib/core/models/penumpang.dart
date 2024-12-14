class Penumpang {
  String companyName; // Nama perusahaan
  String header; // Header
  List<String> ticketNo; // Nomor tiket
  List<String> qrCode; // QR Code
  List<String> penumpang; // Jenis penumpang
  List<String> passengerName; // Nama penumpang
  List<String> pergi; // Tujuan perjalanan (PICK UP)
  List<String> departureDate; // Tanggal keberangkatan
  List<String> scheduleCode; // Kode jadwal
  List<String> pickUp; // Lokasi pick up
  List<String> departure; // Nama lokasi keberangkatan
  List<String> departurePoolName; // Nama pool keberangkatan
  List<String> departureTime; // Waktu keberangkatan
  List<String> kursi; // Kode kursi
  List<String> seatNo; // Nomor kursi
  List<String> dropOff; // Lokasi drop off
  List<String> destination; // Tujuan (DESTINATION)
  List<String> destinationPoolName; // Nama pool tujuan
  List<String> ticketPrice; // Harga tiket
  List<String> transactionTime; // Waktu transaksi

  Penumpang({
    required this.companyName,
    required this.header,
    required this.ticketNo,
    required this.qrCode,
    required this.penumpang,
    required this.passengerName,
    required this.pergi,
    required this.departureDate,
    required this.scheduleCode,
    required this.pickUp,
    required this.departure,
    required this.departurePoolName,
    required this.departureTime,
    required this.kursi,
    required this.seatNo,
    required this.dropOff,
    required this.destination,
    required this.destinationPoolName,
    required this.ticketPrice,
    required this.transactionTime,
  });
}
