# Graphify Knowledge Graph Protocol

Saat repositori memiliki folder `graphify-out/` atau MCP server `graphify` aktif:

## 1. Aturan Eksplorasi Arsitektur & Blast Radius
- **Prioritaskan Subgraph daripada Grep Mentah:**
  - Gunakan tool MCP `query_graph` atau CLI `graphify query "<pertanyaan>"` untuk memetakan alur fitur dan arsitektur modul.
  - Gunakan `shortest_path` untuk melacak jalur pemanggilan antara komponen A (misal Handler/UI) dan komponen B (misal Repository/API).
  - Gunakan `get_node` dan `get_neighbors` untuk memeriksa dependensi fungsi/file sebelum mengisi bagian **Blast Radius** di `TRD` dan `DESIGN_BEFORE_CODE.md`.
  - Gunakan `god_nodes` atau `get_community` untuk memahami modul inti proyek baru secara instan.

## 2. Kapan Graphify Wajib Dipakai?
- Di awal sesi saat menjalankan **`baca sura`** atau **`/design`** untuk mengidentifikasi file yang wajib disentuh vs tidak boleh disentuh.
- Saat menyusun bagian **Blast Radius & Layer Design** di dalam dokumen **TRD**.
- Saat melakukan *impact analysis* sebelum merombak fungsi/tipe yang dipakai bersama.

## 3. Kapan Graphify Diperbarui?
- Jika proyek belum memiliki `graphify-out/graph.json`, tawarkan inisialisasi cepat atau jalankan ekstraksi AST Graphify.
- Jalankan pembaruan incremental (`graphify --update` / `graphify update .`) hanya saat ada penambahan modul baru atau refactor arsitektur yang signifikan — jangan re-index di setiap edit kecil agar tetap cepat dan hemat komputasi.

