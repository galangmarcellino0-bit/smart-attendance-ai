# Smart Attendance AI

> **Sistem Absensi Sekolah Berbasis Pengenalan Wajah AI & Validasi Lokasi (Geofencing)**  
> Dibangun dengan arsitektur **PHP Native MVC**, **Bootstrap 5**, dan **MySQL** untuk lingkungan lokal **XAMPP / Apache**.

---

## 📌 Ringkasan Proyek

Smart Attendance AI adalah platform presensi sekolah cerdas yang mengintegrasikan:
1. **AI Face Recognition**: Validasi biometrik wajah siswa dengan ambang batas kemiripan (*similarity threshold*) serta deteksi *liveness* (anti-spoofing). Template disimpan dalam bentuk vektor fitur biometrik terenkripsi (AES-256 GCM) dengan verifikasi integritas hash SHA-256 tanpa menyimpan foto mentah.
2. **Geofencing GPS**: Pembatasan radius absensi fisik di area kampus/sekolah (radius default 150 meter).
3. **Multi-Role Portal**: Tampilan dan hak akses terpisah untuk **Super User (Admin)**, **Guru Pengajar**, **Wali Kelas**, dan **Murid / Siswa**.
4. **Relational MySQL Database**: 15 tabel relasional ternormalisasi dengan integritas referensial penuh (Foreign Keys, Unique Constraints, Indexing, dan Audit Logging).

---

## 🗂 Struktur Direktori (MVC Architecture)

```
tugas prd/
├── .env                              # File konfigurasi lokal aktif (Kredensial tidak di-commit ke repo)
├── .env.example                      # Template environment variables
├── .htaccess                         # Apache rewrite ke direktori public & proteksi direktori privat
├── README.md                         # Dokumentasi panduan instalasi & arsitektur
├── app/                              # Logika Inti Aplikasi (Di luar direktori public)
│   ├── Config/
│   │   ├── app.php                   # Konfigurasi nama, timezone, role, AI threshold, geofence
│   │   └── database.php              # Konfigurasi koneksi PDO MySQL
│   ├── Core/
│   │   ├── Autoloader.php            # PSR-4 Class Loader otomatis
│   │   ├── Env.php                   # Parser file .env
│   │   ├── Database.php              # Singleton koneksi PDO MySQL dengan prepared statements
│   │   ├── Router.php                # Request router & URL dispatcher
│   │   ├── Controller.php            # Base controller (view rendering, auth check, CSRF)
│   │   ├── Model.php                 # Base model PDO query helper
│   │   ├── Request.php               # Abstraksi HTTP Request
│   │   ├── Response.php              # Abstraksi HTTP Response (redirect & JSON)
│   │   ├── Session.php               # Session, flash message, dan token CSRF
│   │   └── Auth.php                  # Status login dan manajemen hak akses role
│   ├── Controllers/
│   │   ├── AuthController.php        # Login, logout, dan pengalih peran demo
│   │   ├── DashboardController.php   # Dispatcher dashboard per role
│   │   ├── AttendanceController.php  # Monitoring presensi & simulasi AI check-in
│   │   └── ErrorController.php       # Tampilan halaman 404 & 500
│   ├── Models/
│   │   ├── User.php                  # Autentikasi dan data pengguna
│   │   ├── Attendance.php            # Statistik presensi dan log biometrik
│   │   └── Classroom.php             # Data kelas dan daftar siswa
│   └── Views/
│       ├── layouts/                  # Template layout modular (Header, Navbar, Sidebar, Footer, Breadcrumb)
│       ├── auth/                     # Halaman Login modern
│       ├── dashboard/                # Dashboard terpisah (admin.php, teacher.php, homeroom.php, student.php)
│       ├── attendance/               # Halaman tabel log presensi lengkap
│       ├── components/               # Komponen UI: card_stat, empty_state, loading_skeleton, toast
│       └── errors/                   # Halaman kesalahan HTTP 404 & 500
├── database/
│   ├── schema.sql                    # Skema 15 tabel relasional MySQL
│   ├── seed.sql                      # Data awal pengguna, peran, kelas, jadwal, dan sampel presensi
│   ├── install.php                   # Skrip CLI migrasi & instalasi database otomatis
│   └── test_connection.php           # Skrip CLI pengujian koneksi & integritas skema
├── public/                           # Web Root Publik (Hanya folder ini yang terekspos Apache)
│   ├── .htaccess                     # Front Controller Rewrite ke index.php
│   ├── index.php                     # Front Controller tunggal
│   └── assets/
│       ├── css/app.css               # Tema kustom warna Navy & Teal, utilitas, animasi scan
│       ├── js/app.js                 # Skrip interaktif kamera simulator, filter, autofill
│       └── img/                      # Asset grafis & ikon
└── storage/                          # Direktori penyimpanan internal
    ├── cache/
    ├── logs/
    └── uploads/
```

