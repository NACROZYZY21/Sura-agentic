
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
| 🧠 **Production-Grade Memory** | Ekosistem `sura-memory/` lengkap (`MEMORY`, `CONVENTIONS`, `COMMANDS`, `SKILL`, `DESIGN_BEFORE_CODE`, `PR_REVIEW_PLAYBOOK`, `TASK_LOG`, `TRD/`, `designs/`, `reviews/`, `lessons/`) | AI langsung paham konteks proyek & rantai kerja lintas repo tanpa perlu dijelaskan dari nol. |
| 📋 **Auto PRD & TRD Engine** | Otomatis menghasilkan dokumen `PRD` & `TRD` standar industri dari hasil diskusi sebelum ngoding dimulai, lalu disinkronkan saat `update sura` | Setiap fitur memiliki spesifikasi bisnis (User Story, Metrics) dan teknis (Sequence Diagram, API, Blast Radius, Story Points) yang rapi. |
| 🎯 **Adaptive Project Profile** | Mendukung pilihan Scope (`fullstack`, `backend`, `frontend`, `apidef`, `cli-lib`) & Mode Test (`strict-tdd`, `flexible`, `no-test`) | Aturan AI, template TRD, dan gerbang verifikasi otomatis menyesuaikan jenis proyek (pakai file test maupun tanpa test). |
| 🗺️ **Graphify Engine** | Integrasi AST knowledge graph (`graphify-out/`) untuk analisis *Blast Radius* | AI memetakan relasi komponen dan file yang wajib/dilarang disentuh tanpa membaca puluhan file mentah. |
| ⚡ **Superpowers Workflow** | Orkestrasi *brainstorming*, *TDD*, *systematic-debugging*, & *verification-before-completion* | Mencegah halusinasi dan memastikan setiap klaim selesai dibuktikan dengan output terminal nyata. |
| 🛡️ **Zero Token Waste & Git Safe** | Core rules ramping (~5.2 KB di `CLAUDE.md`) + protokol detail dimuat sebagai skill hanya saat dipakai + filter `.ignore` universal + proteksi `.git/info/exclude` | Biaya awal sesi kecil, AI tidak membaca sampah token, dan **100% aman dari kebocoran ke PR/commit tim**. |

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

**Superpowers & Graphify otomatis dicek.** Keduanya terpasang per user (sekali per laptop), jadi installer hanya menawarkan yang belum ada:

| Kondisi | Mode interaktif | `--non-interactive` | `--with-deps` | `--no-deps` |
|---|---|---|---|---|
| Sudah terpasang | `✅ sudah terpasang` | sama | sama | tidak dicek |
| Ada yang belum | tampilkan perintah, tanya `Pasang sekarang? [Y/n]` | hanya cetak rekomendasi | pasang tanpa bertanya | tidak dicek |

Perintah yang dipakai: `claude plugin install superpowers@superpowers-marketplace` dan `uv tool install graphifyy` (paket resmi, dua huruf y) + `graphify install --platform claude`. Gagal install tidak menghentikan installer.

**Selesai!** Script akan otomatis:
* ✅ Menyiapkan folder `sura-memory/` beserta seluruh template dokumen & subfolder (`TRD/`, `designs/`, `reviews/`, `lessons/`).
* ✅ Memasang filter penghemat token (`.ignore`, `.cursorignore`, `.geminiignore`) tanpa menimpa kustomisasi yang sudah ada.
* ✅ Meng-compile rule AI sesuai profil proyek untuk **Antigravity** (`.agents/rules/`), **Gemini CLI** (`GEMINI.md`), **Claude Code** (`CLAUDE.md` / `CLAUDE.local.md` + `.claude/skills/sura-*`), dan **Cursor** (`.cursor/rules/`).
* ✅ Membuat folder arsip `sura-memory/TRD/archive/` — PRD/TRD fitur yang selesai diarsipkan, tidak pernah dihapus.
* ✅ Mengamankan seluruh konfigurasi ke `.git/info/exclude` (**0% risiko bocor ke Git tim**).

### Perawatan: Upgrade & Uninstall
```bash
# Perbarui rules, skill, dan hook memakai profil proyek yang tersimpan.
# Perubahan template sura-memory/ TIDAK ditimpa — disimpan sebagai diff di sura-memory/.upgrade/
bash ~/Sura-agentic/install.sh --upgrade

# Cabut semua file buatan Sura (file tim, sura-memory/, dan ~/.sura tidak disentuh)
bash ~/Sura-agentic/install.sh --uninstall
bash ~/Sura-agentic/install.sh --uninstall --purge   # ikut hapus sura-memory/
```

### Profil Developer Global (`~/.sura/`)
- `~/.sura/profile.md` — tentang **kamu** (nama, gaya belajar, Mode Belajar aktif/nonaktif, preferensi). Dibuat sekali, dipakai semua proyek.
- `~/.sura/lessons.md` — **pelajaran umum lintas proyek**. Saat `update sura`, AI bertanya apakah sebuah pelajaran berlaku umum; bila ya, ditulis ulang tanpa detail rahasia perusahaan dan ditambahkan **hanya setelah persetujuanmu**.
- `sura-memory/` di tiap proyek kini hanya berisi konteks proyek itu.

### Hook Claude Code (Aturan yang Dipaksa, Bukan Sekadar Teks)
Terdaftar di `.claude/settings.local.json` (pribadi; bila file itu di-track git oleh tim, hook dilewati):
- **`SessionStart`** — tiap sesi dibuka, profil `~/.sura/`, task aktif, dan batasan proyek disuntikkan otomatis (diam di proyek tanpa `sura-memory/`). `baca sura` tetap dipakai untuk memuat PRD/TRD lengkap.
- **`PreToolUse`** — membaca `node_modules/`, `vendor/`, cache compiler, `*.log`, dan `*-audit.json` diblokir oleh harness, bukan sekadar diminta lewat aturan.

