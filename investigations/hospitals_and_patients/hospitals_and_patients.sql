


SELECT
"corr_avgquality_surveymean" AS pair,
ROUND(CORR(h.avg_score, s.mean_survey_score),4) AS CORRELATION,
"corr_avgquality_ovall_survey" AS pair,
ROUND(CORR(h.avg_score, s.overall_rating_of_hospital_performance_rate),4) AS CORRELATION,
"corr_procvar_surveymean" AS pair,
ROUND(CORR(h.std_norm_score, s.mean_survey_score),4) AS CORRELATION,
"corr_procvar_ovall_survey" AS pair,
ROUND(CORR(h.std_norm_score, s.overall_rating_of_hospital_performance_rate),4) AS CORRELATION

FROM hospitals_tfm h
INNER JOIN 
surveys_responses_tfm s
ON h.provider_id = s.provider_id;

