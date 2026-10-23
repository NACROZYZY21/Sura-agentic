# Superpowers Agentic Skills Protocol

Integrasi terpadu antara **Superpowers**, **Graphify**, dan **Sura-agentic** untuk memastikan pengembangan bebas halusinasi, terukur, dan hemat token:

## 1. Fase Eksplorasi & Perencanaan (`brainstorming` → Auto PRD & TRD)
- Sebelum menyentuh kode proyek/fitur baru, aktifkan pola kerja `superpowers:brainstorming`:
  - Jika **Repo Existing**: padukan dengan analisis arsitektur **Graphify** untuk mempelajari kode yang sudah ada.
  - Jika **Repo Baru/Kosong (Greenfield)**: rancang struktur folder dan arsitektur dari nol bersama developer.
- **Aturan Override Lokasi Spek & Auto-Replace:** Setelah desain disepakati, **jangan** menulis spek ke `docs/superpowers/specs/` (agar tidak mengotori Git tim). Sebagai gantinya, tuangkan hasil diskusi dan rencana kerja (`writing-plans`) langsung ke dalam:
  - `sura-memory/TRD/PRD.md` (Product Requirements aktif)
  - `sura-memory/TRD/TRD.md` (Technical Requirements aktif)
- Jika sebelumnya `PRD.md` dan `TRD.md` berisi Proyek/Fitur A yang sudah selesai (`Done`), **hapus isinya dan ganti dengan Proyek/Fitur B yang baru** agar AI selalu fokus 100% pada proyek aktif.

## 2. Fase Implementasi Adaptif (`test-driven-development` & `subagent-driven-development`)
- Sesuaikan eksekusi dengan `TEST_MODE` proyek di `sura-memory/CONVENTIONS.md`:
  - Jika **`strict-tdd`**: jalankan siklus Red-Green-Refactor (`test-driven-development`) secara disiplin untuk setiap layer yang disentuh.
  - Jika **`flexible`**: terapkan test pada logika bisnis utama/krusial.
  - Jika **`no-test`**: lewati pembuatan file test baru dan fokus pada implementasi bersih sesuai desain layer serta verifikasi build/linter.
- Gunakan `dispatching-parallel-agents` / `subagent-driven-development` apabila terdapat 2+ sub-task independen yang perlu diteliti atau dikerjakan secara paralel tanpa mengotori konteks utama.

## 3. Fase Debugging (`systematic-debugging`)
- Saat menemukan error, test gagal, atau perilaku tak terduga, gunakan `systematic-debugging`: baca bukti log/stack trace secara presisi, lacak alur dengan Graphify, temukan *root cause*, dan dilarang menebak-nebak perbaikan secara acak.
- Jika bug berasal dari jebakan arsitektur penting, catat pembelajarannya di `sura-memory/lessons/` saat sesi ditutup.

## 4. Fase Verifikasi & Finalisasi (`verification-before-completion` → `update sura`)
- Wajib menjalankan `verification-before-completion` (atau jurus `/verify`): eksekusi perintah test/lint/build sungguhan di terminal dan buktikan dengan output terbaru sebelum mengklaim selesai.
- Saat developer mengetik **`update sura`**, tandai task selesai di `TASK_LOG.md` & `MEMORY.md`, dan apabila developer langsung memulai proyek/fitur berikutnya, hapus `PRD.md` & `TRD.md` lama untuk diganti dengan spesifikasi proyek baru.
