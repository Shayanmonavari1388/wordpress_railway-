# ShMWordPress — WordPress on Railway

پروژه آماده برای اجرای **WordPress رسمی** روی [Railway](https://railway.app) با:

- Image رسمی `wordpress:latest`
- سرویس **MySQL** جداگانه (رسمی Railway)
- **Persistent Volume** برای حفظ فایل‌ها، افزونه‌ها، قالب‌ها و uploads
- امکان اتصال دامنه اختصاصی
- بدون نیاز به VPS

ساختار بسیار ساده است و فقط شامل فایل‌های ضروری می‌شود.

```
ShMWordPress/
├── Dockerfile
├── .dockerignore
├── .gitignore
└── README.md
```

---

## پیش‌نیازها

1. حساب کاربری در [Railway](https://railway.app)
2. حساب [GitHub](https://github.com)
3. این Repository را روی GitHub قرار دهید (یا fork کنید)

---

## مراحل Deploy روی Railway

### ۱. ساخت Project در Railway

1. وارد [Railway Dashboard](https://railway.app/dashboard) شوید.
2. روی **New Project** کلیک کنید.
3. گزینه **Empty Project** را انتخاب کنید (یا بعداً از GitHub Deploy کنید).

### ۲. اضافه کردن سرویس MySQL

1. داخل Project روی **+ New** کلیک کنید.
2. **Database** → **MySQL** را انتخاب کنید.
3. صبر کنید تا MySQL Deploy شود.
4. نام سرویس را یادداشت کنید (معمولاً `MySQL`). اگر نام دیگری گذاشتید، در مرحله Environment Variables از همان نام استفاده کنید.

### ۳. Deploy کردن Repository از GitHub

1. روی **+ New** → **GitHub Repo** کلیک کنید.
2. Repository این پروژه را انتخاب کنید.
3. Railway به‌طور خودکار Dockerfile را تشخیص می‌دهد و Build را شروع می‌کند.
4. نام سرویس را مثلاً `WordPress` بگذارید.

> **نکته:** اگر Project خالی ساختید، می‌توانید از **Settings** سرویس، Source را به GitHub Repo وصل کنید.

### ۴. تنظیم Environment Variables

روی سرویس **WordPress** بروید → تب **Variables** → این متغیرها را اضافه کنید:

| Variable               | Value                                              |
|------------------------|----------------------------------------------------|
| `WORDPRESS_DB_HOST`    | `${{MySQL.MYSQLHOST}}:${{MySQL.MYSQLPORT}}`       |
| `WORDPRESS_DB_USER`    | `${{MySQL.MYSQLUSER}}`                             |
| `WORDPRESS_DB_PASSWORD`| `${{MySQL.MYSQLPASSWORD}}`                         |
| `WORDPRESS_DB_NAME`    | `${{MySQL.MYSQLDATABASE}}`                         |

**توضیح syntax:**

- `${{ServiceName.VARIABLE}}` سینتکس رسمی Reference Variable در Railway است.
- اگر نام سرویس MySQL شما متفاوت است (مثلاً `mysql` یا `Database`)، به‌جای `MySQL` همان نام را بنویسید.
- Railway هنگام Deploy این مقادیر را از سرویس MySQL می‌خواند و به کانتینر WordPress تزریق می‌کند.

می‌توانید از **Raw Editor** استفاده کنید و این بلوک را paste کنید (نام سرویس را در صورت نیاز تغییر دهید):

```
WORDPRESS_DB_HOST=${{MySQL.MYSQLHOST}}:${{MySQL.MYSQLPORT}}
WORDPRESS_DB_USER=${{MySQL.MYSQLUSER}}
WORDPRESS_DB_PASSWORD=${{MySQL.MYSQLPASSWORD}}
WORDPRESS_DB_NAME=${{MySQL.MYSQLDATABASE}}
```

بعد از ذخیره، Railway سرویس را Redeploy می‌کند.

### ۵. ساخت Persistent Volume

بدون Volume، بعد از هر Restart یا Redeploy، فایل‌های WordPress (افزونه‌ها، قالب‌ها، uploads) پاک می‌شوند.

1. روی سرویس **WordPress** بروید.
2. تب **Settings** → بخش **Volumes** (یا از Canvas روی سرویس راست‌کلیک کنید).
3. **Add Volume** / **Mount Volume** را بزنید.
4. **Mount Path** را دقیقاً این مقدار قرار دهید:

```
/var/www/html
```

5. حجم پیشنهادی: حداقل `1 GB` (برای شروع کافی است؛ بعداً می‌توانید افزایش دهید).

حالا تمام محتویات `/var/www/html` (هسته WordPress، `wp-content`، uploads و ...) پایدار می‌مانند.

### ۶. Generate Domain

1. روی سرویس **WordPress** → تب **Settings** → **Networking**.
2. روی **Generate Domain** کلیک کنید.
3. یک دامنه عمومی شبیه `your-app.up.railway.app` دریافت می‌کنید.
4. این دامنه را در مرورگر باز کنید.

### ۷. ورود به صفحه نصب WordPress

بعد از Deploy موفق و تنظیم متغیرها و Volume:

1. دامنه تولیدشده را باز کنید.
2. صفحه نصب ۵ دقیقه‌ای WordPress نمایش داده می‌شود.
3. زبان را انتخاب کنید، اطلاعات سایت، نام کاربری ادمین و رمز عبور را وارد کنید و نصب را کامل کنید.

اگر صفحه سفید یا خطای دیتابیس دیدید:

- مطمئن شوید Environment Variables درست هستند و نام سرویس MySQL دقیق است.
- Logs سرویس WordPress را در Railway بررسی کنید.
- مطمئن شوید Volume روی `/var/www/html` mount شده است.

### ۸. اتصال دامنه اختصاصی (اختیاری)

1. روی سرویس WordPress → **Settings** → **Networking**.
2. **Custom Domain** را اضافه کنید.
3. در پنل DNS دامنه خود، یک **CNAME** به دامنه Railway (مثلاً `your-app.up.railway.app`) بسازید.
4. Railway به‌طور خودکار SSL (HTTPS) صادر می‌کند.

---

## ساختار نهایی در Railway

```
Railway Project
├── WordPress Service
│   ├── Source: این GitHub Repo (Dockerfile)
│   ├── Volume → /var/www/html
│   └── Variables: WORDPRESS_DB_* (مراجعه به MySQL)
└── MySQL Service
    └── (متغیرهای MYSQLHOST, MYSQLPORT, MYSQLUSER, ...)
```

---

## نکات مهم

- **MySQL داخل کانتینر WordPress نصب نشده** — کاملاً جدا و مدیریت‌شده توسط Railway است.
- از image رسمی `wordpress:latest` استفاده شده؛ نیازی به نصب دستی Apache یا PHP نیست.
- **رفع خطای MPM:** Dockerfile شامل دستورات لازم برای غیرفعال‌کردن `mpm_event` / `mpm_worker` و فعال‌کردن فقط `mpm_prefork` است (مشکل رایج روی Railway).
- Volume روی `/var/www/html` ضروری است تا داده‌ها بعد از Deploy از بین نروند.
- هیچ Secret یا Password واقعی داخل فایل‌های پروژه قرار نگرفته است.
- برای به‌روزرسانی WordPress Core، افزونه‌ها و قالب‌ها از داشبورد خود WordPress استفاده کنید (Volume آن‌ها را نگه می‌دارد).
- اگر می‌خواهید نسخه خاصی از WordPress را قفل کنید، در Dockerfile به‌جای `latest` از تگ مشخص استفاده کنید (مثلاً `wordpress:6.7-php8.2-apache`).
- **مهم:** در Settings سرویس WordPress، فیلد **Custom Start Command** را خالی بگذارید تا CMD داخل Dockerfile اجرا شود. اگر Start Command سفارشی دارید، آن را پاک کنید یا با دستور زیر جایگزین کنید.

---

## عیب‌یابی سریع

| مشکل                        | راه‌حل پیشنهادی                                      |
|-----------------------------|-----------------------------------------------------|
| `More than one MPM loaded`  | Dockerfile اصلاح‌شده را push کنید و Redeploy کنید. Custom Start Command را خالی بگذارید |
| خطای اتصال به دیتابیس       | نام سرویس MySQL در Reference Variables را چک کنید   |
| صفحه سفید بعد از Deploy     | Logs را ببینید + Volume را بررسی کنید               |
| فایل‌ها بعد از Redeploy پاک می‌شوند | Volume باید روی `/var/www/html` mount شده باشد     |
| دامنه باز نمی‌شود           | Generate Domain را انجام دهید و Deploy را چک کنید   |

### اگر هنوز خطای MPM می‌بینید

در Railway → سرویس WordPress → **Settings** → **Deploy** → فیلد **Custom Start Command** را کاملاً خالی کنید (تا CMD داخل Dockerfile استفاده شود).

یا این دستور را به‌عنوان Start Command بگذارید:

```
bash -c "a2dismod mpm_event mpm_worker 2>/dev/null || true; rm -f /etc/apache2/mods-enabled/mpm_event.* /etc/apache2/mods-enabled/mpm_worker.* 2>/dev/null || true; a2enmod mpm_prefork 2>/dev/null || true; exec docker-entrypoint.sh apache2-foreground"
```

---

## لایسنس

این پروژه فقط یک اسکلت Deploy است. WordPress تحت مجوز GPL منتشر می‌شود.
