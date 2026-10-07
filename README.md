# wsok634-web

Static site for WSOK634.net — `index.html`, `style.css`, and `assets/`. No build step.

## Deploy with Docker

```sh
./install.sh              # pulls alpine, builds the image, runs it on port 80
PORT=8080 ./install.sh    # use a different host port
```

On a fresh server without a checkout, the script clones this repo to `~/wsok634-web`
first (override with `INSTALL_DIR`). Re-run it any time to pull changes and redeploy.

The image is `alpine:3.20` + nginx serving the files from `/var/www/wsok634`.
The container restarts automatically (`--restart unless-stopped`).

## Other hosts

The folder can also be uploaded as-is to any static host (Cloudflare Pages, GitHub Pages,
Netlify, Nginx, Apache, …).
