# Aturan Operasional

## Wajib Selalu
- Baca `sura-memory/` (`MEMORY.md`, `CONVENTIONS.md`, `TASK_LOG.md`, dan `TRD/PRD.md` + `TRD/TRD.md`) sebelum menjawab pertanyaan atau mengambil tindakan apapun tentang proyek ini.
- Patuhi **Profil Proyek** (`PROJECT_SCOPE` & `TEST_MODE`) di `sura-memory/CONVENTIONS.md` dan **Batasan Proyek** di `sura-memory/MEMORY.md` tanpa kecuali.
- Kuasai **2 Mode Pembuatan PRD/TRD**:
  - Jika **Repo Sudah Ada Kode (*Existing*)**: pelajari struktur & kode repo (via Graphify/file terkait) lalu isi PRD & TRD berdasarkan komponen nyata yang ada.
  - Jika **Repo Belum Ada Kode (*Greenfield*)**: rancang arsitektur dan struktur folder dari nol sesuai `PROJECT_SCOPE`, lalu tuangkan sebagai cetak biru di PRD & TRD.
- Terapkan **Rotasi Otomatis PRD & TRD**: selama mengerjakan Proyek/Fitur A, ingat dan gunakan `sura-memory/TRD/PRD.md` & `TRD.md` milik Proyek A. Begitu Proyek A selesai dan masuk ke Proyek/Fitur B, **hapus/ganti** `PRD.md` & `TRD.md` lama dengan milik Proyek B.
- Sajikan setiap langkah implementasi dalam format: **Tujuan → Lokasi → Arahan → Verifikasi**.
- Tunggu konfirmasi eksplisit ("lanjut" / "eksekusi") sebelum mengedit file kode, membuat file aplikasi, atau menjalankan perintah mutasi.
- Jalankan verifikasi nyata (unit test / linter / build sesuai `TEST_MODE` proyek) sebelum menyatakan pekerjaan selesai.

## Dilarang Keras
- Mengedit file kode, membuat file di luar `sura-memory/` saat fase desain, atau menjalankan perintah destruktif tanpa persetujuan.
- Membaca file utuh lebih dari 100 baris — wajib gunakan rentang baris (`StartLine`/`EndLine`) atau grep terarah.
- Membaca `*.log`, cache compiler (`.go-cache/`, `.gocache/`), atau `node_modules/` / `vendor/`.
- Menyatakan "sudah selesai" / "sudah aman" tanpa menempelkan bukti output terminal verifikasi terbaru.
- Menambahkan trailer `Co-authored-by` AI pada pesan commit atau PR.
- Menyimpan dokumen desain pribadi ke folder tim (seperti `docs/superpowers/specs/`) — semua spek, PRD, TRD, dan design wajib masuk ke dalam `sura-memory/`.

## Format Panduan Tiap Langkah Koding
- **Tujuan:** Apa yang ingin dicapai pada langkah ini.
- **Lokasi:** Path file dan nomor baris spesifik yang ditargetkan.
- **Arahan:** Potongan kode ringkas yang ditambahkan/diubah, tanpa mengulang boilerplate yang tidak berubah.
- **Verifikasi:** Perintah terminal atau test yang membuktikan langkah ini berhasil.

## Format Penjelasan Perintah Terminal (Wajib — Mode Belajar)
Setiap kali memberikan perintah terminal (`make ...`, `go test ...`, `npx nx ...`, `npm ...`, `git ...`) kepada developer, **wajib** sertakan penjelasan minimal 5 baris berikut (jangan pernah melempar command mentah tanpa konteks):

```markdown
**Perintah:** `<command lengkap>`
**Fungsi:** Apa yang dilakukan perintah ini (1 kalimat bahasa sederhana)
**Kapan dipakai:** Situasi spesifik kapan perintah ini harus dijalankan
**Alur terkait:** Posisi perintah dalam rantai kerja (contoh: ApiDef → ApiGo → Backend → Test → PR)
**Verifikasi:** Perintah atau indikator output yang membuktikan eksekusi berhasil
```
