# Rencana Implementasi: Integrasi Penuh Backend & Restrukturisasi Folder Flutter (Front-End)

Rencana ini menjabarkan detail pembenahan arsitektur folder `front-end/lib` menjadi struktur berstandar industri (Clean Architecture style), pengintegrasian rute backend pengguna (**Privacy Consents**, **Transactions**, **ML Product Recommendations**, dan **Profile Management**), serta pembuatan antarmuka modern khas aplikasi finansial premium CIMB Niaga (OCTO maroon gradients, micro-animations, dynamic cards).

---

## Yang Memerlukan Tinjauan Pengguna

> [!IMPORTANT]
> **Arsitektur Pembenahan Struktur Folder**
> Kami akan menata ulang berkas-berkas di bawah `front-end/lib` agar terbagi dengan rapi menjadi:
> * `core/` (Tema warna maroon premium, konstanta, scrollbars)
> * `data/models/` (Homogenisasi model data)
> * `data/services/` (Kumpulan API Service)
> * `providers/` (State management Provider)
> * `ui/views/` (Halaman utama)
> * `ui/widgets/` (Widget penunjang bersama)
> Semua import berkas di internal Flutter akan disesuaikan secara otomatis.

> [!TIP]
> **Fitur Simulasi Cerdas (Self-Healing Local Storage)**
> Sama halnya dengan admin dashboard, seluruh API Service baru di Flutter ini akan mewarisi arsitektur *self-healing*. Jika API backend offline, aplikasi akan otomatis memuat database lokal terenkripsi tiruan (menggunakan Shared Preferences atau memori internal) sehingga aplikasi tetap berjalan lancar dan interaktif.

---

## Perubahan yang Diusulkan (Struktur Folder Baru)

```
front-end/lib/
├── core/
│   ├── constants/       (Aset gambar, strings)
│   └── theme/           (Maroon ThemeData, style teks)
├── data/
│   ├── models/          (user_model.dart, transaction_model.dart, consent_model.dart, homepage_config.dart)
│   └── services/        (auth_service.dart, homepage_service.dart, interaction_service.dart, transaction_service.dart, consent_service.dart, recommendation_service.dart, user_service.dart, session_manager.dart)
├── providers/           (homepage_provider.dart, transaction_provider.dart, user_provider.dart, consent_provider.dart)
├── ui/
│   ├── views/           (home_page.dart, login_page.dart, register_page.dart, settings_page.dart, wealth_page.dart, my_account_page.dart, splash_screen.dart)
│   └── widgets/         (custom_bottom_nav.dart, bdui_renderer.dart, bdui_menu_grid.dart, bdui_balance_card.dart, balance_card.dart, E_Wallet.dart, berita_promosi.dart, info_banner.dart, header1.dart, header2.dart, header3.dart)
└── main.dart
```

---

## Rincian Modul Integrasi Baru

### 1. Modul Transaksi Dinamis (`transaction_service` & `my_account_page`)
* **[NEW] `transaction_service.dart`**: Menangani transfer dana baru (`POST /transactions`) dan pengambilan riwayat transaksi pengguna (`GET /transactions/:userId`).
* **[MODIFY] `my_account_page.dart`**: Diubah menjadi halaman mutasi mutakhir. Mengambil transaksi riil dari backend dan menampilkannya dengan visual mutasi modern (transaksi keluar diberi minus `-` merah redup, transaksi masuk diberi plus `+` hijau cerah, lengkap dengan pengelompokan ikon kategori transaksi).
* **[MODIFY] `E_Wallet.dart`**: Menghubungkan aksi tombol "Connect Gopay". Saat diklik, aplikasi akan mengirimkan transaksi top-up riil (`POST /transactions`) ke backend, yang secara otomatis memperbarui saldo OCTO Pay pengguna dan menambah mutasi riwayat transaksi secara real-time.

### 2. Modul Persetujuan Hukum Privasi (`consent_service` & `settings_page`)
* **[NEW] `consent_service.dart`**: Menyimpan persetujuan data sharing ke backend (`POST /consents`) dan memperbarui persetujuan (`PUT /consents/:userId`).
* **[MODIFY] `settings_page.dart`**: Menambahkan saklar toggles hukum privasi ("Bagikan Data untuk Personalisasi AI"). Setiap kali pengguna menyalakan/mematikan tombol ini, status hukum persetujuan langsung diperbarui di database backend secara real-time.
* **[NEW] Dialog Persetujuan Awal**: Saat masuk beranda pertama kali, jika pengguna belum menentukan persetujuan, aplikasi akan menampilkan BottomSheet modern dengan maroon accents yang meminta kesediaan pengguna menyetujui optimalisasi AI.

### 3. Modul Rekomendasi Dinamis AI (`recommendation_service` & `berita_promosi`)
* **[NEW] `recommendation_service.dart`**: Mengambil produk finansial terpersonalisasi yang dihasilkan oleh model Machine Learning backend (`GET /recommendations/:userId`).
* **[MODIFY] `berita_promosi.dart`**: Alih-alih menampilkan banner statis yang sama untuk semua orang, komparator ini akan mendeteksi hasil klasifikasi model backend. 
  * Jika cluster pengguna adalah `INVESTOR_SAVER`, banner akan merekomendasikan produk investasi reksa dana dengan imbal hasil tinggi.
  * Jika cluster pengguna adalah `TRANSFER_HEAVY`, banner akan mempromosikan promo bebas biaya transfer antar bank dan cashback e-wallet.

### 4. Modul Manajemen Profil (`user_service` & `settings_page`)
* **[NEW] `user_service.dart`**: Mengelola pembacaan profil dinamis (`GET /users/:id`) dan pembaruan detail nama/email (`PUT /users/:id`).
* **[MODIFY] `settings_page.dart`**: Menyediakan formulir pengeditan profil yang modern. Pengguna dapat mengubah nama lengkap dan email resmi mereka, langsung tersinkronisasi dengan database utama backend.

---

## Rencana Verifikasi

### Pengujian Otomatis & Analisis Kode
* Menjalankan perintah `flutter analyze` untuk memastikan 100% kode bersih dari error sintaks, warning const, atau import usang.

### Verifikasi Alur Fungsional
1. **Otentikasi & Sesi**: Pengguna masuk ke aplikasi, memverifikasi data profil dimuat secara dinamis.
2. **Uji Mutasi Riil**: Mengetuk tombol *Connect Gopay*, memverifikasi mutasi saldo terupdate dan langsung tercatat di riwayat transaksi *My Account*.
3. **Uji AI Recommendation**: Membandingkan banner promosi antara user cluster `INVESTOR_SAVER` (menampilkan reksa dana) vs user biasa (menampilkan promosi standard).
4. **Pembaruan Profil & Hukum Persetujuan**: Mengubah nama di halaman pengaturan dan men-toggle persetujuan legalitas, memverifikasi datanya langsung terupdate di PostgreSQL melalui dashboard admin.
