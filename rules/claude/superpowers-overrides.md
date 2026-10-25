# Override Superpowers (Claude Code)

Skill Superpowers menentukan proses; aturan di bawah hanya mengganti default-nya:

1. **Lokasi dokumen:** spek dari `superpowers:brainstorming` → `sura-memory/TRD/PRD.md` + `TRD.md`. Plan dari `superpowers:writing-plans` → `sura-memory/designs/YYYY-MM-DD-<fitur>-plan.md`, ditautkan dari TRD bagian 7. Jangan tulis ke `docs/superpowers/`.
2. **Gerbang `TEST_MODE`:**
   - `strict-tdd` → `superpowers:test-driven-development` wajib.
   - `flexible` → test hanya untuk logika bisnis krusial.
   - `no-test` → jangan jalankan `superpowers:test-driven-development`; `superpowers:verification-before-completion` memakai build + lint + checklist manual.
3. **`/sura:execute`:** bila Superpowers ada, buat plan dengan `superpowers:writing-plans` dari TRD lalu jalankan dengan `superpowers:executing-plans` (gerbang `TEST_MODE` & advisor-strict tetap berlaku).
4. **Bila skill Superpowers tidak tersedia:** ikuti alur diskusi → PRD/TRD → plan bertahap → implementasi sesuai `TEST_MODE` → root cause dari bukti → verifikasi dengan output terminal.
5. **Advisor-strict menang:** `superpowers:executing-plans` / `superpowers:subagent-driven-development` tetap menunggu "lanjut" / "eksekusi" sebelum mengubah file.
