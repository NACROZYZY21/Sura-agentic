# Project Conventions

> Standar profil proyek, arsitektur, koding, dan git khusus repositori ini.
> Aturan operasional AI ada di rules Sura Protocol (`SOUL.md` / `RULES.md`),
> bukan di sini — jangan diduplikasi.

Terakhir diperbarui: **{{DATE}}**

---

## ⚙️ Profil Konfigurasi Proyek (Dibaca Otomatis oleh AI)
- **`PROJECT_SCOPE`:** `{{PROJECT_SCOPE}}`
  - Pilihan valid: `fullstack` | `backend` | `frontend` | `apidef` | `cli-lib`
- **`TEST_MODE`:** `{{TEST_MODE}}`
  - Pilihan valid: `strict-tdd` (wajib unit/integration test) | `flexible` (test untuk logika krusial) | `no-test` (tanpa file test baru; fokus verifikasi build & linter)

---

## 🏛️ Arsitektur

### A. Struktur Folder Proyek
```text
{{FOLDER_STRUCTURE_OVERVIEW}}
```

### B. Perintah Utama Proyek
*(Detail lengkap & penjelasan alur ada di [COMMANDS.md](COMMANDS.md))*
- **Install:** `{{INSTALL_COMMAND}}`
- **Run Dev:** `{{DEV_COMMAND}}`
- **Test:** `{{TEST_COMMAND}}`
- **Lint / Format:** `{{LINT_COMMAND}}`
- **Build / Generate:** `{{BUILD_COMMAND}}`

### C. Standar Kualitas & Layer Rules
- **Framework Testing:** {{TESTING_FRAMEWORK}} (Mengikuti `TEST_MODE`: `{{TEST_MODE}}`)
- **Batas Kompleksitas Kode:** Cognitive Complexity ≤ 15 per fungsi, Coverage kode baru ≥ 60% (bila `TEST_MODE` = `strict-tdd`).
- **Formatter & Linter:** Wajib 0 error/warning sebelum membuka PR.
- **Rules Layer Internal Repo:** Periksa `.claude/rules/` atau dokumentasi tim di repo ini bila tersedia.

---

## 🌿 Konvensi Git & Pull Request

- **Format Commit:** `feat(...)`, `fix(...)`, `refactor(...)`, `docs(...)`, `chore(...)`.
- **Bersih dari Jejak AI:** Hapus semua trailer `Co-authored-by` AI pada commit & deskripsi PR.
- **Sinkronisasi Branch:** Rebase onto `{{MAIN_BRANCH}}` sebelum membuka PR.
- **Squash Commit:** Squash menjadi 1 commit rapi per PR.

### Label Wajib Pull Request
- `enhancement` — fitur baru atau peningkatan fitur yang ada
- `bug` — perbaikan bug yang terjadi di Production
- `defect` — perbaikan bug yang terjadi di Staging (belum rilis ke Production)
- `dependencies` — pembaruan dependensi / library / package (misal bump ApiGo / npm)
- `documentation` — pull request khusus dokumentasi

> 💡 Gunakan: `gh pr create --label "enhancement" ...`
