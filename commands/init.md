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

3. **Graphify (peta kode):** bila perintah `graphify` tersedia, proyek berisi kode, dan belum ada folder `graphify-out/`, tawarkan membuat index. Jalankan hanya setelah developer setuju:

   ```bash
   graphify update .
   ```

   Ini ekstraksi AST tanpa LLM (cepat, gratis). `graphify-out/` sudah dilindungi dari git oleh installer. Bila `graphify` tidak ada, cukup sebutkan bahwa Graphify belum terpasang.
4. Tampilkan ringkasan output installer ke developer, lalu sarankan langkah berikutnya: isi `~/.sura/profile.md` bila masih kosong, kemudian `/sura:baca` untuk mulai diskusi kebutuhan.
