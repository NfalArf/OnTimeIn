# nama_project

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Modul 1 — Manajemen Tugas

- Prioritas dihitung saat ditampilkan: tugas selesai berprioritas normal,
  deadline terlewat atau maksimal 24 jam berprioritas tinggi, maksimal 3 hari
  berprioritas sedang, dan selebihnya normal.
- Daftar tugas dan mata kuliah masih menggunakan penyimpanan in-memory. Foto
  disimpan di direktori aplikasi pada perangkat native dan sebagai data gambar
  pada web; referensi foto ikut hilang ketika data tugas di memori hilang.
  Penyimpanan tugas permanen belum diimplementasikan.
- Mata kuliah tidak dapat dihapus selama masih dipakai tugas; ubah mata kuliah
  tugas terlebih dahulu. Mengganti nama mata kuliah juga memperbarui nama pada
  tugas yang terkait selama sesi aplikasi berjalan.
