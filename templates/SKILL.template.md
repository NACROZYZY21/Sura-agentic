# Sura Developer Skills (All-in-One Protocol)

Kumpulan jurus operasional terarah untuk mendampingi developer dalam siklus pengembangan software.
Terintegrasi penuh dengan **Graphify** (peta arsitektur) dan **Superpowers** (disiplin eksekusi).

---

## 1. Kata Kunci Utama Siklus Kerja

### 🟢 `"baca sura"` (Pembuka Sesi & Diskusi Kebutuhan)
**Kapan dipakai:** Di awal sesi chat baru atau sebelum memulai proyek/fitur baru.
**Prosedur yang dijalankan AI:**
1. Membaca `MEMORY.md`, `CONVENTIONS.md` (`PROJECT_SCOPE` & `TEST_MODE`), `TASK_LOG.md`, serta `TRD/PRD.md` dan `TRD/TRD.md` yang sedang aktif.
2. **Deteksi Kondisi Repo (2 Mode):**
   - **Repo Sudah Ada Kode (*Existing*):** Jalankan eksplorasi arsitektur **Graphify** (`query_graph` / `get_neighbors`) untuk mempelajari komponen, endpoint, dan skema yang sudah ada.
   - **Repo Belum Ada Kode (*Greenfield*):** Bantu rancang struktur folder dan arsitektur dari nol sesuai `PROJECT_SCOPE`.
3. Mengaktifkan `superpowers:brainstorming`: berdiskusi dengan developer untuk mematangkan kebutuhan bisnis & teknis.
4. **Auto-Generate / Replace PRD & TRD:** Setelah diskusi disetujui, AI otomatis menulis ke `sura-memory/TRD/PRD.md` dan `sura-memory/TRD/TRD.md` sebelum menulis kode. (Jika sebelumnya berisi Proyek A yang sudah selesai, otomatis dihapus dan diganti dengan Proyek B).

### 🔴 `"update sura"` / `/retro` (Penutup Task & Rotasi Proyek)
**Kapan dipakai:** Saat proyek/fitur selesai dikembangkan, lulus verifikasi, atau PR sudah di-merge, serta saat mau berpindah ke proyek/fitur berikutnya.
**Prosedur yang dijalankan AI:**
1. **Update Task Log & Memory:** Ubah status task di `TASK_LOG.md` menjadi **`Done`**, cantumkan nomor PR + *lessons learned*, arsipkan entri lama jika > 3 task ke `TASK_LOG.archive.md`, dan pindahkan task di `MEMORY.md` ke *Riwayat Proyek/Task Selesai*.
2. **Rotasi PRD & TRD (Proyek A → Proyek B):**
   - Jika proyek/fitur A sudah dinyatakan selesai dan developer mulai mendiskusikan proyek/fitur B, **hapus isi `sura-memory/TRD/PRD.md` dan `sura-memory/TRD/TRD.md` milik Proyek A**, lalu ganti sepenuhnya dengan PRD & TRD Proyek B.

---

## 2. Jurus `/design` (Bedah Arsitektur 10-Section Sebelum Koding)
**Kapan dipakai:** Di awal pengerjaan endpoint/komponen spesifik — **wajib sebelum menulis kode**. Tunggu izin `"lanjut"` / `"eksekusi"`.
**Template wajib:** [DESIGN_BEFORE_CODE.md](DESIGN_BEFORE_CODE.md) (10 section adaptif sesuai `PROJECT_SCOPE`: `{{PROJECT_SCOPE}}`).

---

## 3. Jurus `/verify` (Verifikasi Pre-PR Gate)
**Kapan dipakai:** Sebelum membuka PR atau memastikan branch siap merge.
**Prosedur yang dijalankan AI (menyesuaikan `TEST_MODE`: `{{TEST_MODE}}`):**
1. **Formatting & Linter:** Pastikan 0 diff/error (`gofmt`, `eslint`, `prettier`, dll.).
2. **Dependencies Check:** Pastikan tidak ada perubahan dependency liar atau `replace` lokal sementara yang tertinggal.
3. **Testing / Build Gate:**
   - Jika `TEST_MODE` = `strict-tdd` / `flexible`: Jalankan unit/integration test pada modul terdampak. Wajib **PASS** (coverage kode baru ≥ 60%, Cognitive Complexity ≤ 15).
   - Jika `TEST_MODE` = `no-test`: Jalankan full build/compile check (`exit 0`) dan tampilkan checklist verifikasi manual yang sudah tervalidasi.
4. **PR Labels & Clean Commit:** Pastikan commit bersih tanpa `Co-authored-by` AI dan siap diberi label (`enhancement`, `bug`, `defect`, `dependencies`, atau `documentation`).
5. **Vonis Akhir:** Berikan status tegas: **READY TO PR** atau **NOT READY** (sertakan daftar perbaikannya).

---

## 4. Jurus `/review-pr <nomor>` (Review PR — Mode Belajar & Kualitas Tim)
**Kapan dipakai:** Saat me-review PR rekan tim atau memeriksa PR sendiri sebelum di-review senior.
**Basis wajib:** [PR_REVIEW_PLAYBOOK.md](PR_REVIEW_PLAYBOOK.md).
**Prosedur yang dijalankan AI:**
1. Jalankan `gh pr view <nomor>` + `gh pr diff <nomor>` (hanya baca; tidak checkout dan tidak post komentar tanpa izin).
2. Klasifikasi file per layer → jalankan cek mesin & checklist layer yang relevan.
3. Setiap temuan wajib mencantumkan: `file:baris`, kategori aturan, dan penjelasan **kenapa penting**.
4. Simpan ringkasan review ke `sura-memory/reviews/PR_<nomor>_<slug>.md`.

---

## 5. Jurus `/clean` (Pembersihan Workspace & Pengamanan Token)
**Kapan dipakai:** Saat workspace mulai lambat atau ingin memastikan kerahasiaan memori lokal.
**Prosedur yang dijalankan AI:**
1. Hapus file log sementara (`*.log`), dump, atau artifact yang tidak diperlukan.
2. Pastikan `.ignore`, `.cursorignore`, dan `.geminiignore` aktif.
3. Pastikan seluruh `sura-memory/` dan file rules lokal terdaftar di `.git/info/exclude`.

---

## 6. Aturan Penjelasan Perintah Terminal (Wajib — Mode Belajar)
Setiap kali AI memberikan perintah terminal kepada developer, **wajib** gunakan format 5 baris ini:

```markdown
**Perintah:** `<perintah terminal>`
**Fungsi:** Apa yang dilakukan (1 kalimat bahasa sederhana)
**Kapan dipakai:** Situasi spesifik kapan harus dijalankan
**Alur terkait:** Posisi perintah di rantai kerja (contoh: ApiDef → ApiGo → Backend → Test → PR)
**Verifikasi:** Perintah atau output yang membuktikan eksekusi berhasil
```
