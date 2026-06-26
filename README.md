# 🛡️ LYGEND - MSGP Security Control Room Terminal
### Camp Gatepass, Roster & Ingress Management System

[English Guide](#english-guide) | [دليل التشغيل باللغة العربية](#العربية-arabic-guide)

---

## العربية (Arabic Guide)

### ❓ لماذا لا يشتغل المشروع مباشرة عند رفعه إلى GitHub؟
المشروع مبني باستخدام **React + TypeScript + Vite**. متصفحات الويب لا تستطيع قراءة ملفات الكود المصدري من نوع `.tsx` أو ملفات TypeScript مباشرة بدون عملية تجميع وبناء (Build). 
لذلك، إذا قمت بمجرد رفع الملفات المصدرية مباشرة أو فتح ملف `index.html` في جهازك، فلن يظهر شيء في المتصفح وستظهر شاشة بيضاء أو أخطاء.

يجب بناء وتجميع المشروع أولاً لإنتاج ملفات HTML و JavaScript قياسية ومضغوطة داخل مجلد `dist/` وهو المجلد الذي يقرأه خادم الاستضافة (GitHub Pages).

لقد قمنا بحل وتسهيل هذه العملية لك بالكامل عبر **طريقتين مضمونتين 100%** لتشغيل ونشر موقعك على GitHub Pages:

---

### 🌟 الطريقة الأولى: النشر التلقائي عبر GitHub Actions (الأسهل والأفضل)
هذه الطريقة تقوم ببناء ونشر موقعك تلقائياً في الخلفية في كل مرة ترفع فيها تعديلاً جديداً (Push).

1. **ارفع كود المشروع بالكامل** إلى مستودع (Repository) جديد على حسابك في GitHub.
2. **تفعيل صلاحيات الكتابة لـ GitHub Actions (خطوة مهمة جداً قد تمنع النشر إن لم تفعلها):**
   - في صفحة المستودع الخاص بك على GitHub، اضغط على **Settings** في الشريط العلوي.
   - من القائمة الجانبية اليسرى، اضغط على **Actions** ثم اختر **General**.
   - انزل لأسفل الصفحة حتى تصل إلى قسم **Workflow permissions**.
   - قم بتغيير الخيار إلى **`Read and write permissions`** ثم اضغط على زر **Save**.
3. **تفعيل النشر التلقائي:**
   - من نفس قائمة الإعدادات الجانبية، اختر **Pages**.
   - تحت قسم **Build and deployment**:
     - عند خيار **Source**، قم بتغييره من `Deploy from a branch` إلى **`GitHub Actions`**.
4. بمجرد إتمام هذه الخطوات، سيقوم GitHub تلقائياً بتشغيل ملف المراقبة والبناء المتكامل الذي أنشأناه لك في `.github/workflows/deploy.yml` ويقوم ببناء ونشر موقعك على الرابط المباشر الخاص بك خلال دقيقة واحدة!

---

### ⚡ الطريقة الثانية: النشر اليدوي بأمر واحد عبر الـ Terminal (باستخدام gh-pages)
لقد قمنا بإضافة وتجهيز حزمة `gh-pages` الرسمية في المشروع لتتمكن من النشر مباشرة من جهازك بأمر واحد فقط:

1. افتح مبدل الأوامر (Terminal) في مجلد المشروع على جهازك.
2. قم بتشغيل الأمر التالي لبناء المشروع ورفعه لفرع النشر المخصص على GitHub تلقائياً:
   ```bash
   npm run deploy
   ```
3. سيقوم هذا الأمر تلقائياً ببناء الكود ورفع محتويات مجلد `dist/` إلى فرع جديد في GitHub يسمى `gh-pages`.
4. اذهب إلى إعدادات المستودع **Settings > Pages** وتأكد من أن **Source** هو `Deploy from a branch` والفرع (Branch) المختار هو **`gh-pages`** ثم اضغط **Save**.

---

### 💻 التشغيل والتجربة على جهازك المحلي (Local Machine):

لتشغيل وتطوير التطبيق محلياً على جهازك، اتبع الخطوات التالية:

1. تأكد من تثبيت بيئة **Node.js** (الإصدار 18 أو أحدث) على جهازك.
2. افتح مبدل الأوامر (Terminal) في مجلد المشروع وقم بتثبيت الحزم البرمجية:
   ```bash
   npm install
   ```
3. قم بتشغيل خادم التطوير المحلي:
   ```bash
   npm run dev
   ```
4. افتح المتصفح على الرابط المحلي الذي سيظهر لك (مثل `http://localhost:3000` أو `http://localhost:5173`).

---

## English Guide

### ❓ Why don't the raw files work directly on GitHub?
This application is built with **React, TypeScript, and Vite**. Modern web browsers cannot directly parse `.tsx` files or TypeScript imports. They require a compilation/build step to compile the source code into standardized, compressed HTML, CSS, and JS files (which are generated inside the `dist/` directory).

If you simply upload the raw files to GitHub Pages or double-click `index.html` locally, the browser will display a blank screen.

To make things extremely simple and bulletproof, **we have set up two highly reliable deployment methods** to publish your app to GitHub Pages:

---

### 🌟 Method 1: Automatic Deployment via GitHub Actions (Recommended)
This method automatically compiles, builds, and deploys your website in the background every time you push code changes to GitHub.

1. **Push your repository files to GitHub** (make sure the `.github/workflows/deploy.yml` folder and file are included).
2. **Enable Workflow Permissions (CRITICAL STEP - otherwise the build will fail to publish):**
   - On your GitHub Repository page, click on **Settings** in the top navigation bar.
   - On the left sidebar, under **Actions**, click on **General**.
   - Scroll down to the **Workflow permissions** section.
   - Select **`Read and write permissions`** and click **Save**.
3. **Configure Pages deployment source:**
   - Under the same left sidebar, click on **Pages**.
   - Under the **Build and deployment** section, change the **Source** dropdown from `Deploy from a branch` to **`GitHub Actions`**.
4. That's it! GitHub Actions will now automatically pick up the file at `.github/workflows/deploy.yml`, compile your code, and publish your live website in less than a minute.

---

### ⚡ Method 2: One-Command Terminal Deployment (Using gh-pages)
We have pre-installed and configured the official `gh-pages` package in your project. You can deploy directly from your local terminal with a single command:

1. Open your Terminal inside the project folder on your computer.
2. Run the deployment script:
   ```bash
   npm run deploy
   ```
3. This script will automatically compile your project and push the build assets inside `dist/` directly to a dedicated `gh-pages` branch on GitHub.
4. Go to **Settings > Pages** on your GitHub repository, make sure the **Source** is set to `Deploy from a branch` and the branch is set to **`gh-pages`**, then click **Save**.

---

### 💻 Running the App Locally:

To run and test the application on your computer, follow these simple steps:

1. Ensure you have **Node.js** (v18 or higher) installed.
2. Open your Terminal inside the project folder and install the dependencies:
   ```bash
   npm install
   ```
3. Start the local development server:
   ```bash
   npm run dev
   ```
4. Open your browser and go to the local URL shown in your terminal (usually `http://localhost:3000` or `http://localhost:5173`).
