---
name: sura-prd-trd
description: Gunakan saat developer mengetik "baca sura" atau "update sura", saat menulis/memperbarui sura-memory/TRD/PRD.md atau TRD.md, atau saat berpindah dari satu fitur/proyek ke fitur/proyek berikutnya.
---

# Protokol PRD, TRD, & Siklus Hidup Fitur

Setiap diskusi proyek atau fitur harus bermuara pada dokumentasi aktif di `sura-memory/TRD/PRD.md` dan `sura-memory/TRD/TRD.md`.

## 1. `baca sura` — Langkah Detail
1. Baca `sura-memory/MEMORY.md`, `CONVENTIONS.md`, dan `TASK_LOG.md`.
2. Jika ada task aktif (atau pertanyaan menyangkut fitur aktif), baca juga `TRD/PRD.md` & `TRD/TRD.md`.
3. Deteksi kondisi repo (bagian 2) lalu diskusikan kebutuhan sampai matang.
4. Setelah disetujui developer, tulis/perbarui `TRD/PRD.md` & `TRD/TRD.md` sebelum menulis kode.

## 1b. Alur `build prd` → `build trd` → `eksekusi`
Dokumen dianggap **masih template** bila masih memuat placeholder `{{...}}` atau bagian intinya kosong.
1. **`build prd`:** bila PRD fitur lama sudah selesai, arsipkan dulu (bagian 3). Diskusi satu pertanyaan per giliran, lalu tulis PRD (struktur bagian 4) setelah disetujui. Beri nomor setiap user story: `US-01`, `US-02`, ...
2. **`build trd`:** tolak bila PRD masih template — arahkan ke `build prd`. Petakan kode (Mode A/B, bagian 2), tulis TRD (struktur bagian 5). Setiap user story PRD wajib muncul di TRD: kolom *User Story* di tabel Tasks Breakdown menyebut `US-xx`; user story tanpa task = TRD belum selesai.
3. **`eksekusi`:** tolak bila TRD masih template — arahkan ke `build trd`. Ambil task berikutnya yang belum `Done` (atau nomor yang diminta), sajikan Tujuan → Lokasi → Arahan → Verifikasi, tunggu "lanjut", kerjakan, verifikasi sesuai `TEST_MODE`, lalu tandai status task di TRD & `TASK_LOG.md`. Satu task per giliran.

## 2. Dua Mode Pembuatan PRD & TRD

### Mode A — Repo Sudah Ada Kode (*Existing / Brownfield*)
1. Pelajari arsitektur yang berjalan (Graphify bila `graphify-out/` ada, struktur folder, konvensi kode).
2. Petakan endpoint/komponen berstatus `EXISTING` vs `NEW`.
3. Isi **Related File**, **Reuse vs Buat Baru**, dan **Blast Radius** (wajib disentuh vs dilarang disentuh) berdasarkan file nyata di repositori.

### Mode B — Repo Belum Ada Kode (*Greenfield / From Scratch*)
1. Jika folder proyek masih kosong, **jangan berhenti atau bingung mencari file**.
2. Rancang arsitektur dari nol bersama developer lewat sesi diskusi kebutuhan, sesuai `PROJECT_SCOPE` dan `TEST_MODE`.
3. Susun PRD & TRD sebagai *blueprint*: struktur folder standar, seluruh endpoint/komponen berstatus `NEW`, skema database awal, dan urutan *scaffolding*.

## 3. Siklus Hidup "Satu Fitur Aktif" (Arsip, Bukan Hapus)
1. **Selama mengerjakan Fitur A:** dokumen aktif ada di `TRD/PRD.md` & `TRD/TRD.md`.
2. **Saat Fitur A selesai (`update sura`):**
   - Tandai task selesai di `TASK_LOG.md` & `MEMORY.md` (nomor PR + *lessons learned*).
   - Untuk tiap *lesson learned*, tanya developer: **berlaku umum atau khusus proyek ini?** Khusus proyek → `sura-memory/lessons/`. Umum → tulis ulang tanpa nama perusahaan, endpoint internal, token, atau detail rahasia, lalu tambahkan ke `~/.sura/lessons.md` **hanya setelah persetujuan developer**.
   - `TASK_LOG.md` hanya memuat task aktif + maksimal 2 task selesai terakhir; entri lebih lama pindah ke `TASK_LOG.archive.md`.
3. **Saat masuk ke Fitur B:**
   - Pindahkan `TRD/PRD.md`, `TRD/TRD.md`, dan file `designs/` milik Fitur A ke `sura-memory/TRD/archive/YYYY-MM-DD-<slug>/`.
   - Render PRD & TRD baru untuk Fitur B dari template.
   - Arsip **tidak dibaca otomatis** — buka hanya saat relevan atau diminta. Jejak keputusan tetap utuh, token tetap hemat.

## 4. Struktur Standar PRD (`sura-memory/TRD/PRD.md`)
1. **Executive Summary:** Konteks bisnis, masalah saat ini, dan solusi yang dibangun.
2. **Objective & Success Metric:** Bullet *Objective* + tabel `Metric | Baseline | Target | Definition | How To Measure`.
3. **User Story & Acceptance Criteria:** Tabel `No (US-01) | Priority (P0/P1/P2) | User Story (As a... I want to... So that...) | Acceptance Criteria (Given / When / Then + Notes) | Design`.
4. **Timeline / Milestone:** Tabel `Sprint / Phase | Goal | User Stories`.
5. **Reference:** Tautan ke `TRD.md`, desain/mockup, atau tiket.

## 5. Struktur Standar TRD (`sura-memory/TRD/TRD.md`)
Menyesuaikan `PROJECT_SCOPE` dan kondisi repo:
1. **Metadata Header:** Tautan PRD, Design, RBAC, Target Audience, Mode Repo (`Existing` / `Greenfield`), `PROJECT_SCOPE` & `TEST_MODE`.
2. **Components (Wajib untuk FE / Fullstack):** Tabel `Scope | Screen Shot / UI | Description` (integrasi API, pagination, search/sort/filter, kolom tabel, *Related API*, *Related File*, *Blocker*).
3. **Flow (Mermaid):** Flow Chart & `sequenceDiagram` (`Actor → WEB → Backend → Database` beserta `alt Valid / Invalid`).
4. **API Specification (Wajib untuk BE / Fullstack / ApiDef):** Tabel `Endpoint | Status (NEW/EXISTING) | Method | Description (operationId) | Auth/Header | Query Param | Request Body | Response Body | Related File`.
5. **Database & Blast Radius:** Migration SQL `Ya / Tidak`; tabel *Reuse vs Buat Baru* (existing) atau *Rancangan Struktur Modul Baru* (greenfield); daftar file **Wajib Disentuh/Dibuat** vs **Dilarang Disentuh**.
6. **Test Plan & Verification (sesuai `TEST_MODE`):** `strict-tdd` / `flexible` → tabel skenario test per layer + command; `no-test` → checklist build, linter, uji manual.
7. **Tasks Breakdown & Story Points:** Tabel `Task ([APIDEF] / [BE] / [FE]) | Assignee | Story Point | Status` beserta `SUM`, plus tautan ke plan implementasi bila ada.
8. **Note / Reference:** Route terkait dan catatan implementasi.
