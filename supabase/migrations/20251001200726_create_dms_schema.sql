/*
  # سیستم مدیریت اسناد (DMS) - ساختار پایگاه داده

  ## جداول اصلی

  ### 1. users (کاربران)
  - `id` (uuid, primary key) - شناسه یکتا
  - `username` (text, unique) - نام کاربری
  - `email` (text, unique) - ایمیل
  - `full_name` (text) - نام کامل
  - `role` (text) - نقش کاربر (admin یا user)
  - `department` (text) - دپارتمان
  - `is_active` (boolean) - وضعیت فعال/غیرفعال
  - `created_at` (timestamptz) - تاریخ ایجاد
  - `updated_at` (timestamptz) - تاریخ آخرین بروزرسانی

  ### 2. document_categories (دسته‌بندی اسناد)
  - `id` (uuid, primary key)
  - `name` (text) - نام دسته‌بندی
  - `description` (text) - توضیحات
  - `parent_id` (uuid) - دسته‌بندی والد
  - `created_at` (timestamptz)

  ### 3. documents (اسناد)
  - `id` (uuid, primary key)
  - `title` (text) - عنوان سند
  - `description` (text) - توضیحات
  - `file_name` (text) - نام فایل
  - `file_size` (bigint) - حجم فایل
  - `file_type` (text) - نوع فایل
  - `file_path` (text) - مسیر فایل
  - `category_id` (uuid) - دسته‌بندی
  - `uploaded_by` (uuid) - کاربر بارگذاری کننده
  - `status` (text) - وضعیت (draft, pending, approved, rejected)
  - `version` (integer) - نسخه سند
  - `tags` (text[]) - تگ‌ها
  - `uploaded_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 4. document_versions (نسخه‌های سند)
  - `id` (uuid, primary key)
  - `document_id` (uuid) - شناسه سند
  - `version` (integer) - شماره نسخه
  - `file_path` (text) - مسیر فایل
  - `uploaded_by` (uuid) - کاربر بارگذاری کننده
  - `changes_description` (text) - توضیحات تغییرات
  - `uploaded_at` (timestamptz)

  ### 5. comments (نظرات)
  - `id` (uuid, primary key)
  - `document_id` (uuid) - شناسه سند
  - `user_id` (uuid) - شناسه کاربر
  - `content` (text) - محتوای نظر
  - `created_at` (timestamptz)

  ### 6. activity_logs (لاگ فعالیت‌ها)
  - `id` (uuid, primary key)
  - `user_id` (uuid) - شناسه کاربر
  - `action` (text) - نوع عملیات
  - `entity_type` (text) - نوع موجودیت
  - `entity_id` (uuid) - شناسه موجودیت
  - `details` (jsonb) - جزئیات
  - `created_at` (timestamptz)

  ## امنیت
  - فعال‌سازی RLS برای تمام جداول
  - تعریف سیاست‌های دسترسی بر اساس نقش کاربر
  - محافظت از داده‌های حساس
*/

-- جدول کاربران
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username text UNIQUE NOT NULL,
  email text UNIQUE NOT NULL,
  full_name text NOT NULL,
  role text NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'user')),
  department text,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- جدول دسته‌بندی اسناد
CREATE TABLE IF NOT EXISTS document_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  parent_id uuid REFERENCES document_categories(id),
  created_at timestamptz DEFAULT now()
);

-- جدول اسناد
CREATE TABLE IF NOT EXISTS documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  file_name text NOT NULL,
  file_size bigint NOT NULL,
  file_type text NOT NULL,
  file_path text NOT NULL,
  category_id uuid REFERENCES document_categories(id),
  uploaded_by uuid REFERENCES users(id) NOT NULL,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'pending', 'approved', 'rejected')),
  version integer DEFAULT 1,
  tags text[] DEFAULT '{}',
  uploaded_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- جدول نسخه‌های سند
CREATE TABLE IF NOT EXISTS document_versions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id uuid REFERENCES documents(id) ON DELETE CASCADE NOT NULL,
  version integer NOT NULL,
  file_path text NOT NULL,
  uploaded_by uuid REFERENCES users(id) NOT NULL,
  changes_description text,
  uploaded_at timestamptz DEFAULT now()
);

