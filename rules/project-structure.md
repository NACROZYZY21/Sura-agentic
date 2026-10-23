# Protokol Profil Proyek & Struktur Folder Adaptif

Sura-agentic beradaptasi dengan arsitektur dan kondisi repositori tempat ia dipasang — baik **Repo yang Sudah Ada (*Existing / Brownfield*)** maupun **Repo Baru dari Nol (*Greenfield*)**. Selalu periksa blok **Profil Proyek** di `sura-memory/CONVENTIONS.md`.

## 1. Adaptasi Berdasarkan Kondisi Repo (Existing vs Greenfield)
- **Repo Sudah Ada Kode (*Existing / Brownfield*):**
  - Pelajari struktur folder, arsitektur layer, dan kode yang sudah berjalan melalui **Graphify** (`graphify-out/`) sebelum menyusun PRD & TRD.
  - Ikuti pola penamaan, konvensi handler/service/repo/component yang sudah ada di repo tersebut.
- **Repo Belum Ada Kode (*Greenfield / Baru Mulai*):**
  - Bantu developer merancang struktur folder terbaik dari nol sesuai `PROJECT_SCOPE`.
  - Jadikan `sura-memory/TRD/PRD.md` dan `sura-memory/TRD/TRD.md` sebagai cetak biru (*blueprint*) awal sebelum membuat struktur folder dan file kode pertama.

## 2. Adaptasi Berdasarkan Scope Proyek (`PROJECT_SCOPE`)
- **`fullstack` (Frontend + Backend):**
  - Saat menyusun TRD & Design Before Code, sertakan kontrak API, alur Backend (Handler → Service → Repo → DB), serta komponen Frontend (API Client → Hook/State → UI).
  - Pastikan urutan kerja selalu menjaga rantai dependensi: **Kontrak API → Backend → Frontend**.
- **`backend` (Backend Only):**
  - Fokuskan TRD & Design Before Code pada spesifikasi Endpoint, Validasi, Logic Bisnis Service, Query Repository/Database, Migration SQL, dan performa/keamanan.
  - Abaikan seksi komponen UI/visual kecuali sebagai konteks pemanggil API.
- **`frontend` (Frontend / WebApp Only):**
  - Fokuskan TRD & Design Before Code pada Halaman/Route, Komponen UI, State Management, Pagination/Filter, Integrasi API Client, dan penanganan Error/Empty/Loading state.
  - Sebelum koding integrasi, selalu cek apakah endpoint Backend sudah siap atau masih stub/mock.
- **`apidef` / `cli-lib` (API Contract / CLI / Library):**
  - Fokuskan TRD & Design Before Code pada skema kontrak (OpenAPI/Swagger/Protobuf) atau antarmuka fungsi publik, kompatibilitas *breaking changes*, validasi skema, dan alur rilis/tag.

## 3. Adaptasi Berdasarkan Kebijakan File Test (`TEST_MODE`)
- **`strict-tdd` (Wajib Unit/Integration Test):**
  - Aktifkan penuh disiplin TDD (`superpowers:test-driven-development`): tulis/perbarui test per layer (Repo, Service, Handler, atau Component) dan pastikan seluruh test **PASS** serta memenuhi batas coverage proyek sebelum PR.
- **`flexible` (Test Selektif / Logika Krusial):**
  - Buat unit test untuk business logic utama, kalkulasi, atau bug fix krusial. Untuk perubahan konfigurasi/UI minor, prioritaskan linter, typecheck, dan test yang sudah ada agar tidak rusak.
- **`no-test` (Tanpa File Test Baru):**
  - **Jangan** membuat file `*.test.*` / `*_test.*` baru kecuali diminta eksplisit.
  - Alihkan tahap verifikasi wajib ke: **Build sukses (`exit 0`) + Linter/Formatter bersih (`0 error`) + Checklist verifikasi fungsional manual**.

## 4. Kesadaran Multi-Repo & Sibling Repositories
Jika proyek berada di dalam ekosistem multi-repo (seperti pola `ApiDefinition → ApiGo → Backend → WebApp`):
- Periksa bagian **Sibling Repositories** di `sura-memory/README.md` dan `sura-memory/MEMORY.md`.
- Baca cheat sheet perintah lintas repo (`COMMANDS.md`) bila task membutuhkan sinkronisasi antar repositori.
- Jaga *Blast Radius* tetap ketat: hanya ubah file di repo aktif saat ini, dan catat dependensi ke repo sibling di dalam TRD / Task Log.

## 5. Peta Standar Folder `sura-memory/`
Seluruh artefak kerja AI disimpan rapi di dalam `sura-memory/` (terlindungi di `.git/info/exclude`):
- `MEMORY.md` — Konteks utama, profil developer, task aktif, batasan proyek, kamus domain.
- `CONVENTIONS.md` — Profil proyek (`PROJECT_SCOPE`, `TEST_MODE`), arsitektur folder, perintah utama, standar Git/PR.
- `COMMANDS.md` — Cheat sheet perintah terminal spesifik proyek beserta penjelasannya.
- `SKILL.md` — Kumpulan jurus operasional (`/design`, `/verify`, `/retro`, `/review-pr`, `/clean`).
- `DESIGN_BEFORE_CODE.md` — Template 10-section wajib sebelum menulis kode.
- `PR_REVIEW_PLAYBOOK.md` — Standar checklist review PR & panen revisi.
- `TASK_LOG.md` & `TASK_LOG.archive.md` — Logbook task aktif (maks 3 task) & arsip riwayat.
- `TRD/PRD.md` & `TRD/TRD.md` — Dokumen **PRD & TRD aktif saat ini** (otomatis diingat selama Proyek A berjalan; dihapus & diganti baru saat Proyek A selesai dan pindah ke Proyek B).
- `designs/` — Breakdown desain teknis task yang sedang aktif.
- `reviews/` — Catatan hasil review PR (`PR_<nomor>_<slug>.md`).
- `lessons/` — Catatan kesalahan teknis / post-mortem agar tidak terulang di sesi berikutnya.
