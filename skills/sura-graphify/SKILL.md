---
name: sura-graphify
description: Gunakan saat repo memiliki graphify-out/ atau MCP graphify aktif dan kamu perlu memetakan alur, dependensi, siapa memanggil apa, atau dampak/blast radius sebelum mengubah atau me-refactor kode.
---

# Graphify Knowledge Graph Protocol

Berlaku hanya saat repositori memiliki folder `graphify-out/` atau MCP server `graphify` aktif. Tanpa keduanya, lewati protokol ini.

## 1. Eksplorasi Arsitektur & Blast Radius
- **Subgraph dulu, bukan grep mentah atau membuka puluhan file acak:**
  - `query_graph` atau `graphify query "<pertanyaan>"` untuk memetakan alur fitur dan arsitektur modul.
  - `shortest_path` / `graphify path "A" "B"` untuk melacak jalur pemanggilan antara komponen A (Handler/UI) dan B (Repository/API).
  - `get_node` dan `get_neighbors` untuk memeriksa dependensi sebelum mengisi **Blast Radius** di TRD dan `DESIGN_BEFORE_CODE.md`.
  - `god_nodes` atau `get_community` untuk memahami modul inti proyek baru secara cepat.

## 2. Kapan Graphify Wajib Dipakai
- Saat `baca sura` atau `/design` untuk mengidentifikasi file yang wajib disentuh vs tidak boleh disentuh.
- Saat menyusun **Blast Radius & Layer Design** di TRD.
- Saat *impact analysis* sebelum merombak fungsi/tipe yang dipakai bersama.

## 3. Kapan Graphify Diperbarui
- Jika belum ada `graphify-out/graph.json`, tawarkan inisialisasi (`graphify update .` — ekstraksi AST, tanpa LLM).
- Jalankan pembaruan incremental (`graphify update .`) hanya saat ada modul baru atau refactor arsitektur signifikan — jangan re-index di setiap edit kecil.
