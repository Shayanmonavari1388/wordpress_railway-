# ShMWordPress (English) — WordPress on Railway

Ready-to-deploy **official WordPress** on [Railway](https://railway.app) with:

- Official image `wordpress:latest`
- Separate Railway **MySQL** service
- **Persistent Volume** for WordPress files, plugins, themes, and uploads
- Custom domain support
- No VPS required

```
ShMWordPress-EN/
├── Dockerfile
├── .dockerignore
├── .gitignore
└── README.md
```

---

## Prerequisites

1. [Railway](https://railway.app) account
2. [GitHub](https://github.com) account
3. Push this repository to GitHub

---

## Deploy steps on Railway

### 1. Create a Project

1. Open [Railway Dashboard](https://railway.app/dashboard)
2. Click **New Project** → **Empty Project**

### 2. Add MySQL

1. Click **+ New** → **Database** → **MySQL**
2. Wait until MySQL is deployed
3. Note the service name (usually `MySQL`)

### 3. Deploy this repository

1. Click **+ New** → **GitHub Repo**
2. Select this repository
3. Railway will detect the Dockerfile and build
4. Name the service e.g. `WordPress`

### 4. Environment Variables

On the **WordPress** service → **Variables** tab, add:

| Variable                | Value                                           |
|-------------------------|-------------------------------------------------|
| `WORDPRESS_DB_HOST`     | `${{MySQL.MYSQLHOST}}:${{MySQL.MYSQLPORT}}`    |
| `WORDPRESS_DB_USER`     | `${{MySQL.MYSQLUSER}}`                          |
| `WORDPRESS_DB_PASSWORD` | `${{MySQL.MYSQLPASSWORD}}`                      |
| `WORDPRESS_DB_NAME`     | `${{MySQL.MYSQLDATABASE}}`                      |

If your MySQL service has a different name, replace `MySQL` accordingly.

Raw Editor paste:

```
WORDPRESS_DB_HOST=${{MySQL.MYSQLHOST}}:${{MySQL.MYSQLPORT}}
WORDPRESS_DB_USER=${{MySQL.MYSQLUSER}}
WORDPRESS_DB_PASSWORD=${{MySQL.MYSQLPASSWORD}}
WORDPRESS_DB_NAME=${{MySQL.MYSQLDATABASE}}
```

### 5. Persistent Volume

1. WordPress service → **Settings** → **Volumes**
2. Add Volume with Mount Path:

```
/var/www/html
```

Suggested size: at least `1 GB`.

### 6. Generate Domain

1. WordPress service → **Settings** → **Networking**
2. Click **Generate Domain**
3. Open the `*.up.railway.app` URL

### 7. WordPress install wizard

Open the public URL → complete the 5-minute install (choose language, site title, admin user).

### 8. Custom domain (optional)

1. **Settings** → **Networking** → **Custom Domain**
2. Add a CNAME in your DNS pointing to the Railway domain
3. SSL is issued automatically

---

## Railway layout

```
Railway Project
├── WordPress Service
│   ├── Source: this GitHub Repo
│   ├── Volume → /var/www/html
│   └── Variables: WORDPRESS_DB_* → MySQL
└── MySQL Service
```

---

## Important notes

- MySQL is **not** inside the WordPress container.
- The Dockerfile fixes the common Railway error `AH00534: More than one MPM loaded`.
- Keep **Custom Start Command** empty so the Dockerfile `CMD` runs.
- No secrets are stored in the repo.

### If you still see MPM errors

Set **Custom Start Command** to:

```
bash -c "a2dismod mpm_event mpm_worker 2>/dev/null || true; rm -f /etc/apache2/mods-enabled/mpm_event.* /etc/apache2/mods-enabled/mpm_worker.* 2>/dev/null || true; a2enmod mpm_prefork 2>/dev/null || true; exec docker-entrypoint.sh apache2-foreground"
```

---

## License

Deploy skeleton only. WordPress is GPL.
