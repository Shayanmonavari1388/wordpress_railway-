# ShMWordPress — WordPress on Railway

Ready-to-deploy **official WordPress** on [Railway](https://railway.app).

پروژه آماده برای اجرای **WordPress رسمی** روی Railway.

- Official image `wordpress:latest` / Image رسمی
- Separate Railway **MySQL** / سرویس MySQL جداگانه
- **Persistent Volume** at `/var/www/html`
- Custom domain support / دامنه اختصاصی
- No VPS required / بدون نیاز به VPS
- Language is chosen during WordPress install wizard  
  زبان در صفحه نصب وردپرس انتخاب می‌شود

```
ShMWordPress/
├── Dockerfile
├── .dockerignore
├── .gitignore
├── LICENSE
└── README.md
```

---

## فارسی

### پیش‌نیازها

1. حساب [Railway](https://railway.app)
2. حساب [GitHub](https://github.com)
3. این Repository را روی GitHub قرار دهید

### مراحل Deploy

#### ۱. ساخت Project
- [Railway Dashboard](https://railway.app/dashboard) → **New Project** → **Empty Project**

#### ۲. اضافه کردن MySQL
- **+ New** → **Database** → **MySQL**
- نام سرویس را یادداشت کنید (معمولاً `MySQL`)

#### ۳. Deploy از GitHub
- **+ New** → **GitHub Repo** → این Repository را انتخاب کنید
- نام سرویس مثلاً `WordPress`

#### ۴. Environment Variables

سرویس WordPress → **Variables**:

| Variable | Value |
|----------|--------|
| `WORDPRESS_DB_HOST` | `${{MySQL.MYSQLHOST}}:${{MySQL.MYSQLPORT}}` |
| `WORDPRESS_DB_USER` | `${{MySQL.MYSQLUSER}}` |
| `WORDPRESS_DB_PASSWORD` | `${{MySQL.MYSQLPASSWORD}}` |
| `WORDPRESS_DB_NAME` | `${{MySQL.MYSQLDATABASE}}` |

اگر نام سرویس MySQL متفاوت است، `MySQL` را عوض کنید.

Raw Editor:

```
WORDPRESS_DB_HOST=${{MySQL.MYSQLHOST}}:${{MySQL.MYSQLPORT}}
WORDPRESS_DB_USER=${{MySQL.MYSQLUSER}}
WORDPRESS_DB_PASSWORD=${{MySQL.MYSQLPASSWORD}}
WORDPRESS_DB_NAME=${{MySQL.MYSQLDATABASE}}
```

#### ۵. Persistent Volume
- Settings → **Volumes**
- Mount Path: `/var/www/html`
- حداقل `1 GB`

#### ۶. Generate Domain
- Settings → **Networking** → **Generate Domain**

#### ۷. نصب وردپرس
دامنه را باز کنید → صفحه نصب → **زبان را انتخاب کنید** (فارسی یا انگلیسی) → نصب را کامل کنید.

#### ۸. دامنه اختصاصی (اختیاری)
- Custom Domain + CNAME در DNS → SSL خودکار

### نکات مهم

- MySQL داخل کانتینر WordPress نیست.
- Dockerfile خطای `More than one MPM loaded` را روی Railway رفع می‌کند.
- **Custom Start Command** را خالی بگذارید.
- اگر هنوز خطای MPM دیدید، این Start Command را بگذارید:

```
bash -c "a2dismod mpm_event mpm_worker 2>/dev/null || true; rm -f /etc/apache2/mods-enabled/mpm_event.* /etc/apache2/mods-enabled/mpm_worker.* 2>/dev/null || true; a2enmod mpm_prefork 2>/dev/null || true; exec docker-entrypoint.sh apache2-foreground"
```

---

## English

### Prerequisites

1. [Railway](https://railway.app) account
2. [GitHub](https://github.com) account
3. Push this repository to GitHub

### Deploy steps

#### 1. Create a Project
- [Railway Dashboard](https://railway.app/dashboard) → **New Project** → **Empty Project**

#### 2. Add MySQL
- **+ New** → **Database** → **MySQL**
- Note the service name (usually `MySQL`)

#### 3. Deploy from GitHub
- **+ New** → **GitHub Repo** → select this repository
- Name the service e.g. `WordPress`

#### 4. Environment Variables

WordPress service → **Variables**:

| Variable | Value |
|----------|--------|
| `WORDPRESS_DB_HOST` | `${{MySQL.MYSQLHOST}}:${{MySQL.MYSQLPORT}}` |
| `WORDPRESS_DB_USER` | `${{MySQL.MYSQLUSER}}` |
| `WORDPRESS_DB_PASSWORD` | `${{MySQL.MYSQLPASSWORD}}` |
| `WORDPRESS_DB_NAME` | `${{MySQL.MYSQLDATABASE}}` |

Replace `MySQL` if your database service has a different name.

Raw Editor:

```
WORDPRESS_DB_HOST=${{MySQL.MYSQLHOST}}:${{MySQL.MYSQLPORT}}
WORDPRESS_DB_USER=${{MySQL.MYSQLUSER}}
WORDPRESS_DB_PASSWORD=${{MySQL.MYSQLPASSWORD}}
WORDPRESS_DB_NAME=${{MySQL.MYSQLDATABASE}}
```

#### 5. Persistent Volume
- Settings → **Volumes**
- Mount Path: `/var/www/html`
- At least `1 GB`

#### 6. Generate Domain
- Settings → **Networking** → **Generate Domain**

#### 7. WordPress install
Open the URL → install wizard → **choose language** → finish setup.

#### 8. Custom domain (optional)
- Add Custom Domain + CNAME in DNS → SSL is automatic

### Important notes

- MySQL is not inside the WordPress container.
- The Dockerfile fixes Railway’s `AH00534: More than one MPM loaded` error.
- Keep **Custom Start Command** empty.
- If MPM error persists, set Start Command to:

```
bash -c "a2dismod mpm_event mpm_worker 2>/dev/null || true; rm -f /etc/apache2/mods-enabled/mpm_event.* /etc/apache2/mods-enabled/mpm_worker.* 2>/dev/null || true; a2enmod mpm_prefork 2>/dev/null || true; exec docker-entrypoint.sh apache2-foreground"
```

---

## Railway layout / ساختار

```
Railway Project
├── WordPress Service
│   ├── Source: this GitHub Repo
│   ├── Volume → /var/www/html
│   └── Variables: WORDPRESS_DB_* → MySQL
└── MySQL Service
```

## License

MIT (see `LICENSE`). WordPress itself is GPL.
