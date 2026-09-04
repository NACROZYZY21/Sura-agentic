# ⚡ Sura-agentic

> **Portable AI Pair-Programming Framework for Modern Software Engineers**  
> *Structured Context • Zero Token Waste • Graphify Knowledge Graph • Superpowers Integration • Strict Advisor Mode*

---

## 🌟 Mengapa Toolkit Ini Dibuat?

Bekerja bersama AI coding assistant (Cursor, Claude Code, Gemini CLI, Windsurf) sering kali menghadapi 3 masalah besar:
1. **AI Cepat Amnesia:** Setiap sesi baru, AI lupa konteks arsitektur, histori tiket, dan standar tim.
2. **Token Boncos (Cache Read Bengkak):** AI membaca seluruh folder `node_modules`, cache compiler, dan log raksasa.
3. **AI Halusinasi & Asal Eksekusi:** AI langsung mengedit kode tanpa konfirmasi dan tanpa memahami kebutuhan fitur.

**Agentic Dev Kit** adalah framework portabel 1-klik yang mengubah AI coding assistant menjadi **senior co-pilot yang disiplin, hemat token, dan patuh pada SOP**.

---

## 🏛️ 5 Pilar Utama

| Pilar | Deskripsi | Manfaat |
|---|---|---|
| 🧠 **Structured Memory** | 3-tier memory system (`MEMORY.md`, `TASK_LOG.md`, `CONVENTIONS.md`) | AI langsung paham konteks kerjaan tanpa perlu dijelaskan dari nol. |
| 🛡️ **Zero Token Waste** | Universal filter (`.ignore`, `.cursorignore`, `.geminiignore`) | Memotong 70–80% konsumsi token cache read yang tidak perlu. |
| 🗺️ **Graphify Engine** | Integrasi AST knowledge graph (`graphify-out/`) | AI melihat peta arsitektur dependensi tanpa harus membaca puluhan file. |
| ⚡ **Superpowers Integration** | Workflow TDD, brainstorming, dan verifikasi terarah | Mencegah bug dan memastikan kode diverifikasi sebelum commit/PR. |
| 🛑 **Strict Advisor Mode** | Discussion-first & no direct unapproved execution | Developer memegang kendali penuh. AI tidak boleh mengedit tanpa izin. |

---

## 🚀 Cara Pasang di Proyek Apapun (1-Klik Saja)

### 1. Clone Toolkit Ini ke Laptop Lo
```bash
git clone https://github.com/NACROZYZY21/Sura-agentic.git ~/Sura-agentic
```

### 2. Pasang ke Proyek Apapun yang Sedang Dikerjakan
Masuk ke folder proyek baru lo (misal kantor baru, proyek freelance, atau skripsi), lalu jalankan:

```bash
bash ~/Sura-agentic/install.sh
```

**Selesai!** Script akan otomatis:
* ✅ Menyiapkan folder `dev-memory/` beserta 3 template dokumennya.
* ✅ Memasang filter ignore token universal (`.ignore`, `.cursorignore`, `.geminiignore`).
* ✅ Mengonfigurasi rule AI otomatis untuk Cursor dan Gemini/Antigravity.
* ✅ Mengamankan seluruh konfigurasi ke `.git/info/exclude` (**100% aman dari PR / commit tim**).

---

## 💬 Cara Pakai Sehari-hari

Cukup ingat **2 kata kunci**:

### 🟢 1. Di Awal Sesi Chat
Ketik ke AI:
> **`"Baca dev-memory ya"`**

*AI akan langsung membaca memori, menyalakan Superpowers & Graphify, dan mengajak diskusi kebutuhan sebelum menulis kode.*

### 🔴 2. Saat Task Selesai & PR Di-merge
Ketik ke AI:
> **`"Update dev-memory ya"`**

*AI akan menandai status task menjadi `Done`, mencatat link PR, dan menyiapkan task berikutnya di daftar antrean.*

---

## 📁 Struktur Repositori

```text
agentic-dev-kit/
├── install.sh                  # Installer 1-klik untuk proyek apapun
├── README.md                   # Dokumentasi resmi
├── templates/
│   ├── MEMORY.template.md      # Template whiteboard harian & kamus domain
│   ├── TASK_LOG.template.md    # Template logbook pengerjaan task detail
│   └── CONVENTIONS.template.md # Template aturan koding & SOP hemat token
├── rules/
│   ├── ai-sop.md               # Prompt SOP pair-programming universal
│   ├── graphify.md             # Panduan protokol knowledge graph
│   └── superpowers.md          # Panduan integrasi superpowers
└── ignore/
    └── .ignore-template        # Filter universal pemblokir sampah token
```

---

## 📄 Lisensi
Distributed under the **MIT License**. Bebas digunakan untuk proyek pribadi, freelance, maupun perusahaan komersial.

Crafted with ❤️ by **Sultan Fadhil**.
