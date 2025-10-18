import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://klewnjwcpiretqmwhvpr.supabase.co';
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtsZXduandjcGlyZXRxbXdodnByIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkzNDU4NjQsImV4cCI6MjA3NDkyMTg2NH0.rTeq2RhSkSlDdXpGKeBj06_5iAaj5SgicbI7Xh9A_Q0';

if (!supabaseServiceKey) {
  console.error('SUPABASE_SERVICE_ROLE_KEY is required');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

const users = [
  {
    email: 'admin@example.com',
    password: 'admin123',
    full_name: 'مدیر سیستم',
    username: 'admin',
    role: 'admin',
    department: 'مدیریت'
  },
  {
    email: 'user@example.com',
    password: 'user123',
    full_name: 'کاربر نمونه',
    username: 'user',
    role: 'user',
    department: 'فناوری اطلاعات'
  }
];

async function setupUsers() {
  console.log('🚀 شروع ایجاد کاربران نمونه...\n');

  for (const userData of users) {
    try {
      console.log(`📝 در حال ایجاد کاربر: ${userData.username}`);

      const { data: authData, error: authError } = await supabase.auth.admin.createUser({
        email: userData.email,
        password: userData.password,
        email_confirm: true,
        user_metadata: {
          full_name: userData.full_name
        }
      });

      if (authError) {
        console.error(`❌ خطا در ایجاد کاربر ${userData.username}:`, authError.message);
        continue;
      }

      console.log(`✅ کاربر Auth ایجاد شد با ID: ${authData.user.id}`);

      const { error: insertError } = await supabase
        .from('users')
        .insert({
          id: authData.user.id,
          email: userData.email,
          username: userData.username,
          full_name: userData.full_name,
          role: userData.role,
          department: userData.department,
          is_active: true
        });

      if (insertError) {
        console.error(`❌ خطا در ثبت اطلاعات کاربر ${userData.username}:`, insertError.message);
      } else {
        console.log(`✅ اطلاعات کاربر ${userData.username} در دیتابیس ثبت شد\n`);
      }

    } catch (error) {
      console.error(`❌ خطای غیرمنتظره برای کاربر ${userData.username}:`, error);
    }
  }

  console.log('\n🎉 فرآیند ایجاد کاربران تکمیل شد!');
  console.log('\n📋 اطلاعات ورود:');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  users.forEach(user => {
    console.log(`\n👤 ${user.full_name} (${user.role === 'admin' ? 'مدیر سیستم' : 'کاربر عادی'})`);
    console.log(`   نام کاربری: ${user.username}`);
    console.log(`   رمز عبور: ${user.password}`);
  });
  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
}

setupUsers().catch(console.error);
