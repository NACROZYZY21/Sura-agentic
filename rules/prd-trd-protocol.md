# Protokol Otomatisasi PRD, TRD, & Design Before Code

Setiap diskusi proyek atau fitur harus bermuara pada dokumentasi aktif di `sura-memory/TRD/PRD.md` dan `sura-memory/TRD/TRD.md`.

---

## 1. Dua Mode Pembuatan PRD & TRD (Repo Existing vs Repo Kosong/Baru)

AI wajib mendeteksi kondisi repositori secara otomatis saat menyusun PRD & TRD:

### Mode A — Repo Sudah Ada Kode (*Existing / Brownfield Repo*)
- **Cara Kerja:**
  1. Pelajari arsitektur yang sudah berjalan menggunakan **Graphify** (`graphify-out/`, `query_graph`, `get_neighbors`) serta struktur folder dan konvensi kode yang ada.
  2. Saat mengisi **PRD & TRD**, petakan langsung mana endpoint/komponen yang berstatus `EXISTING` vs `NEW`.
  3. Isi bagian **Related File**, **Reuse vs Buat Baru**, dan **Blast Radius** (file wajib disentuh vs dilarang disentuh) berdasarkan file nyata di repositori.

### Mode B — Repo Belum Ada Kode / Proyek Baru dari Nol (*Greenfield / From Scratch*)
- **Cara Kerja:**
  1. Jika folder proyek masih kosong atau belum memiliki kode aplikasi, **jangan berhenti atau bingung mencari file**.
  2. Gunakan diskusi (`baca sura` / `brainstorming`) untuk merancang arsitektur dari nol bersama developer sesuai `PROJECT_SCOPE` (`fullstack` / `backend` / `frontend` / `apidef` / `cli-lib`) dan `TEST_MODE`.
  3. Susun **PRD & TRD** sebagai *blueprint* (cetak biru) pembangunan awal: rekomendasikan struktur folder standar, daftar seluruh endpoint/komponen dengan status `NEW`, skema database awal, dan urutan pembuatan file (*scaffolding*) dari langkah pertama.

---

## 2. Siklus Hidup "Satu Proyek Aktif" (Auto-Replace Proyek A → Proyek B)

Agar memori AI selalu fokus, tajam, dan hemat token, folder `sura-memory/TRD/` menerapkan aturan **Single Active PRD & TRD**:

1. **Selama Mengerjakan Proyek/Fitur A:**
   - Dokumen disimpan di `sura-memory/TRD/PRD.md` dan `sura-memory/TRD/TRD.md`.
   - Setiap sesi chat baru (`"baca sura"`), AI wajib membaca kedua file ini sehingga langsung ingat seluruh detail bisnis dan teknis Proyek A tanpa perlu dijelaskan ulang.
2. **Saat Proyek/Fitur A Selesai (`"update sura"`):**
   - AI mencatat ringkasan kelulusan Proyek A (beserta link PR dan *lessons learned*) ke `TASK_LOG.md` dan `MEMORY.md`.
3. **Saat Masuk ke Proyek/Fitur Baru (Proyek B):**
   - **Hapus / Timpa (`Replace`)** isi `sura-memory/TRD/PRD.md` dan `sura-memory/TRD/TRD.md` milik Proyek A, lalu ganti sepenuhnya dengan PRD & TRD baru milik **Proyek B** (begitu juga file desain lama di `sura-memory/designs/` yang sudah selesai).
   - Dengan demikian, `sura-memory/TRD/` tidak pernah menumpuk file usang dan AI tidak pernah mencampuradukkan spesifikasi Proyek A yang sudah selesai dengan Proyek B yang sedang dikerjakan.

---

## 3. Struktur Standar PRD (`sura-memory/TRD/PRD.md`)
1. **Executive Summary:** Konteks bisnis, masalah yang dihadapi saat ini, dan solusi yang dibangun.
2. **Objective & Success Metric:**
   - Bullet poin *Objective* utama.
   - Tabel *Success Metric*: `Metric | Baseline | Target | Definition | How To Measure`.
3. **User Story & Acceptance Criteria:**
   - Tabel: `No (US-01) | Priority (P0/P1/P2) | User Story (As a... I want to... So that...) | Acceptance Criteria (Given / When / Then + Notes) | Design`.
4. **Timeline / Milestone:** Tabel `Sprint / Phase | Goal | User Stories`.
5. **Reference:** Tautan ke `TRD.md`, desain/mockup, atau tiket.

---

## 4. Struktur Standar TRD (`sura-memory/TRD/TRD.md`)
Menyesuaikan `PROJECT_SCOPE` dan kondisi repo (*Existing* maupun *Greenfield*):
1. **Metadata Header:** Tabel tautan ke PRD (`PRD.md`), Design, RBAC, Target Audience, Mode Repo (`Existing` / `Greenfield`), serta `PROJECT_SCOPE` & `TEST_MODE`.
2. **Components (Wajib untuk FE / Fullstack):**
   - Tabel `Scope | Screen Shot / UI | Description` (integrasi API, pagination, search/sort/filter, kolom tabel, *Related API*, *Related File*, *Blocker*).
3. **Flow (Mermaid):**
   - Flow Chart & `sequenceDiagram` lengkap (`Actor → WEB → Backend → Database` beserta percabangan `alt Valid / Invalid`).
4. **API Specification (Wajib untuk BE / Fullstack / ApiDef):**
   - Tabel per endpoint: `Endpoint | Status (NEW/EXISTING) | Method | Description (operationId) | Auth/Header | Query Param | Request Body | Response Body | Related File`.
5. **Database & Blast Radius (Graphify / Blueprint Analysis):**
   - Migration SQL: `Ya / Tidak` beserta tabel/skema terkait.
   - Tabel *Reuse vs Buat Baru* (untuk repo existing) atau *Rancangan Struktur Modul Baru* (untuk repo greenfield).
   - **Blast Radius:** Daftar file **Wajib Disentuh/Dibuat** vs **Dilarang Disentuh**.
6. **Test Plan & Verification (Menyesuaikan `TEST_MODE`):**
   - Jika `strict-tdd` / `flexible`: Tabel skenario test per layer + command verifikasi.
   - Jika `no-test`: Checklist verifikasi build, linter, dan uji manual.
7. **Tasks Breakdown & Story Points:**
   - Tabel `Task ([APIDEF] / [BE] / [FE]) | Assignee | Story Point | Status` beserta `SUM`.
8. **Note / Reference:** Daftar route terkait dan catatan implementasi.
