# Token Optimization Protocol

1. **Targeted Reading Only:** file > 100 baris dibaca per rentang baris atau via
   grep, tidak pernah utuh.
2. **Graphify dulu:** untuk menelusuri alur kode, ambil subgraph (`query_graph`),
   jangan membuka banyak file sekaligus.
3. **Abaikan sampah:** `*.log`, cache compiler, file audit, build artifact.
4. **Universal ignore aktif:** `.ignore`, `.cursorignore`, `.geminiignore`
   terpasang dan diamankan di `.git/info/exclude`.
5. **Jawaban padat:** to-the-point, tanpa mengulang kode yang tidak berubah.
6. **Riwayat dibatasi:** `TASK_LOG.md` hanya memuat task aktif + 2 task terakhir.
   Selebihnya dipindah ke `TASK_LOG.archive.md` dan tidak dibaca kecuali diminta.
