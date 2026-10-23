# Task Logbook & Detailed History

Dokumentasi detail dari setiap task yang dikerjakan.

> ⚠️ **Batas Ukuran Hemat Token:** Simpan hanya **task aktif + maksimal 2 task selesai terakhir** di file ini.
> Saat menjalankan **`"update sura"`**, pindahkan entri `Done` yang lebih lama ke `TASK_LOG.archive.md` — file arsip tidak dibaca otomatis oleh AI kecuali diminta eksplisit.
> Saat berpindah dari **Proyek/Fitur A (Done)** ke **Proyek/Fitur B (Baru)**, hapus isi `sura-memory/TRD/PRD.md` dan `sura-memory/TRD/TRD.md` lama lalu ganti dengan spesifikasi Proyek/Fitur B.

---

## [{{YYYY-MM-DD}}] - [{{TAG}}] {{TASK_TITLE}} - STATUS: In Progress

- **Deskripsi:** {{DETAILED_TASK_DESCRIPTION}}
- **Profil Eksekusi:** Scope = `{{PROJECT_SCOPE}}` | Test Mode = `{{TEST_MODE}}`
- **Dokumen Aktif:**
  - **PRD:** `sura-memory/TRD/PRD.md`
  - **TRD:** `sura-memory/TRD/TRD.md`
- **File / Folder Terdampak (Blast Radius):**
  - `{{PATH_TO_FILE_1}}`
  - `{{PATH_TO_FILE_2}}`
- **Branch:** `feat/{{BRANCH_NAME}}`
- **PR:** #{{PR_NUMBER}}

### 🧠 Keputusan Arsitektur & Analisis Graphify:
1. **Pendekatan Solusi:** {{WHY_WE_CHOSE_THIS_APPROACH}}
2. **Batasan / Constraints:** {{CONSTRAINTS_AND_RULES}}

### 📝 Checklist Pengerjaan:
- [ ] Step 1: Diskusi kebutuhan & pembuatan otomatis `sura-memory/TRD/PRD.md` + `TRD.md`
- [ ] Step 2: Implementasi kode bertahap sesuai layer di `TRD.md` / `DESIGN_BEFORE_CODE.md`
- [ ] Step 3: Verifikasi kualitas (`/verify` — test / linter / build sesuai `TEST_MODE`)
- [ ] Step 4: Clean git commit (tanpa trailer AI), buka PR, & jalankan `"update sura"`

### 💡 Revisi & Lessons Learned:
- {{LESSONS_LEARNED_NOTES}}
