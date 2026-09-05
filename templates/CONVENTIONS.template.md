# Project Conventions

> Standar arsitektur, koding, dan git khusus proyek ini.
> Aturan operasional AI ada di rules Sura Protocol (`SOUL.md` / `RULES.md`),
> bukan di sini — jangan diduplikasi.

Terakhir diperbarui: **{{DATE}}**

---

## 🏛️ Arsitektur

### A. Struktur Folder
```text
{{FOLDER_STRUCTURE_OVERVIEW}}
```

### B. Perintah Penting
- Install: `{{INSTALL_COMMAND}}`
- Run dev: `{{DEV_COMMAND}}`
- Test: `{{TEST_COMMAND}}`
- Lint / format: `{{LINT_COMMAND}}`
- Build: `{{BUILD_COMMAND}}`

### C. Standar Kualitas
- Framework testing: {{TESTING_FRAMEWORK}}
- Batas kompleksitas kode (Cognitive Complexity).
- Formatter & linter wajib lolos sebelum PR.

---

## 🌿 Konvensi Git & Pull Request

- Format commit: `feat(...)`, `fix(...)`, `refactor(...)`.
- Hapus semua AI commit co-authored trailer (misal `Co-authored-by: Cursor`).
- Rebase onto `{{MAIN_BRANCH}}` sebelum PR.
- Squash menjadi 1 commit rapi per PR.

### Label Wajib Pull Request
- `enhancement` — fitur baru atau peningkatan
- `bug` — perbaikan bug yang terjadi di Production
- `defect` — perbaikan bug yang terjadi di Staging (belum ke Production)
- `dependencies` — pembaruan dependensi / library / package
- `documentation` — pull request khusus dokumentasi

> 💡 Gunakan: `gh pr create --label "enhancement" ...`
