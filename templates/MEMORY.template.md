# Project Memory & Quick Context

> **Dokumentasi pribadi developer** — disimpan di `sura-memory/` (di-exclude lokal di `.git/info/exclude`).
> Single source of truth untuk konteks instan asisten AI saat dipanggil dengan **`"baca sura"`**.

Terakhir diperbarui: **{{DATE}}**

---

## 🧭 Project Profile
> Profil developer (nama, gaya belajar, preferensi) ada di `~/.sura/profile.md` — berlaku untuk semua proyek.

- **Project Scope:** `{{PROJECT_SCOPE}}` *(fullstack / backend / frontend / apidef / cli-lib)*
- **Testing Mode:** `{{TEST_MODE}}` *(strict-tdd / flexible / no-test)*
- **Repo Condition:** `{{REPO_MODE}}` *(Existing Repo / Greenfield New Repo)*
- **Tech Stack:** {{TECH_STACK}}

---

## 📌 Proyek / Task Aktif Saat Ini
**[{{TASK_TAG}}] {{TASK_NAME}}** — {{START_DATE}} — **In Progress**
- **Deskripsi:** {{TASK_BRIEF_DESCRIPTION}}
- **Fokus:** {{TASK_FOCUS}}
- **Target:** {{TASK_TARGET}}
- **PRD Aktif:** [sura-memory/TRD/PRD.md](TRD/PRD.md) *(Diingat selama proyek ini aktif; diarsipkan ke `TRD/archive/YYYY-MM-DD-<slug>/` lalu diganti baru saat pindah ke proyek baru)*
- **TRD Aktif:** [sura-memory/TRD/TRD.md](TRD/TRD.md) *(Diingat selama proyek ini aktif; diarsipkan ke `TRD/archive/YYYY-MM-DD-<slug>/` lalu diganti baru saat pindah ke proyek baru)*

---

## 🚧 Batasan Proyek (Constraints)

> Hal yang **TIDAK boleh** dilakukan di repo ini. Isi begitu ketemu —
> ini konteks yang paling mahal kalau hilang antar sesi.

- {{CONSTRAINT_1}} <!-- cth: jangan pakai axios langsung, gunakan wrapper api-client internal -->
- **Folder terlarang disentuh:** {{FORBIDDEN_PATHS}} <!-- cth: .claude/memory/ milik tim, migrations/ tanpa izin -->
- **Perintah terlarang dijalankan:** {{FORBIDDEN_COMMANDS}}

---

## 🔗 Rantai Kerja Lintas Repo (Jika Multi-Repo)
- Alur rilis kontrak/kode: `{{CROSS_REPO_FLOW}}` *(cth: ApiDefinition → ApiGo → Backend → WebApp, atau Single Repo)*

---

## 📜 Riwayat Proyek / Task Selesai
- {{COMPLETED_DATE}} — [{{TAG}}] {{TASK_TITLE}} → **Done** (PR: #{{PR_NUMBER}})

---

## 📖 Kamus Domain Bisnis (Domain Glossary)

| Istilah / Akronim | Arti & Konteks Bisnis |
|-------------------|----------------------|
| {{TERM_1}}        | {{EXPLANATION_1}}    |
| {{TERM_2}}        | {{EXPLANATION_2}}    |
