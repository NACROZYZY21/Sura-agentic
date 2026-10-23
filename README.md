
# ⚡ Sura-agentic

> **Portable AI Pair-Programming Framework for Modern Software Engineers**  
> *Sura Memory System • Graphify Knowledge Graph • Superpowers Execution • Auto PRD/TRD Engine • Adaptive Project Profile*

---

## 🌟 Mengapa Toolkit Ini Dibuat?

Bekerja bersama AI coding assistant (Antigravity, Gemini CLI, Claude Code, Cursor) sering kali menghadapi 4 masalah besar:
1. **AI Cepat Amnesia:** Setiap sesi baru, AI lupa konteks arsitektur, histori tiket, rantai dependensi lintas repo, dan standar tim.
2. **Hasil Diskusi Hilang di Chat:** Diskusi panjang bersama AI tidak menghasilkan dokumen **PRD**, **TRD**, atau **Design Before Code** yang terstruktur.
3. **Token Boncos (Cache Read Bengkak):** AI membaca seluruh folder `node_modules`, cache compiler Go/JS, dan log raksasa.
4. **AI Kaku & Asal Eksekusi:** AI langsung mengedit kode tanpa izin, atau memaksakan pembuatan file test pada proyek yang sedang tidak membutuhkan test.

**Sura-agentic** menyatukan tiga kekuatan utama (**Sura Memory** + **[Graphify](https://github.com/Graphify-Labs/graphify)** + **[Superpowers](https://github.com/obra/superpowers)**) menjadi framework portabel 1-klik yang mengubah AI menjadi **navigator senior yang disiplin, hemat token, dan adaptif terhadap profil proyek**.

---

## 🏛️ 6 Pilar Utama

| Pilar | Deskripsi | Manfaat |
|---|---|---|
| 🧠 **Sawitpro-Grade Memory** | Ekosistem `sura-memory/` lengkap (`MEMORY`, `CONVENTIONS`, `COMMANDS`, `SKILL`, `DESIGN_BEFORE_CODE`, `PR_REVIEW_PLAYBOOK`, `TASK_LOG`, `TRD/`, `designs/`, `reviews/`, `lessons/`) | AI langsung paham konteks proyek & rantai kerja lintas repo tanpa perlu dijelaskan dari nol. |
| 📋 **Auto PRD & TRD Engine** | Otomatis menghasilkan dokumen `PRD` & `TRD` standar industri dari hasil diskusi sebelum ngoding dimulai, lalu disinkronkan saat `update sura` | Setiap fitur memiliki spesifikasi bisnis (User Story, Metrics) dan teknis (Sequence Diagram, API, Blast Radius, Story Points) yang rapi. |
| 🎯 **Adaptive Project Profile** | Mendukung pilihan Scope (`fullstack`, `backend`, `frontend`, `apidef`, `cli-lib`) & Mode Test (`strict-tdd`, `flexible`, `no-test`) | Aturan AI, template TRD, dan gerbang verifikasi otomatis menyesuaikan jenis proyek (pakai file test maupun tanpa test). |
| 🗺️ **Graphify Engine** | Integrasi AST knowledge graph (`graphify-out/`) untuk analisis *Blast Radius* | AI memetakan relasi komponen dan file yang wajib/dilarang disentuh tanpa membaca puluhan file mentah. |
| ⚡ **Superpowers Workflow** | Orkestrasi *brainstorming*, *TDD*, *systematic-debugging*, & *verification-before-completion* | Mencegah halusinasi dan memastikan setiap klaim selesai dibuktikan dengan output terminal nyata. |
| 🛡️ **Zero Token Waste & Git Safe** | Filter `.ignore` universal + proteksi otomatis di `.git/info/exclude` | Memotong 70–80% konsumsi token dan **100% aman dari kebocoran ke PR/commit tim**. |

---

## 🚀 Cara Pasang di Proyek Apapun (1-Klik Saja)

### 1. Clone Toolkit Ini ke Laptop Kamu
```bash
git clone https://github.com/NACROZYZY21/Sura-agentic.git ~/Sura-agentic
```

### 2. Pasang ke Proyek yang Sedang Dikerjakan
Masuk ke folder proyek target, lalu jalankan installer:

```bash
# Mode Interaktif (memilih Scope Proyek & Kebijakan File Test)
bash ~/Sura-agentic/install.sh

# Atau Mode Cepat via Flag CLI:
bash ~/Sura-agentic/install.sh --scope backend --test strict-tdd
bash ~/Sura-agentic/install.sh --scope frontend --test no-test
bash ~/Sura-agentic/install.sh --non-interactive
```

**Selesai!** Script akan otomatis:
* ✅ Menyiapkan folder `sura-memory/` beserta seluruh template dokumen & subfolder (`TRD/`, `designs/`, `reviews/`, `lessons/`).
* ✅ Memasang filter penghemat token (`.ignore`, `.cursorignore`, `.geminiignore`) tanpa menimpa kustomisasi yang sudah ada.
* ✅ Meng-compile rule AI sesuai profil proyek untuk **Antigravity** (`.agents/rules/`), **Gemini CLI** (`GEMINI.md`), **Claude Code** (`CLAUDE.md` / `CLAUDE.local.md`), dan **Cursor** (`.cursor/rules/`).
* ✅ Mengamankan seluruh konfigurasi ke `.git/info/exclude` (**0% risiko bocor ke Git tim**).

---

## 💬 Kata Kunci & Jurus Harian

| Perintah di Chat | Fungsi |
|---|---|
| **`"baca sura"`** | Membaca `sura-memory/`, memeriksa profil proyek, menyalakan **Graphify** & **Superpowers Brainstorming**, berdiskusi mematangkan kebutuhan, lalu **otomatis membuat `PRD` & `TRD`** di `sura-memory/TRD/` sebelum mulai ngoding. |
| **`"update sura"`** *(atau `/retro`)* | Menyinkronkan hasil akhir ke `PRD` & `TRD`, menandai task `Done` di `TASK_LOG.md`, mengarsipkan task lama ke `TASK_LOG.archive.md`, mencatat post-mortem di `lessons/`, dan menggeser antrean task di `MEMORY.md`. |
| **`/design`** | Menyusun dokumen teknis 10-section mengacu pada `sura-memory/DESIGN_BEFORE_CODE.md` (disimpan ke `sura-memory/designs/`). |
| **`/verify`** | Menjalankan gerbang pemeriksaan Pre-PR (linter, formatting, cek dependency, dan test/build sesuai `TEST_MODE`) dengan vonis tegas: **READY TO PR** atau **NOT READY**. |
| **`/review-pr <nomor>`** | Melakukan review PR mendalam secara *read-only* mengacu pada `PR_REVIEW_PLAYBOOK.md` dan menyimpan laporannya di `sura-memory/reviews/`. |
| **`/clean`** | Membersihkan log/artifact sementara dan memastikan proteksi `.ignore` & `.git/info/exclude` aktif. |

---

## 📁 Struktur Repositori `Sura-agentic`

```text
Sura-agentic/
├── install.sh                              # Installer 1-klik (interaktif & mendukung flag CLI)
├── README.md                               # Dokumentasi resmi
├── rules/                                  # UNIVERSAL RULES — di-compile ke CLAUDE.md, GEMINI.md, .agents/, .cursor/
│   ├── SOUL.md                             # Identitas Navigator Senior, 5 prinsip, kata kunci & jurus
│   ├── RULES.md                            # Wajib/Dilarang, format langkah, & format penjelasan perintah 5-baris
│   ├── prd-trd-protocol.md                 # Protokol pembuatan otomatis PRD, TRD, & Design Before Code
│   ├── project-structure.md                # Adaptasi Scope (Fullstack/BE/FE/ApiDef) & Mode Test (TDD/Flexible/No-Test)
│   ├── token-protocol.md                   # Aturan hemat token & manajemen arsip memori
│   ├── graphify.md                         # Protokol eksplorasi arsitektur & blast radius via Graphify
│   └── superpowers.md                      # Orkestrasi Superpowers terintegrasi dengan sura-memory/
├── templates/                              # PER-PROYEK — disalin ke sura-memory/
│   ├── README.template.md                  # Peta isi sura-memory & daftar sibling repository
│   ├── MEMORY.template.md                  # Profil proyek, task aktif, batasan (constraints), glossary
│   ├── CONVENTIONS.template.md             # Konfigurasi PROJECT_SCOPE & TEST_MODE, arsitektur, & konvensi Git/PR
│   ├── COMMANDS.template.md                # Cheat sheet perintah terminal spesifik proyek
│   ├── SKILL.template.md                   # Panduan jurus operasional (/design, /verify, /retro, /review-pr, /clean)
│   ├── DESIGN_BEFORE_CODE.template.md      # Template wajib 10-section sebelum menulis kode
│   ├── PR_REVIEW_PLAYBOOK.template.md      # Standar checklist review PR & aturan panen revisi
│   ├── TASK_LOG.template.md                # Logbook pengerjaan task aktif
│   └── TRD/
│       ├── PRD.template.md                 # Template Product Requirements Document (Executive Summary, Metrics, User Stories)
│       └── TRD.template.md                 # Template Technical Requirements Document (Components, Sequence Diagram, API, Blast Radius, Tasks)
├── ignore/
│   └── .ignore-template                    # Filter universal pemblokir sampah token
└── tests/
    └── test-install.sh                     # Automated test suite untuk memverifikasi installer
```

---

## 🧪 Menjalankan Pengujian Installer

```bash
bash tests/test-install.sh
```

---

## 📄 Lisensi
Distributed under the **MIT License**. Bebas digunakan untuk proyek pribadi, freelance, maupun perusahaan komersial.

Crafted with ❤️ by **Sultan Fadhil**.
