-- ============================================
-- FIX: Exams RLS for multi-course enrollments
-- ============================================
-- The original policy checked students.course_id (legacy single-course field).
-- After the multi-course migration, enrollments live in student_courses, and
-- students.course_id is often NULL — so enrolled students could not see exams.
--
-- Run this in the Supabase SQL Editor.

DROP POLICY IF EXISTS "Students can view course exams" ON exams;

CREATE POLICY "Students can view course exams"
  ON exams FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM students s
      JOIN student_courses sc ON sc.student_id = s.id
      WHERE s.user_id = auth.uid()
        AND sc.course_id = exams.course_id
        AND sc.payment_status = 'paid'
    )
  );
