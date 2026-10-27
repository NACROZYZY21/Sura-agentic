---
name: sura-project-profile
description: Gunakan saat menyusun desain/TRD, memilih strategi test atau menulis test, menentukan apa yang dikerjakan sesuai scope proyek, atau menyentuh repo sibling — berisi adaptasi PROJECT_SCOPE, TEST_MODE, multi-repo, dan peta folder sura-memory/.
---

# Profil Proyek & Struktur Folder Adaptif

Sura-agentic beradaptasi dengan repositori tempat ia dipasang — baik **Existing / Brownfield** maupun **Greenfield**. Selalu periksa blok **Profil Proyek** di `sura-memory/CONVENTIONS.md`.

## 1. Adaptasi Berdasarkan Kondisi Repo
- **Existing / Brownfield:** pelajari struktur folder, arsitektur layer, dan kode yang berjalan (lewat Graphify bila `graphify-out/` ada) sebelum menyusun PRD & TRD. Ikuti pola penamaan dan konvensi handler/service/repo/component yang sudah ada.
- **Greenfield:** bantu merancang struktur folder terbaik sesuai `PROJECT_SCOPE`. Jadikan `TRD/PRD.md` & `TRD/TRD.md` cetak biru sebelum membuat file kode pertama.

## 2. Adaptasi Berdasarkan `PROJECT_SCOPE`
- **`fullstack`:** sertakan kontrak API, alur Backend (Handler → Service → Repo → DB), dan Frontend (API Client → Hook/State → UI). Urutan kerja: **Kontrak API → Backend → Frontend**.
- **`backend`:** fokus pada Endpoint, Validasi, Logic Service, Query Repository/Database, Migration SQL, performa & keamanan. Seksi UI hanya sebagai konteks pemanggil API.
- **`frontend`:** fokus pada Halaman/Route, Komponen UI, State Management, Pagination/Filter, Integrasi API Client, dan state Error/Empty/Loading. Sebelum integrasi, cek apakah endpoint Backend sudah siap atau masih stub/mock.
- **`apidef` / `cli-lib`:** fokus pada skema kontrak (OpenAPI/Swagger/Protobuf) atau antarmuka fungsi publik, *breaking changes*, validasi skema, dan alur rilis/tag.

## 3. Adaptasi Berdasarkan `TEST_MODE`
- **`strict-tdd`:** disiplin penuh siklus Red-Green-Refactor per layer (Repo, Service, Handler, Component); seluruh test **PASS** dan memenuhi batas coverage proyek sebelum PR.
- **`flexible`:** unit test untuk business logic utama, kalkulasi, atau bug fix krusial. Perubahan konfigurasi/UI minor cukup dijaga linter, typecheck, dan test yang sudah ada.
- **`no-test`:** **jangan** membuat file `*.test.*` / `*_test.*` baru kecuali diminta. Verifikasi wajib: **build sukses (`exit 0`) + linter/formatter bersih (`0 error`) + checklist fungsional manual**.

## 4. Multi-Repo & Sibling Repositories
Jika proyek bagian dari ekosistem multi-repo (pola `ApiDefinition → ApiGo → Backend → WebApp`):
- Periksa **Sibling Repositories** di `sura-memory/README.md` dan `MEMORY.md`.
- Baca `COMMANDS.md` bila task butuh sinkronisasi antar repo.
- Jaga *Blast Radius*: hanya ubah file di repo aktif; catat dependensi ke repo sibling di TRD / Task Log.

## 5. Peta Folder `sura-memory/`
Terlindungi di `.git/info/exclude`:
- `MEMORY.md` — konteks utama, profil developer, task aktif, batasan proyek, kamus domain.
- `CONVENTIONS.md` — profil proyek (`PROJECT_SCOPE`, `TEST_MODE`), arsitektur folder, perintah utama, standar Git/PR.
- `COMMANDS.md` — cheat sheet perintah terminal proyek.
- `SKILL.md` — jurus operasional (`/design`, `/verify`, `/retro`, `/review-pr`, `/clean`).
- `DESIGN_BEFORE_CODE.md` — template 10-section sebelum menulis kode.
- `PR_REVIEW_PLAYBOOK.md` — checklist review PR.
- `TASK_LOG.md` & `TASK_LOG.archive.md` — task aktif (maks 3) & arsip riwayat.
- `TRD/PRD.md` & `TRD/TRD.md` — PRD & TRD fitur aktif. `TRD/archive/` — PRD/TRD fitur yang sudah selesai (diarsipkan, bukan dihapus).
- `designs/` — breakdown desain teknis task aktif.
- `reviews/` — hasil review PR (`PR_<nomor>_<slug>.md`).
- `lessons/` — post-mortem agar kesalahan tidak terulang.
