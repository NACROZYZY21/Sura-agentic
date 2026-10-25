---
description: Susun TRD (bagaimana, teknis) dari PRD yang sudah terisi, simpan ke sura-memory/TRD/TRD.md — sama dengan "build trd"
argument-hint: "[catatan teknis]"
---

Jalankan langkah **`build trd`** dari skill `sura-prd-trd` (bagian "Alur `build prd` → `build trd` → `eksekusi`").

- **Gerbang:** baca `sura-memory/TRD/PRD.md`. Bila belum ada atau masih template (placeholder `{{...}}`, user story kosong), berhenti dan arahkan developer ke `/sura:build-prd`.
- Catatan teknis dari developer (boleh kosong): `$ARGUMENTS`
- Petakan kode yang ada (Graphify bila `graphify-out/` ada) sesuai mode Existing/Greenfield, lalu tulis TRD sesuai `PROJECT_SCOPE` & `TEST_MODE`.
- Setiap user story PRD (`US-xx`) wajib punya task di tabel Tasks Breakdown. Sebutkan user story yang belum tercakup sebelum menyatakan TRD selesai.
- Tulis TRD hanya setelah developer menyetujui ringkasannya. Penutup: sarankan `/sura:execute`.
