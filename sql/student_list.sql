SELECT b.spriden_id AS advisor_banner_id,
       b.spriden_first_name || ', ' || b.spriden_last_name AS advisor_full_name,
       c.spriden_id AS student_banner_id,
       c.spriden_first_name || ', ' || c.spriden_last_name AS student_full_name,
       CASE
          WHEN e.stvcoll_desc = 'Coll of Sci, Engr & Tech' THEN 'CSET'
          WHEN e.stvcoll_desc = 'Technologies' THEN 'CSET'
          WHEN e.stvcoll_desc = 'Mathematics' THEN 'CSET'
          WHEN e.stvcoll_desc = 'Computer Information Tech' THEN 'CSET'
          WHEN e.stvcoll_desc = '* Natural Sciences' THEN 'CSET'
          WHEN e.stvcoll_desc = 'College of Business' THEN 'COB'
          WHEN e.stvcoll_desc = 'College of Health Sciences' THEN 'COHS'
          WHEN e.stvcoll_desc = 'Humanities & Social Sciences' THEN 'CHASS'
          WHEN e.stvcoll_desc = 'Coll of Humanities/Soc Sci' THEN 'CHASS'
          WHEN e.stvcoll_desc = 'History/Political Science' THEN 'CHASS'
          WHEN e.stvcoll_desc = 'College of the Arts' THEN 'COA'
          WHEN e.stvcoll_desc = '*Education/Family Studies/PE' THEN 'COE'
          WHEN e.stvcoll_desc = 'College of Education' THEN 'COE'
          WHEN e.stvcoll_desc = 'General Education' THEN 'GE'
          ELSE e.stvcoll_desc
       END AS student_college,
       f.stvmajr_desc AS student_major,
       g.smrprle_program_desc AS student_program
FROM saturn.sgradvr a
-- gather general advisor info
LEFT JOIN saturn.spriden b
       ON b.spriden_pidm = a.sgradvr_advr_pidm
      AND b.spriden_change_ind IS NULL
-- gather general student info
LEFT JOIN saturn.spriden c
       ON c.spriden_pidm = a.sgradvr_pidm
      AND c.spriden_change_ind IS NULL
-- collect base student academic info
LEFT JOIN saturn.sgbstdn d
       ON d.sgbstdn_pidm = a.sgradvr_pidm
      -- only grab most recent term code record from the student base table
      AND d.sgbstdn_term_code_eff =  (SELECT MAX(d1.sgbstdn_term_code_eff)
                                      FROM saturn.sgbstdn d1
                                      WHERE d1.sgbstdn_pidm = d.sgbstdn_pidm)
LEFT JOIN saturn.stvcoll e
       ON d.sgbstdn_coll_code_1 = e.stvcoll_code
LEFT JOIN saturn.stvmajr f
       ON d.sgbstdn_majr_code_1 = f.stvmajr_code
LEFT JOIN saturn.smrprle g
       ON d.sgbstdn_program_1 = g.smrprle_program
-- only grab info for the primary advisor
WHERE a.sgradvr_prim_ind = 'Y'
-- make sure advisor assignment is the most recent
AND a.sgradvr_term_code_eff = (SELECT MAX( a1.sgradvr_term_code_eff )
                                  FROM saturn.sgradvr a1
                                  WHERE a1.sgradvr_pidm = a.sgradvr_pidm)
-- only include record from active students
AND d.sgbstdn_stst_code = 'AS'