/*
  # اضافه کردن متادیتا به جدول اسناد

  ## تغییرات

  ### 1. documents table
  - اضافه کردن ستون `metadata` (jsonb) برای ذخیره متادیتای اسناد
  
  ## جزئیات
  - متادیتا شامل: نویسنده، موضوع، کلمات کلیدی، زبان، تاریخ سند، تاریخ انقضا، سطح محرمانگی
  - از نوع jsonb برای انعطاف‌پذیری و امکان افزودن فیلدهای سفارشی
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'documents' AND column_name = 'metadata'
  ) THEN
    ALTER TABLE documents ADD COLUMN metadata jsonb DEFAULT '{}'::jsonb;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_documents_metadata ON documents USING gin(metadata);