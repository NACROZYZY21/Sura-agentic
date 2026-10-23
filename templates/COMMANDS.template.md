# Project Commands Cheat Sheet

> Referensi cepat perintah terminal untuk repositori ini (`PROJECT_SCOPE`: `{{PROJECT_SCOPE}}`, `TEST_MODE`: `{{TEST_MODE}}`).
> Setiap kali AI menyarankan perintah dari file ini, AI **wajib** menjelaskannya dengan format 5-baris di `SKILL.md` §5.

Terakhir diperbarui: **{{DATE}}**

---

## 1. Setup & Sinkronisasi Dependency

```markdown
**Perintah:** `{{INSTALL_COMMAND}}`
**Fungsi:** Menginstal atau menyinkronkan seluruh dependensi proyek.
**Kapan dipakai:** Saat baru clone repo, pindah branch dengan perubahan package, atau setelah update versi kontrak API.
**Alur terkait:** Clone / Pull → **Install Dependency** → Mulai Koding / Build.
**Verifikasi:** Perintah selesai dengan `exit code 0` tanpa error dependency conflict.
```

---

## 2. Code Generation / Mock / OpenAPI Sync (Jika Ada)

```markdown
**Perintah:** `{{GENERATE_COMMAND}}`
**Fungsi:** Men-generate kode otomatis (seperti mock interface, client API dari OpenAPI/Swagger, atau bundle schema).
**Kapan dipakai:** Setelah mengubah file kontrak YAML atau menambahkan method baru pada interface repository/service.
**Alur terkait:** Ubah Kontrak/Interface → **Generate Code/Mock** → Implementasi Logic → Jalankan Test.
**Verifikasi:** `git status` menampilkan file `*.gen.*` atau `*.mock.*` terbarui tanpa error kompilasi.
```

---

## 3. Verifikasi Kualitas (Test, Linter, & Build)

### A. Menjalankan Unit / Integration Test (Aktif saat `TEST_MODE` = `strict-tdd` / `flexible`)
```markdown
**Perintah:** `{{TEST_COMMAND}}`
**Fungsi:** Menjalankan pengujian otomatis pada package/komponen yang sedang dikerjakan.
**Kapan dipakai:** Setiap selesai menulis skenario test (TDD Red-Green) dan wajib sebelum melakukan commit/PR.
**Alur terkait:** Tulis Kode & Test → **Jalankan Test** → Linter → Buka PR.
**Verifikasi:** Seluruh test berstatus `PASS` dengan 0 failure.
```

### B. Menjalankan Formatter & Linter (Wajib di Semua `TEST_MODE`)
```markdown
**Perintah:** `{{LINT_COMMAND}}`
**Fungsi:** Memeriksa kerapian format kode dan potensi masalah statis (unused variable, cognitive complexity, tipe data).
**Kapan dipakai:** Sebelum melakukan `git commit` atau saat menjalankan jurus `/verify`.
**Alur terkait:** Implementasi Selesai → **Lint & Format** → Commit → PR.
**Verifikasi:** Output bersih (0 error).
```

### C. Menjalankan Build / Validasi Kompiler (Utama saat `TEST_MODE` = `no-test`)
```markdown
**Perintah:** `{{BUILD_COMMAND}}`
**Fungsi:** Memastikan seluruh aplikasi atau skema berhasil dikompilasi/dibundle tanpa error tipe atau sintaks.
**Kapan dipakai:** Sebelum menyatakan task selesai, terutama bila proyek berada dalam mode `no-test`.
**Alur terkait:** Implementasi → **Build Check** → Verifikasi Manual → PR.
**Verifikasi:** Build selesai sukses (`exit code 0`).
```

---

## 4. Git & Pull Request (`gh` CLI)

```markdown
**Perintah:** `gh pr create --title "feat(scope): deskripsi singkat" --label "enhancement" --body "..."`
**Fungsi:** Membuat Pull Request baru di GitHub langsung dari terminal beserta label wajibnya.
**Kapan dipakai:** Setelah seluruh gerbang `/verify` berstatus **READY TO PR** dan branch sudah di-push ke origin.
**Alur terkait:** `/verify` LULUS → Push Branch → **Buka PR** → Jalankan `"update sura"`.
**Verifikasi:** URL Pull Request tampil di terminal.
```
