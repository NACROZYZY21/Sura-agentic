# sura-memory

> Dokumentasi pribadi developer (Sura-agentic). **Di-exclude lokal di `.git/info/exclude`** — tidak pernah ter-commit ke repo tim.

Terakhir diperbarui: **{{DATE}}**

## 🎯 Profil Proyek Aktif
- **Project Scope:** `{{PROJECT_SCOPE}}` *(fullstack / backend / frontend / apidef / cli-lib)*
- **Testing Mode:** `{{TEST_MODE}}` *(strict-tdd / flexible / no-test)*

## 📂 Peta Isi Folder

| File / Folder | Fungsi Utama |
|---|---|
| [MEMORY.md](MEMORY.md) | **Entry point** — konteks instan proyek, task aktif, batasan, glossary |
| [CONVENTIONS.md](CONVENTIONS.md) | Profil proyek, struktur arsitektur, perintah utama, konvensi Git & PR |
| [COMMANDS.md](COMMANDS.md) | **Cheat sheet perintah** terminal spesifik proyek ini |
| [SKILL.md](SKILL.md) | Jurus operasional (`/design`, `/verify`, `/retro`, `/review-pr`, `/clean`) + format penjelasan perintah |
| [DESIGN_BEFORE_CODE.md](DESIGN_BEFORE_CODE.md) | Template wajib 10-section sebelum menulis kode |
| [PR_REVIEW_PLAYBOOK.md](PR_REVIEW_PLAYBOOK.md) | Standar checklist saat me-review PR & aturan panen revisi |
| [TASK_LOG.md](TASK_LOG.md) | Log lifecycle task aktif + maks 2 task selesai terakhir |
| `TASK_LOG.archive.md` | Arsip task lama (tidak dibaca otomatis kecuali diminta) |
| [TRD/PRD.md](TRD/PRD.md) & [TRD/TRD.md](TRD/TRD.md) | **PRD & TRD aktif saat ini** (bisa dari repo existing maupun repo baru; diarsipkan ke `TRD/archive/YYYY-MM-DD-<slug>/` lalu diganti baru saat pindah dari Proyek A ke Proyek B) |
| `designs/` | Breakdown desain teknis task yang sedang aktif |
| `reviews/` | Catatan tiap review PR (`PR_<nomor>_<slug>.md`) — tidak dibaca otomatis |
| `lessons/` | Catatan post-mortem / kesalahan teknis agar tidak terulang |

## 🔗 Sibling Repositories (Untuk Workspace Multi-Repo)

| Repo | Peran dalam Rantai Kerja | Lokasi Cheat Sheet |
|---|---|---|
| `{{SIBLING_REPO_1}}` | {{SIBLING_ROLE_1}} *(cth: ApiDefinition → ApiGo → Backend → WebApp)* | `../{{SIBLING_REPO_1}}/sura-memory/COMMANDS.md` |
