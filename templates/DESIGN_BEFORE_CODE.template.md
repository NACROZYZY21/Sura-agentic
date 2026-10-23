# Design Before Code — Template Wajib (10 Section)

> **Kapan:** AI **wajib** menyajikan desain lengkap ini **sebelum** menulis kode — tunggu konfirmasi `"lanjut"` / `"eksekusi"`.
> **Profil Proyek:** `PROJECT_SCOPE` = `{{PROJECT_SCOPE}}` | `TEST_MODE` = `{{TEST_MODE}}`
> **Lokasi simpan:** `sura-memory/designs/<NAMA_TASK>.md`

---

## Format Wajib (10 Section)

Setiap task baru, AI wajib mengisi 10 section di bawah sesuai `PROJECT_SCOPE`:

### 1. Ringkasan Fitur / Endpoint / Komponen
- **Target (`{{PROJECT_SCOPE}}`):**
  - *Backend:* Method + Path endpoint (atau job/event) & `OperationId` OpenAPI.
  - *Frontend:* Halaman / Route UI & `OperationId` API yang dipanggil.
  - *API Contract (ApiDef):* `OperationId` baru/diubah, Path + Method, status *Breaking Change* (Ya/Tidak).
- **Sumber Kebenaran Logic:** Dokumen PRD/TRD, sistem lama (BFF/legacy), atau tiket.
- **Migration SQL / Perubahan Skema:** Ya / **Tidak** (+ alasan).

### 2. Alur Request / UI (Mermaid)
Diagram `sequenceDiagram` yang menggambarkan aliran data end-to-end sesuai scope (misal: `Actor → FE → Handler → Service → Repo → DB`).

### 3. Logic Bisnis & Aturan Validasi
Bullet poin mengenai filter, sorting, pagination, mapping status, kalkulasi, dan penanganan *edge cases* / error state.

### 4. Reuse vs Buat Baru (Hasil Cek Graphify)
| Komponen / Fungsi Existing | Reuse? (✅/❌) | Lokasi File | Alasan / Catatan |
|---|---|---|---|
| `{{COMPONENT_1}}` | ✅ Extend | `{{FILE_PATH_1}}` | {{REASON_1}} |

### 5. Blast Radius
- **Wajib Disentuh:** Daftar eksplisit file yang akan dibuat atau diedit.
- **Dilarang Disentuh:** Daftar eksplisit file/folder yang tidak boleh tersentuh (contoh: `migrations/` bila tanpa DDL, modul milik tim lain, config global).

### 6. Design per Layer (Adaptif sesuai `{{PROJECT_SCOPE}}`)

#### A. Jika `backend` atau `fullstack` (Sisi Backend):
- **Layer 1 — Handler / Controller:** Transport & validasi input saja (tiru pola handler referensi di repo).
- **Layer 2 — Service / Usecase:** Orkestrasi logika bisnis & aturan domain.
- **Layer 3 — Repository / Data Access:** Query database, filter, sort, pagination, & pemetaan kolom.

#### B. Jika `frontend` atau `fullstack` (Sisi Frontend):
- **Layer 1 — API Client / Service:** Pemanggilan endpoint, header, parameter, & tipe request/response.
- **Layer 2 — Custom Hook / Page State:** Pengelolaan state, filter, pagination, loading, & error.
- **Layer 3 — Presentational Component:** Komponen tabel/form/modal sesuai design system.

#### C. Jika `apidef` / `cli-lib`:
- **Layer 1 — Path / Public Interface:** Definisi endpoint/command, parameter, security, response code.
- **Layer 2 — Components / Schema:** Definisi tipe, validasi enum/required, contoh payload (`example`).
- **Layer 3 — Bundle & Codegen:** Validasi skema dan generasi artefak client/server.

### 7. Kontrak Data (Request / Response / Types)
Ringkasan struct atau interface JSON/TypeScript/Go yang menjadi kontrak antar layer.

### 8. Test Plan & Strategi Verifikasi (Mengikuti `TEST_MODE`: `{{TEST_MODE}}`)
- **Jika `strict-tdd` / `flexible`:**
  | Layer | Skenario Uji Wajib |
  |---|---|
  | Data / Repo / API Module | Happy path, filter/search, empty result, error handling |
  | Service / Hook | Aturan bisnis, kalkulasi, propagasi error |
  | Handler / UI Component | Status 200/render sukses, 400 validation error, state kosong |
- **Jika `no-test`:**
  - Verifikasi kompilasi/build penuh (`{{BUILD_COMMAND}}`).
  - Verifikasi formatter & linter (`{{LINT_COMMAND}}`).
  - Skenario uji fungsional manual (input → ekspektasi output).

**Perintah Verifikasi** *(wajib menggunakan format penjelasan 5-baris `SKILL.md` §6)*:
- Test: `{{TEST_COMMAND}}`
- Lint: `{{LINT_COMMAND}}`
- Build: `{{BUILD_COMMAND}}`

### 9. Keputusan Terbuka Sebelum Koding
Daftar pertanyaan atau asumsi teknis beserta rekomendasi default. **Tunggu konfirmasi developer sebelum mulai menulis kode.**

### 10. Urutan Eksekusi Bertahap
Langkah bernomor dari pembuatan branch, implementasi per layer, hingga verifikasi akhir (`/verify`).
