# PR Review Playbook & Quality Gate

> Panduan standar saat menjalankan jurus **`/review-pr <nomor>`** atau memeriksa kesiapan PR sendiri.
> Semua catatan hasil review disimpan di `sura-memory/reviews/PR_<nomor>_<slug>.md` (tidak dibaca otomatis kecuali diminta).

Terakhir diperbarui: **{{DATE}}**

---

## 1. Prosedur Review (Read-Only)
1. Ambil metadata dan diff PR menggunakan `gh pr view <nomor>` dan `gh pr diff <nomor>`.
2. **Jangan** melakukan `git checkout` yang merusak working tree aktif dan **jangan** mem-posting komentar ke GitHub tanpa perintah eksplisit dari developer.
3. Klasifikasikan file yang berubah berdasarkan layer arsitektur.

---

## 2. Cek Mesin & Kepatuhan Dasar (§2)
- [ ] **Blast Radius Bersih:** Tidak ada perubahan pada file yang tidak relevan dengan tiket/TRD.
- [ ] **Dependency Aman:** Tidak ada `replace` lokal sementara di `go.mod` / `package.json` yang ikut ter-commit.
- [ ] **Bebas Jejak AI:** Tidak ada trailer `Co-authored-by` AI di commit maupun deskripsi PR.
- [ ] **Label PR Tepat:** Memiliki salah satu label standar (`enhancement`, `bug`, `defect`, `dependencies`, `documentation`).

---

## 3. Checklist per Layer (§3)

### A. Backend (Handler → Service → Repository)
- [ ] **Handler:** Hanya mengurus transport & validasi request/pagination; tidak mengandung query DB atau logika bisnis berlapis.
- [ ] **Service:** Menangani logika domain, transaksi, dan propagasi error dengan konteks yang jelas; tidak mengabaikan error (`_ = ...`).
- [ ] **Repository:** Menggunakan parameter binding yang aman (bebas SQL injection), konstanta nama tabel, dan pagination standar.

### B. Frontend (API Client → Hook/State → Component)
- [ ] **API Layer:** Menggunakan base client dan tipe yang ter-generate/terstandar, bukan URL hardcoded.
- [ ] **State & Hook:** Menangani state *loading*, *empty*, dan *error* dengan rapi; tidak ada infinite loop pada `useEffect`.
- [ ] **Component:** Menggunakan komponen/token desain yang sudah ada (*reuse over recreate*).

### C. Testing & Verifikasi (Sesuai `TEST_MODE`: `{{TEST_MODE}}`)
- [ ] Jika `strict-tdd` / `flexible`: Skenario positif, negatif, dan batas (*edge case*) teruji tanpa mock yang terlalu longgar.
- [ ] Jika `no-test`: Build dan linter lulus 100% tanpa error tipe atau *unused code*.

---

## 4. Format Laporan Review (`sura-memory/reviews/PR_<nomor>_<slug>.md`)

```markdown
# Review PR #<nomor> — <Judul PR>

- **Author:** @username
- **Tanggal Review:** YYYY-MM-DD
- **Vonis:** APPROVE / REQUEST CHANGES / COMMENT

## 🔍 Temuan
1. **[SEVERITY: HIGH/MED/LOW]** `path/ke/file.ext:baris`
   - **Masalah:** ...
   - **Sumber Aturan / Kenapa Penting:** ...
   - **Saran Perbaikan:** ...

## 💡 Pola / Pembelajaran untuk Proyek Ini
- ...
```

---

## 5. Aturan Panen Revisi (Harvesting Rule)
Jika sebuah pola kesalahan muncul **2 kali atau lebih** pada review PR, promosikan pola tersebut ke bagian **Batasan Proyek (Constraints)** di `sura-memory/MEMORY.md` atau ke dalam `sura-memory/lessons/` agar AI selalu mencegahnya sejak fase `/design`.
