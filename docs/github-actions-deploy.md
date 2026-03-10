# GitHub Actions Build Image (Untuk Dockploy)

Workflow ini akan:
1. Build image Docker Laravel di GitHub Actions.
2. Push image ke GitHub Container Registry (GHCR).
3. Menyediakan tag image yang bisa langsung dipakai di Dockploy.

## File Workflow

Workflow ada di `.github/workflows/deploy.yml`.

## Secrets yang Wajib Diisi

Tambahkan di GitHub repository settings -> Secrets and variables -> Actions.

Tidak perlu secret SSH/VPS.

Yang dipakai cukup token bawaan GitHub Actions (`GITHUB_TOKEN`) untuk push image ke GHCR.

## Catatan Penting Environment

- Jangan simpan `.env` di image Docker.
- Nilai runtime seperti `APP_KEY`, `DB_*`, `MAIL_*`, `REDIS_*` diatur di Dockploy (Environment Variables atau env file).
- Jika frontend butuh variable `VITE_*`, variable itu harus tersedia saat build di GitHub Actions (karena masuk ke bundle JS).

## Setup di Dockploy

1. Tambahkan application/service baru berbasis Docker Image.
2. Isi image dengan tag dari workflow, contoh:
	- `ghcr.io/<owner-lowercase>/sistem-parkir-laravel:latest`
	- atau tag commit: `ghcr.io/<owner-lowercase>/sistem-parkir-laravel:<sha>`
3. Set runtime environment variables di Dockploy.
4. Set port mapping sesuai arsitektur Anda (container expose `9000`).
5. Jika image GHCR private, isi kredensial registry di Dockploy (`ghcr.io`, username, PAT `read:packages`).

## Trigger Workflow

Workflow jalan saat push ke branch `main`, atau manual via `workflow_dispatch`.

Di akhir workflow akan tampil output tag image yang siap dipakai untuk update service di Dockploy.