---

## 🗄️ 15 Tabel Relasional Database

| No | Nama Tabel | Deskripsi & Fungsi Kunci |
|---|---|---|
| 1 | `users` | Akun autentikasi utama (`email`, `phone`, `password_hash`, `status`). |
| 2 | `roles` | Daftar hak akses (`super_admin`, `teacher`, `homeroom`, `student`). |
| 3 | `user_roles` | Relasi *many-to-many* antara pengguna dan peran yang dimiliki. |
| 4 | `students` | Profil identitas siswa, nomor induk (`nis`, `nisn`, `full_name`, `gender`, wali). Terpisah dari `users`. |
| 5 | `teachers` | Profil identitas guru (`nip`, `nuptk`, `full_name`, `qualification`, `specialization`). Terpisah dari `users`. |
| 6 | `classes` | Data rombongan belajar (`grade_level`, `major`, `academic_year`). |
| 7 | `class_students` | Relasi penempatan siswa di kelas pada tahun ajaran tertentu (`status`, `enrolled_at`). |
| 8 | `homeroom_assignments` | Penugasan wali kelas unik per kelas & tahun ajaran (1 guru hanya untuk 1 kelas). |
| 9 | `face_profiles` | Vektor descriptor wajah terenkripsi (`encrypted_embedding`, `feature_vector_hash`). |
| 10 | `school_locations` | Koordinat titik pusat sekolah, toleransi radius geofence (`radius_meters`), alamat. |
| 11 | `class_locations` | Pemetaan ruangan / area presensi khusus tiap kelas. |
| 12 | `attendance_schedules` | Jadwal jam masuk, batas toleransi terlambat (*late threshold*), dan jam pulang per hari. |
| 13 | `attendance_records` | Data kehadiran, hasil pencocokan AI (`face_similarity_score`, `liveness_score`), jarak GPS, dan status validasi. Memiliki *composite unique key* agar siswa tidak dobel presensi di sesi yang sama. |
| 14 | `otp_verifications` | Verifikasi OTP aman ber-hash SHA-256 (`otp_hash`, `purpose`, `expires_at`, `attempts`). |
| 15 | `attendance_corrections` | Pengajuan surat izin/sakit, bukti dokumen lampiran, dan persetujuan wali kelas. |
| 16 | `audit_logs` | Jejak rekam aktivitas penting sistem (`action`, `entity_type`, `old_values`, `new_values`, `ip_address`). |

---

## 🚀 Panduan Migrasi & Instalasi Database

1. **Jalankan Apache & MySQL di XAMPP**:
   Buka XAMPP Control Panel dan klik **Start** pada modul **Apache** dan **MySQL**.

2. **Eksekusi Migrasi & Seeding Otomatis**:
   Buka terminal di root proyek dan jalankan:
   ```bash
   C:\xampp\php\php.exe database/install.php
   ```
   *Skrip ini bersifat idempoten (dapat dijalankan berulang kali dengan aman).*

3. **Uji Integritas Koneksi & Skema**:
   ```bash
   C:\xampp\php\php.exe database/test_connection.php
   ```

4. **Metode Manual via phpMyAdmin**:
   Jika Anda lebih memilih antarmuka web:
   - Buka `http://localhost/phpmyadmin`.
   - Buat database `smart_attendance_ai`.
   - Impor file `database/schema.sql`.
   - Impor file `database/seed.sql`.

---

## 🔐 Kredensial Uji Coba (Demo Accounts)

| Peran (*Role*) | Email / NIP / NISN | Kata Sandi |
|---|---|---|
| **Super User (Admin)** | `admin@school.id` / `19800101001` | `admin123` |
| **Guru Pengajar** | `guru@school.id` / `19850202002` | `guru123` |
| **Wali Kelas** | `walikelas@school.id` / `19870303003` | `wali123` |
| **Murid / Siswa** | `murid@school.id` / `20241001` | `murid123` |
