---
description: Kerjakan task dari TRD satu per satu dengan verifikasi — sama dengan "eksekusi"
argument-hint: "[nomor/nama task]"
---

Jalankan langkah **`eksekusi`** dari skill `sura-prd-trd` (bagian "Alur `build prd` → `build trd` → `eksekusi`").

- **Gerbang:** baca `sura-memory/TRD/TRD.md`. Bila belum ada atau masih template (placeholder `{{...}}`, Tasks Breakdown kosong), berhenti dan arahkan developer ke `/sura:build-trd`.
- Task yang diminta developer (kosong = task berikutnya yang belum `Done`): `$ARGUMENTS`
- Sajikan rencana task dalam format **Tujuan → Lokasi → Arahan → Verifikasi**, lalu **tunggu "lanjut" atau "eksekusi"** sebelum mengubah file apa pun.
- Setelah dikerjakan, jalankan verifikasi sesuai `TEST_MODE` dan tempel output terbarunya. Tandai status task di TRD dan `TASK_LOG.md`.
- Satu task per giliran. Setelah semua task `Done`, sarankan `/sura:update`.
