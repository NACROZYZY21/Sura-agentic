# Project Conventions & AI SOP

> Panduan baku arsitektur, standar coding, dan aturan operasional asisten AI.

Terakhir diperbarui: **{{DATE}}**

---

## 🤖 Aturan Wajib Asisten AI (SOP Pair-Programming, Superpowers, & Graphify)

Setiap asisten AI yang membaca repositori ini WAJIB mematuhi aturan mutlak berikut:
1. **Diskusi Dulu Sebelum Koding:** Sebelum menyentuh kode atau file proyek, asisten wajib mendiskusikan kebutuhan task terlebih dahulu bersama developer sampai matang (meliputi alur fitur, kebutuhan data/komponen, dan daftar file relevan).
2. **Dilarang Langsung Eksekusi (Mode Advisor Strict):** Asisten dilarang keras langsung mengedit file, membuat kode baru, atau menjalankan perintah eksekusi tanpa persetujuan eksplisit dari developer—selalu sajikan arahan tertulis bertahap (Tujuan, Lokasi, Arahan, Verifikasi) dan tunggu konfirmasi ("lanjut"/"eksekusi") di setiap langkah.
3. **Superpowers & Graphify:** Selalu aktifkan dan manfaatkan skill **superpowers** (seperti brainstorming, writing-plans, dan verification) dan prioritaskan tool **Graphify** (`graphify-out/`) untuk analisis relasi arsitektur kode guna menjaga alur kerja yang terstruktur, hemat token, dan tepat sasaran sejak langkah pertama.

---

## ⚡ Aturan Hemat Token (Token Optimization Protocol)

1. **Targeted Reading Only:** Dilarang membaca file utuh jika > 100 baris. Wajib gunakan `view_file` dengan batas `StartLine`-`EndLine` spesifik atau pencarian `grep_search`.
2. **Prioritaskan Graphify:** Dilarang membaca banyak file sekaligus untuk menelusuri alur kode. Gunakan tool MCP Graphify (`query_graph`) untuk mengambil subgraph yang ringkas.
3. **Abaikan File Log & Sampah:** Dilarang membaca file `*.log`, file cache compiler, atau file audit.
4. **Universal Ignore Active:** Filter `.ignore`, `.cursorignore`, dan `.geminiignore` wajib aktif dan diamankan di `.git/info/exclude`.
5. **Jawaban Padat & Tepat Sasaran:** Berikan respon to-the-point tanpa mengulang boilerplate kode yang tidak berubah.

---

## 🏛️ Arsitektur & Standar Koding Proyek

### A. Struktur Folder
```text
{{FOLDER_STRUCTURE_OVERVIEW}}
```

### B. Standar Testing & Kualitas
- {{TESTING_FRAMEWORK_AND_COMMANDS}}
- Batas kompleksitas kode (Cognitive Complexity).
- Formatters & Linters.

### C. Konvensi Git & Pull Request
- Format commit: `feat(...)`, `fix(...)`, `refactor(...)`.
- Hapus semua AI commit co-authored trailers (misal: `Co-authored-by: Cursor`).
- Rebase onto main/master sebelum PR.
- Squash menjadi 1 commit rapi per PR.

### D. Standar Wajib Label Pull Request
- `enhancement`: fitur baru atau perbaikan peningkatan (improvement)
- `bug`: perbaikan bug yang terjadi di Production
- `defect`: perbaikan bug yang terjadi di Staging (belum ke Production)
- `dependencies`: pembaruan dependensi / library / package
- `documentation`: pull request khusus dokumentasi

> 💡 Gunakan: \`gh pr create --label "enhancement" ...\`
