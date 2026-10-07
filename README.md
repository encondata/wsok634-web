# wsok634-web

Static site for WSOK634.net — `index.html`, `style.css`, and `assets/`. No build step.

## Deploy with Docker

```sh
curl -fsSL https://raw.githubusercontent.com/encondata/wsok634-web/main/install.sh | sh
```

The script asks where to install the site code (default `/mnt/user/wsok634_web`),
clones or updates the repo there, pulls `alpine:3.20`, builds the image, and runs it
on port 8675. Re-run it any time to pull changes and redeploy.

- `INSTALL_DIR=/some/path` skips the prompt
- `PORT=8080` serves on a different host port

The image is `alpine:3.20` + nginx serving the files from `/var/www/wsok634`.
The container restarts automatically (`--restart unless-stopped`).

## Other hosts

The folder can also be uploaded as-is to any static host (Cloudflare Pages, GitHub Pages,
Netlify, Nginx, Apache, …).
