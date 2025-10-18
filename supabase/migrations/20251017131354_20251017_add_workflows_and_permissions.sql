/*
  # اضافه کردن گردش کار و مدیریت دسترسی

  ## جداول جدید

  ### 1. user_groups (گروه‌های کاربری)
  ### 2. user_group_members (اعضای گروه‌ها)
  ### 3. workflows (گردش کارها)
  ### 4. workflow_steps (مراحل گردش کار)
  ### 5. permissions (دسترسی‌ها)
  ### 6. document_workflow_history (تاریخچه گردش کار اسناد)

  ## امنیت
  - فعال‌سازی RLS برای تمام جداول
  - تعریف سیاست‌های دسترسی بر اساس نقش
*/

-- جدول گروه‌های کاربری
CREATE TABLE IF NOT EXISTS user_groups (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  description text,
  created_at timestamptz DEFAULT now()
);

-- جدول اعضای گروه‌ها
CREATE TABLE IF NOT EXISTS user_group_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id uuid REFERENCES user_groups(id) ON DELETE CASCADE NOT NULL,
  user_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  assigned_at timestamptz DEFAULT now(),
  UNIQUE(group_id, user_id)
);

-- جدول گردش کارها
CREATE TABLE IF NOT EXISTS workflows (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  category_id uuid REFERENCES document_categories(id),
  is_active boolean DEFAULT true,
  created_by uuid REFERENCES users(id) NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- جدول مراحل گردش کار
CREATE TABLE IF NOT EXISTS workflow_steps (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workflow_id uuid REFERENCES workflows(id) ON DELETE CASCADE NOT NULL,
  step_order integer NOT NULL,
  step_name text NOT NULL,
  assigned_group_id uuid REFERENCES user_groups(id) NOT NULL,
  action_type text NOT NULL CHECK (action_type IN ('review', 'approve', 'reject', 'edit')),
  is_required boolean DEFAULT true,
  UNIQUE(workflow_id, step_order)
);

-- جدول دسترسی‌ها
CREATE TABLE IF NOT EXISTS permissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id uuid REFERENCES user_groups(id) ON DELETE CASCADE NOT NULL,
  resource_type text NOT NULL CHECK (resource_type IN ('documents', 'categories', 'users', 'workflows')),
  action text NOT NULL CHECK (action IN ('create', 'read', 'update', 'delete', 'approve', 'reject')),
  category_id uuid REFERENCES document_categories(id),
  created_at timestamptz DEFAULT now(),
  UNIQUE(group_id, resource_type, action, category_id)
);

-- جدول تاریخچه گردش کار اسناد
CREATE TABLE IF NOT EXISTS document_workflow_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id uuid REFERENCES documents(id) ON DELETE CASCADE NOT NULL,
  workflow_step_id uuid REFERENCES workflow_steps(id),
  user_id uuid REFERENCES users(id) NOT NULL,
  action text NOT NULL,
  comment text,
  created_at timestamptz DEFAULT now()
);

-- ایجاد ایندکس‌ها
CREATE INDEX IF NOT EXISTS idx_user_group_members_group ON user_group_members(group_id);
CREATE INDEX IF NOT EXISTS idx_user_group_members_user ON user_group_members(user_id);
CREATE INDEX IF NOT EXISTS idx_workflow_steps_workflow ON workflow_steps(workflow_id);
CREATE INDEX IF NOT EXISTS idx_permissions_group ON permissions(group_id);
CREATE INDEX IF NOT EXISTS idx_document_workflow_history_document ON document_workflow_history(document_id);

-- فعال‌سازی RLS
ALTER TABLE user_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflows ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_workflow_history ENABLE ROW LEVEL SECURITY;

-- حذف سیاست‌های قدیمی در صورت وجود
DROP POLICY IF EXISTS "view_groups" ON user_groups;
DROP POLICY IF EXISTS "create_groups" ON user_groups;
DROP POLICY IF EXISTS "update_groups" ON user_groups;
DROP POLICY IF EXISTS "delete_groups" ON user_groups;

DROP POLICY IF EXISTS "view_group_members" ON user_group_members;
DROP POLICY IF EXISTS "add_group_members" ON user_group_members;
DROP POLICY IF EXISTS "remove_group_members" ON user_group_members;

DROP POLICY IF EXISTS "view_workflows" ON workflows;
DROP POLICY IF EXISTS "create_workflows" ON workflows;
DROP POLICY IF EXISTS "update_workflows" ON workflows;
DROP POLICY IF EXISTS "delete_workflows" ON workflows;

DROP POLICY IF EXISTS "view_workflow_steps" ON workflow_steps;
DROP POLICY IF EXISTS "create_workflow_steps" ON workflow_steps;
DROP POLICY IF EXISTS "update_workflow_steps" ON workflow_steps;
DROP POLICY IF EXISTS "delete_workflow_steps" ON workflow_steps;

DROP POLICY IF EXISTS "view_permissions" ON permissions;
DROP POLICY IF EXISTS "create_permissions" ON permissions;
DROP POLICY IF EXISTS "delete_permissions" ON permissions;

DROP POLICY IF EXISTS "view_workflow_history" ON document_workflow_history;
DROP POLICY IF EXISTS "create_workflow_history" ON document_workflow_history;

-- سیاست‌های دسترسی برای user_groups
CREATE POLICY "view_groups"
  ON user_groups FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "create_groups"
  ON user_groups FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "update_groups"
  ON user_groups FOR UPDATE
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

CREATE POLICY "delete_groups"
  ON user_groups FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- سیاست‌های دسترسی برای user_group_members
CREATE POLICY "view_group_members"
  ON user_group_members FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "add_group_members"
  ON user_group_members FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "remove_group_members"
  ON user_group_members FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- سیاست‌های دسترسی برای workflows
CREATE POLICY "view_workflows"
  ON workflows FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "create_workflows"
  ON workflows FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "update_workflows"
  ON workflows FOR UPDATE
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

CREATE POLICY "delete_workflows"
  ON workflows FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- سیاست‌های دسترسی برای workflow_steps
CREATE POLICY "view_workflow_steps"
  ON workflow_steps FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "create_workflow_steps"
  ON workflow_steps FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "update_workflow_steps"
  ON workflow_steps FOR UPDATE
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

CREATE POLICY "delete_workflow_steps"
  ON workflow_steps FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- سیاست‌های دسترسی برای permissions
CREATE POLICY "view_permissions"
  ON permissions FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "create_permissions"
  ON permissions FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "delete_permissions"
  ON permissions FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- سیاست‌های دسترسی برای document_workflow_history
CREATE POLICY "view_workflow_history"
  ON document_workflow_history FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "create_workflow_history"
  ON document_workflow_history FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- درج گروه‌های پیش‌فرض
INSERT INTO user_groups (name, description)
VALUES
  ('مدیران', 'گروه مدیران سیستم'),
  ('کارشناسان مالی', 'گروه کارشناسان بخش مالی'),
  ('کارشناسان منابع انسانی', 'گروه کارشناسان منابع انسانی'),
  ('ناظران', 'گروه ناظران و بازبینان اسناد')
ON CONFLICT DO NOTHING;
