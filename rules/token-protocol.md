# Token Optimization Protocol

1. **Targeted Reading Only:** File berukuran > 100 baris **wajib** dibaca per rentang baris (`StartLine`/`EndLine`) atau dicari posisinya via grep terarah, tidak pernah dibaca utuh sekaligus.
2. **Graphify Dulu (Untuk Repo Existing):** Untuk menelusuri alur kode, relasi antar fungsi, atau *blast radius* pada repo yang sudah berjalan, ambil subgraph (`query_graph`, `get_node`, `get_neighbors`, `shortest_path`) terlebih dahulu — jangan membuka puluhan file secara acak.
3. **Abaikan Sampah Token:** Dilarang membaca `*.log`, `logs-server/`, `*-audit.json`, cache compiler (`.go-cache/`, `.gocache/`, `.gomodcache/`), `node_modules/`, `vendor/`, atau build artifact (`dist/`, `build/`, `.next/`).
4. **Universal Ignore Aktif:** Pastikan `.ignore`, `.cursorignore`, dan `.geminiignore` selalu terpasang dan diamankan bersama `sura-memory/` di `.git/info/exclude`.
5. **Single Active PRD & TRD (Auto-Replace):**
   - Hanya simpan **1 PRD aktif (`sura-memory/TRD/PRD.md`)** dan **1 TRD aktif (`sura-memory/TRD/TRD.md`)** untuk proyek/fitur yang sedang dikerjakan.
   - Saat Proyek A selesai dan berpindah ke Proyek B, hapus PRD & TRD Proyek A lalu ganti dengan PRD & TRD Proyek B agar tidak membebani pembacaan token di sesi berikutnya.
6. **Manajemen Riwayat Memori:**
   - `TASK_LOG.md` hanya memuat **task aktif + maksimal 2 task selesai terakhir**. Entri yang lebih lama wajib dipindahkan ke `TASK_LOG.archive.md` saat `update sura`.
   - File di dalam `TASK_LOG.archive.md`, `sura-memory/reviews/`, dan `sura-memory/lessons/` **tidak dibaca otomatis** di awal sesi — buka secara selektif hanya saat relevan atau diminta eksplisit.
