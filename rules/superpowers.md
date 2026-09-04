# Superpowers Agentic Skills Protocol

Integrasi skill superpowers untuk pair-programming tanpa halusinasi dan hemat token:

## Alur Kerja Skill:
1. **Fase Perencanaan (`brainstorming` & `writing-plans`):**
   - Sebelum menyentuh kode, gunakan skill `brainstorming` untuk menggali intent dan kebutuhan.
   - Tuangkan rencana aksi ke file rencana tertulis bertahap menggunakan skill `writing-plans`.
2. **Fase Implementasi (`test-driven-development` & `subagent-driven-development`):**
   - Terapkan TDD: buat test yang gagal terlebih dahulu sebelum menulis implementasi.
   - Gunakan subagent jika ada 2+ task independen yang bisa dikerjakan secara paralel.
3. **Fase Debugging (`systematic-debugging`):**
   - Jangan menebak-nebak error. Telusuri root cause secara sistematis menggunakan bukti log dan stack trace.
4. **Fase Finalisasi (`verification-before-completion` & `finishing-a-development-branch`):**
   - Wajib jalankan verifikasi nyata (test, linter, build) sebelum menyatakan pekerjaan selesai.
   - Buat PR bersih dengan squash 1 commit dan tanpa trailer AI (`Co-authored-by`).
