# Graphify Knowledge Graph Protocol

Saat repositori memiliki folder `graphify-out/` atau tools MCP Graphify terpasang:

## Aturan Eksplorasi Arsitektur:
1. **Prioritaskan Subgraph daripada Grep Raw:**
   - Gunakan `query_graph` atau CLI `graphify query "<pertanyaan>"` untuk mencari pemahaman arsitektur atau alur kode.
   - Gunakan `shortest_path` untuk menelusuri relasi langsung antara komponen A dan komponen B.
   - Gunakan `get_node` / `get_neighbors` untuk memeriksa fungsi tertentu tanpa perlu membuka seluruh file.
2. **Kapan Graphify Digunakan?**
   - Di awal pengerjaan task baru saat fase diskusi requirement.
   - Saat perlu mengecek dampak perubahan fungsi (*impact analysis*) terhadap file lain.
3. **Kapan Graphify Diperbarui?**
   - Jalankan `graphify update .` hanya saat ada refactor arsitektur besar atau file baru bertambah dalam jumlah signifikan.
   - Jangan re-index di setiap commit kecil untuk menghemat waktu komputasi.
