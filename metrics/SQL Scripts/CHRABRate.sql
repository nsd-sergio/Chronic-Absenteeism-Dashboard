;WITH StudentADA
AS (SELECT DISTINCT
           caaf.StudentKey,
           (COUNT(1) OVER (PARTITION BY caaf.StudentKey, caaf.SchoolKey, dd.SchoolYear)
            - SUM(caaf.ReportedAsAbsentFromSchool) OVER (PARTITION BY caaf.StudentKey, caaf.SchoolKey, dd.SchoolYear)
           )
           / CAST(COUNT(1) OVER (PARTITION BY caaf.StudentKey, caaf.SchoolKey, dd.SchoolYear) AS DECIMAL) AS ADA
    FROM analytics.chrab_ChronicAbsenteeismAttendanceFact caaf
        INNER JOIN analytics.DateDim dd
            ON caaf.DateKey = dd.DateKey
        INNER JOIN analytics.SchoolDim sd
            ON caaf.SchoolKey = sd.SchoolKey),
      chrabStudents
AS (SELECT StudentKey,
           CASE
               WHEN ADA <= 0.9 THEN
                   1
               ELSE
                   0
           END AS IsCHRAB
    FROM StudentADA)
SELECT SUM([IsCHRAB]) / CAST(COUNT([StudentKey]) AS DECIMAL) AS CHRABRate
FROM chrabStudents;