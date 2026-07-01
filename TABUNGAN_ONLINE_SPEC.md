# 🏗️ Architecture & Implementation Specification: Tabungan Online

Dokumen ini adalah **Spesifikasi Teknis (Spec-Driven Development)** yang dirancang dengan ketat untuk memastikan tidak ada kegagalan arsitektur selama proses pengembangan. Aplikasi "Tabungan Online" akan dibangun dengan standar industri tertinggi menggunakan ekosistem Flutter dan Firebase.

---

## 1. 🌟 System Architecture Overview

Karena kita menargetkan **Android** dengan performa tinggi dan sinkronisasi real-time, arsitektur akan memanfaatkan:

*   **Frontend (Mobile App)**: Flutter (di dalam folder `frontend/`).
*   **Backend as a Service (BaaS)**: Firebase (Authentication, Cloud Firestore).
*   **State Management**: Riverpod (untuk skalabilitas dan keamanan data reactivity).
*   **Shared Kernel**: Package `shared_models` untuk memastikan kontrak data (Data Models) antara Firebase dan Flutter selalu konsisten tanpa duplikasi kode.
*   **Custom Backend (Opsional/Microservice)**: Folder `backend/` (Dart Frog) dapat dipertahankan sebagai webhook processor atau *Admin API* untuk task terisolasi, atau diabaikan jika Firebase Functions sudah cukup.

---

## 2. 🗄️ Database Schema (Cloud Firestore)

Kita akan menggunakan arsitektur NoSQL yang *denormalized* agar akses data di mobile menjadi sangat cepat.

### Collections:
1.  **`users`** (Data profil & saldo agregat)
    *   `uid` (String, Primary Key)
    *   `name` (String)
    *   `email` (String)
    *   `balance` (Number) - *Disinkronisasi secara aman melalui transaksi*
    *   `created_at` (Timestamp)

2.  **`transactions`** (Riwayat mutasi saldo)
    *   `id` (String, Document ID)
    *   `uid` (String, Foreign Key)
    *   `type` (String) -> enum: `DEPOSIT`, `WITHDRAWAL`
    *   `amount` (Number)
    *   `note` (String)
    *   `timestamp` (Timestamp)

3.  **`saving_goals`** (Fitur target tabungan impian)
    *   `id` (String)
    *   `uid` (String)
    *   `title` (String) -> ex: "Beli Laptop"
    *   `target_amount` (Number)
    *   `current_amount` (Number)
    *   `deadline` (Timestamp)
    *   `is_completed` (Boolean)

---

## 3. 🧩 Modul & Struktur Direktori (`frontend`)

Struktur folder akan menggunakan pola **Feature-First Architecture** untuk mencegah spaghetti code:

```text
frontend/lib/
 ├── core/              # Tema, Konfigurasi, Routing (GoRouter), Error Handling
 ├── shared/            # Widget reusable (Button, TextField kustom)
 └── features/
      ├── auth/         # Login & Register
      ├── dashboard/    # Ringkasan saldo & grafik
      ├── transaction/  # Form setor/tarik & list riwayat
      └── goals/        # Manajemen target tabungan
```

---

## 4. 🎨 Design Aesthetics & UI/UX

Mengikuti aturan *Frontend UI Engineering*, aplikasi tidak boleh terlihat seperti aplikasi *template*:
*   **Color Palette**: Deep Emerald Green (`#0F766E`) sebagai primary, dengan aksen Gold/Yellow. Mode gelap (Dark Mode) didukung penuh.
*   **Glassmorphism**: Digunakan pada kartu saldo utama (Balance Card) untuk kesan premium.
*   **Micro-animations**: Animasi transisi antar halaman, loading *skeleton*, dan *confetti* ketika target tabungan tercapai.
*   **Typography**: Menggunakan font Google modern (contoh: *Outfit* atau *Plus Jakarta Sans*).

---

## 5. 🔒 Security & Hardening Rules

1.  **Firestore Security Rules**: Harus ketat. User hanya boleh membaca dan menulis data yang memiliki `uid` milik mereka sendiri.
2.  **Atomic Operations**: Perubahan `balance` (saldo) pada tabel `users` harus dilakukan menggunakan Firestore `Transaction` atau `FieldValue.increment()` bersamaan dengan pembuatan record di tabel `transactions`. Mencegah saldo minus atau *race conditions*.
3.  **Data Validation**: Semua model di `shared_models` akan menggunakan package `freezed` atau `json_serializable` agar type-safe.

---

## 6. 🚀 Fase Eksekusi (Roadmap)

Untuk memastikan aplikasi ini tidak gagal, kita akan mengeksekusinya secara bertahap (Incremental Implementation):

*   **Fase 1: Setup & Konfigurasi**
    *   Membuat Firebase Project dan mengonfigurasi `flutterfire_cli` untuk Android.
    *   Memasang dependensi utama (`firebase_core`, `riverpod`, `freezed`, dll).
*   **Fase 2: Shared Models Construction**
    *   Menulis `UserModel`, `TransactionModel`, `GoalModel` di dalam package `shared_models`.
*   **Fase 3: Authentication Flow**
    *   Membuat UI Login/Register & integrasi Firebase Auth.
*   **Fase 4: Core Engine (Firestore + Provider)**
    *   Membuat Repository pattern untuk CRUD transaksi dan kalkulasi saldo.
*   **Fase 5: Premium UI Implementation**
    *   Membangun UI Dashboard, animasi, dan merakit seluruh komponen.