### Claude Code vs Tool Lain
- **Claude Code:** `CLAUDE.md` hanya berisi core (SOUL + RULES) dan override Superpowers. Protokol detail (`skills/sura-prd-trd`, `skills/sura-project-profile`, `skills/sura-graphify`) dipasang ke `.claude/skills/` dan baru dimuat saat relevan — mekanisme yang sama yang membuat Superpowers murah.
- **Gemini CLI, Cursor, Antigravity:** belum ada mekanisme skill yang sama, jadi isi skill di-inline ke payload rule beserta checklist alur kerja ringkas (tanpa menyebut skill Superpowers yang tidak tersedia di sana).

### Ukuran Payload (Hasil Ukur)
Diukur oleh `bash tests/measure.sh` dengan memasang versi sebelum refactor (`0a94e8a`) dan versi sekarang ke folder kosong. Token ≈ byte / 4 (perkiraan kasar). File `sura-memory/` masih berupa template kosong — di proyek yang sudah terisi angkanya lebih besar.

<!-- MEASURE:START -->
| Dibaca AI di awal sesi | Sebelum refactor | Sekarang |
|---|---|---|
| `CLAUDE.md` (selalu dimuat) | 21.3 KB | 5.2 KB |
| Hook `SessionStart` (otomatis) | — | 2.2 KB |
| File wajib saat `baca sura` | 5 file, 13.0 KB | 5 file (2 global + 3 proyek), 7.2 KB |
| **Total awal sesi (Claude Code)** | **34.3 KB ≈ 8567 token** | **14.6 KB ≈ 3652 token** |
| `GEMINI.md` / Cursor / Antigravity (selalu dimuat) | 21.3 KB | 13.9 KB |
<!-- MEASURE:END -->

Tabel ini dicek otomatis (`bash tests/measure.sh --check`): kalau payload berubah tapi tabel tidak diperbarui, pengecekan gagal.

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
├── rules/
│   ├── core/                               # SELALU DIMUAT semua tool
│   │   ├── SOUL.md                         # Identitas Navigator Senior, 5 prinsip, kata kunci
│   │   └── RULES.md                        # Wajib/Dilarang, format langkah, format penjelasan perintah 5-baris
│   ├── claude/
│   │   └── superpowers-overrides.md        # Hanya Claude Code: lokasi dokumen, gerbang TEST_MODE, advisor-strict
│   └── inline/
│       └── workflow-checklist.md           # Hanya Gemini/Cursor/Antigravity: checklist alur kerja ringkas
├── hooks/                                  # Hook Claude Code → .claude/hooks/ (+ merge-settings.py untuk settings.local.json)
├── skills/                                 # ON-DEMAND — ke .claude/skills/ (Claude), di-inline untuk tool lain
│   ├── sura-prd-trd/SKILL.md               # baca/update sura, mode Existing/Greenfield, arsip, struktur PRD & TRD
│   ├── sura-project-profile/SKILL.md       # Adaptasi PROJECT_SCOPE, TEST_MODE, multi-repo, peta sura-memory/
│   └── sura-graphify/SKILL.md              # Eksplorasi arsitektur & blast radius via Graphify (bila graphify-out/ ada)
├── templates/                              # PER-PROYEK — disalin ke sura-memory/
│   ├── README.template.md                  # Peta isi sura-memory & daftar sibling repository
│   ├── MEMORY.template.md                  # Profil proyek, task aktif, batasan (constraints), glossary
│   ├── CONVENTIONS.template.md             # Konfigurasi PROJECT_SCOPE & TEST_MODE, arsitektur, & konvensi Git/PR
│   ├── COMMANDS.template.md                # Cheat sheet perintah terminal spesifik proyek
│   ├── SKILL.template.md                   # Panduan jurus operasional (/design, /verify, /retro, /review-pr, /clean)
│   ├── DESIGN_BEFORE_CODE.template.md      # Template wajib 10-section sebelum menulis kode
│   ├── PR_REVIEW_PLAYBOOK.template.md      # Standar checklist review PR & aturan panen revisi
│   ├── TASK_LOG.template.md                # Logbook pengerjaan task aktif
│   ├── profile.template.md                 # → ~/.sura/profile.md (profil developer global)
│   ├── lessons.template.md                 # → ~/.sura/lessons.md (pelajaran umum lintas proyek)
│   └── TRD/
│       ├── PRD.template.md                 # Template Product Requirements Document (Executive Summary, Metrics, User Stories)
│       └── TRD.template.md                 # Template Technical Requirements Document (Components, Sequence Diagram, API, Blast Radius, Tasks)
├── ignore/
│   └── .ignore-template                    # Filter universal pemblokir sampah token
└── tests/
    ├── measure.sh                          # Ukur payload & bacaan awal sesi; --check menjaga angka di README
    ├── pre-push                            # Git hook: semua test wajib lulus sebelum push
    ├── test-hooks.sh                       # Unit test hook SessionStart & PreToolUse
    ├── test-content.sh                     # Lint isi rules, skills, templates, README
    └── test-install.sh                     # Automated test suite untuk memverifikasi installer
```

---

## 🧪 Menjalankan Pengujian Installer

```bash
bash tests/test-content.sh && bash tests/test-hooks.sh && bash tests/test-install.sh && bash tests/measure.sh --check

# Jalankan otomatis di setiap git push:
ln -sf ../../tests/pre-push .git/hooks/pre-push
```

---

## 📄 Lisensi
Distributed under the **MIT License**. Bebas digunakan untuk proyek pribadi, freelance, maupun perusahaan komersial.

Crafted with ❤️ by **Sultan Fadhil**.
