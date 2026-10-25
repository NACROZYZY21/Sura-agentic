---
description: Pasang Sura di proyek ini (sura-memory/, profil ~/.sura, .ignore) — tanpa menulis file rules ke repo
argument-hint: "[scope] [test-mode]"
---

Siapkan Sura di proyek yang sedang dibuka.

1. Tentukan profil proyek. Argumen dari developer: `$ARGUMENTS`.
   - Scope: `fullstack` | `backend` | `frontend` | `apidef` | `cli-lib`
   - Test mode: `strict-tdd` | `flexible` | `no-test`
   - Bila argumen kosong atau tidak lengkap, tanyakan dulu ke developer (sebutkan tebakanmu dari isi repo sebagai default). Jangan lanjut sebelum dijawab.
2. Jalankan (ganti `<scope>` dan `<test>`):

   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/install.sh" . --plugin --scope <scope> --test <test>
   ```

3. Tampilkan ringkasan output installer ke developer, lalu sarankan langkah berikutnya: isi `~/.sura/profile.md` bila masih kosong, kemudian `/sura:baca` untuk mulai diskusi kebutuhan.
