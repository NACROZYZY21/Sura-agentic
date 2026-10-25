# Aturan Operasional

## Wajib Selalu
- Saat `baca sura`: baca `sura-memory/MEMORY.md`, `CONVENTIONS.md`, `TASK_LOG.md`. Baca `TRD/PRD.md` + `TRD/TRD.md` hanya bila ada task aktif atau pertanyaan menyangkut fitur aktif.
- Patuhi **Profil Proyek** (`PROJECT_SCOPE` & `TEST_MODE`) di `CONVENTIONS.md` dan **Batasan Proyek** di `MEMORY.md`.
- Baca terarah (rentang baris / grep) secara default; baca utuh boleh saat me-review atau me-refactor file itu sendiri.
- Tunggu konfirmasi eksplisit ("lanjut" / "eksekusi") sebelum mengedit kode, membuat file aplikasi, atau menjalankan perintah mutasi.
- Jalankan verifikasi nyata (test / linter / build sesuai `TEST_MODE`) dan tempel output terbarunya sebelum menyatakan selesai.

## Dilarang Keras
- Mengedit kode, membuat file di luar `sura-memory/` saat fase desain, atau menjalankan perintah destruktif tanpa persetujuan.
- Membaca `*.log`, `logs-server/`, `*-audit.json`, cache compiler (`.go-cache/`, `.gocache/`, `.gomodcache/`), `node_modules/`, `vendor/`, atau build artifact (`dist/`, `build/`, `.next/`).
- Membaca otomatis `TASK_LOG.archive.md`, `TRD/archive/`, `reviews/`, `lessons/` — buka hanya saat relevan atau diminta.
- Menambahkan trailer `Co-authored-by` AI pada commit atau PR.
- Menyimpan spek/PRD/TRD/design ke folder tim (mis. `docs/`) — semuanya masuk `sura-memory/`.

## Format Tiap Langkah Koding
- **Tujuan:** apa yang dicapai langkah ini.
- **Lokasi:** path file + nomor baris.
- **Arahan:** potongan kode ringkas yang ditambah/diubah, tanpa boilerplate yang tidak berubah.
- **Verifikasi:** perintah/test yang membuktikan langkah berhasil.

## Format Perintah Terminal (Mode Belajar)
Setiap memberi perintah terminal, jangan lempar command mentah — sertakan:

```markdown
**Perintah:** `<command lengkap>`
**Fungsi:** apa yang dilakukan (1 kalimat sederhana)
**Kapan dipakai:** situasi spesifik penggunaannya
**Alur terkait:** posisinya di rantai kerja (mis. ApiDef → ApiGo → Backend → Test → PR)
**Verifikasi:** indikator output yang membuktikan berhasil
```
