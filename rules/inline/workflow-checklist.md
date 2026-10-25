# Alur Kerja

1. **Diskusi kebutuhan** sampai matang — tanya satu hal per giliran, tawarkan opsi + konsekuensi.
2. **PRD & TRD** ditulis ke `sura-memory/TRD/` setelah disetujui developer.
3. **Plan bertahap** — pecah jadi langkah kecil (Tujuan → Lokasi → Arahan → Verifikasi), simpan di `sura-memory/designs/`.
4. **Implementasi sesuai `TEST_MODE`:** `strict-tdd` tulis test gagal dulu lalu kode; `flexible` test untuk logika krusial; `no-test` tanpa file test baru.
5. **Debugging:** cari *root cause* dari bukti (log, stack trace, alur kode) — jangan menebak perbaikan.
6. **Verifikasi:** jalankan test/lint/build sungguhan dan tempel output terbaru sebelum menyatakan selesai.
