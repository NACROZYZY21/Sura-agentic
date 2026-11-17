---
description: Susun TRD (bagaimana, teknis) dari PRD yang sudah terisi atau PRD kiriman, simpan ke sura-memory/TRD/TRD.md — sama dengan "build trd"
argument-hint: "[path PRD kiriman (.pdf/.md), atau catatan teknis]"
---

Jalankan langkah **`build trd`** dari skill `sura-prd-trd` (bagian "Alur `build prd` → `build trd` → `eksekusi`").

- Masukan developer (boleh kosong) — path PRD kiriman dan/atau catatan teknis: `$ARGUMENTS`
- **PRD kiriman:** bila masukan atau pesan developer memuat PRD buatan orang lain (file `.pdf`/`.md`), impor dulu ke `sura-memory/TRD/PRD.md` sesuai aturan impor di skill (file asli tidak diubah, nomori `US-xx`, yang kosong jadi `Belum ditentukan` + Pertanyaan Terbuka, tunggu persetujuan ringkasan).
- **Gerbang:** tanpa PRD kiriman, baca `sura-memory/TRD/PRD.md`. Bila belum ada atau masih template (placeholder `{{...}}`, user story kosong), berhenti dan arahkan developer ke `/sura:build-prd`.
- Petakan kode yang ada (Graphify bila `graphify-out/` ada) sesuai mode Existing/Greenfield, lalu tulis TRD sesuai `PROJECT_SCOPE` & `TEST_MODE`.
- Setiap user story PRD (`US-xx`) wajib punya task di tabel Tasks Breakdown. Sebutkan user story yang belum tercakup sebelum menyatakan TRD selesai.
- Tulis TRD hanya setelah developer menyetujui ringkasannya. Penutup: sarankan `/sura:execute`.
