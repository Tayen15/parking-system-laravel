# GitHub Actions Build + Deploy (Tanpa Build di VPS)

Workflow ini akan:
1. Build image Docker Laravel di GitHub Actions.
2. Push image ke GitHub Container Registry (GHCR).
3. SSH ke VPS, pull image, lalu run container dengan environment file di VPS.

## File Workflow

Workflow ada di `.github/workflows/deploy.yml`.

## Secrets yang Wajib Diisi

Tambahkan di GitHub repository settings -> Secrets and variables -> Actions.

### Untuk SSH VPS
- `VPS_HOST`: IP/domain VPS
- `VPS_USER`: user SSH di VPS
- `VPS_SSH_KEY`: private key SSH (format OpenSSH)
- `VPS_APP_DIR`: direktori app di VPS (contoh: `/opt/sistem-parkir`)
- `VPS_ENV_FILE`: path env file di VPS (contoh: `/opt/sistem-parkir/.env`)

### Untuk Pull dari GHCR di VPS
- `GHCR_USERNAME`: username GitHub yang punya akses package
- `GHCR_PAT`: Personal Access Token dengan minimal scope `read:packages`

### Konfigurasi Container
- `CONTAINER_NAME`: nama container (contoh: `sistem-parkir-app`)
- `APP_PORT`: port host VPS yang dipetakan ke container port 9000 (contoh: `9000`)

## Catatan Penting Environment

- Jangan simpan `.env` di image Docker.
- Nilai runtime seperti `APP_KEY`, `DB_*`, `MAIL_*`, `REDIS_*` harus ada di file env di VPS.
- Jika frontend butuh variable `VITE_*`, variable itu harus tersedia saat build di GitHub Actions (karena masuk ke bundle JS).

## Persiapan di VPS

1. Pastikan Docker sudah terpasang.
2. Buat direktori deploy (sesuai `VPS_APP_DIR`).
3. Letakkan file env production di path `VPS_ENV_FILE`.
4. Pastikan user SSH punya izin menjalankan Docker.

## Trigger Deploy

Deploy otomatis jalan saat push ke branch `main`, atau manual via `workflow_dispatch`.