-- جدول نظرات
CREATE TABLE IF NOT EXISTS comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id uuid REFERENCES documents(id) ON DELETE CASCADE NOT NULL,
  user_id uuid REFERENCES users(id) NOT NULL,
  content text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- جدول لاگ فعالیت‌ها
CREATE TABLE IF NOT EXISTS activity_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) NOT NULL,
  action text NOT NULL,
  entity_type text NOT NULL,
  entity_id uuid NOT NULL,
  details jsonb,
  created_at timestamptz DEFAULT now()
);

-- ایجاد ایندکس‌ها
CREATE INDEX IF NOT EXISTS idx_documents_category ON documents(category_id);
CREATE INDEX IF NOT EXISTS idx_documents_uploaded_by ON documents(uploaded_by);
CREATE INDEX IF NOT EXISTS idx_documents_status ON documents(status);
CREATE INDEX IF NOT EXISTS idx_document_versions_document ON document_versions(document_id);
CREATE INDEX IF NOT EXISTS idx_comments_document ON comments(document_id);
CREATE INDEX IF NOT EXISTS idx_activity_logs_user ON activity_logs(user_id);

-- فعال‌سازی RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_logs ENABLE ROW LEVEL SECURITY;

-- سیاست‌های دسترسی برای users
CREATE POLICY "کاربران می‌توانند پروفایل خود را مشاهده کنند"
  ON users FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "ادمین‌ها می‌توانند تمام کاربران را مشاهده کنند"
  ON users FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "ادمین‌ها می‌توانند کاربر ایجاد کنند"
  ON users FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "ادمین‌ها می‌توانند کاربران را ویرایش کنند"
  ON users FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- سیاست‌های دسترسی برای document_categories
CREATE POLICY "همه می‌توانند دسته‌بندی‌ها را مشاهده کنند"
  ON document_categories FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "ادمین‌ها می‌توانند دسته‌بندی ایجاد کنند"
  ON document_categories FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- سیاست‌های دسترسی برای documents
CREATE POLICY "کاربران می‌توانند اسناد را مشاهده کنند"
  ON documents FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "کاربران می‌توانند سند بارگذاری کنند"
  ON documents FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = uploaded_by);

CREATE POLICY "کاربران می‌توانند اسناد خود را ویرایش کنند"
  ON documents FOR UPDATE
  TO authenticated
  USING (auth.uid() = uploaded_by)
  WITH CHECK (auth.uid() = uploaded_by);

CREATE POLICY "ادمین‌ها می‌توانند تمام اسناد را ویرایش کنند"
  ON documents FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "کاربران می‌توانند اسناد خود را حذف کنند"
  ON documents FOR DELETE
  TO authenticated
  USING (auth.uid() = uploaded_by);

-- سیاست‌های دسترسی برای document_versions
CREATE POLICY "کاربران می‌توانند نسخه‌های اسناد را مشاهده کنند"
  ON document_versions FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "کاربران می‌توانند نسخه جدید بارگذاری کنند"
  ON document_versions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = uploaded_by);

-- سیاست‌های دسترسی برای comments
CREATE POLICY "کاربران می‌توانند نظرات را مشاهده کنند"
  ON comments FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "کاربران می‌توانند نظر بگذارند"
  ON comments FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "کاربران می‌توانند نظرات خود را حذف کنند"
  ON comments FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- سیاست‌های دسترسی برای activity_logs
CREATE POLICY "کاربران می‌توانند لاگ‌ها را مشاهده کنند"
  ON activity_logs FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "سیستم می‌تواند لاگ ایجاد کند"
  ON activity_logs FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- درج دسته‌بندی‌های پیش‌فرض
INSERT INTO document_categories (name, description)
VALUES
  ('قراردادها', 'اسناد مربوط به قراردادها'),
  ('گزارشات', 'گزارشات و مستندات'),
  ('صورتجلسات', 'صورتجلسات جلسات'),
  ('مالی', 'اسناد و مدارک مالی'),
  ('پرسنلی', 'اسناد پرسنلی'),
  ('سایر', 'سایر اسناد')
ON CONFLICT DO NOTHING;
