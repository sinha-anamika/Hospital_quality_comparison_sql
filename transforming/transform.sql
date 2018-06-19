


DROP TABLE measures_tfm;

CREATE TABLE measures_tfm AS
SELECT
	ms.measure_id measure_id,
	ms.measure_name measure_name,
	CAST (CONCAT(SUBSTR(ms.measure_start_date, 7, 4),
				'-',
				SUBSTR(ms.measure_start_date, 1, 2),
				'-',
				SUBSTR(ms.measure_start_date, 4, 2)
				)
		AS date) AS measure_start_date,
	CAST (CONCAT (SUBSTR(ms.measure_end_date, 7, 4),
				'-',
				SUBSTR(ms.measure_end_date, 1, 2),
				'-',
				SUBSTR(ms.measure_end_date, 4, 2)
				)
		AS date) AS measure_end_date,
            case when d.measure_id in 
		('IMM_2', 'OP_2', 'OP_23', 'OP_29', 'OP_30', 'OP_31', 'OP_4', 
		'STK_4', 'VTE_5') then 'H'	
           	             else 'L'   
		 end as highval_good_ind,
	CAST(CASE	 
		when d.measure_id like '%MORT_%' then 0.6
		when d.measure_id like 'PSI_%' then 0.6
		when d.measure_id like 'COMP_%' then 0.6
		else 0.4  end as decimal(2,1)) measure_weight

FROM measures ms 
INNER JOIN 
(select distinct measure_id from effective_care
  where measure_id <> 'EDV'
union select distinct measure_id from readmissions) d
ON ms.measure_id = d.measure_id

UNION

SELECT
	distinct(ec.measure_id) measure_id,
	ec.measure_name measure_name,
	CAST (CONCAT(SUBSTR(ec.measure_start_date, 7, 4),
				'-',
				SUBSTR(ec.measure_start_date, 1, 2),
				'-',
				SUBSTR(ec.measure_start_date, 4, 2)
				)
		AS date) AS measure_start_date,
	CAST (CONCAT (SUBSTR(ec.measure_end_date, 7, 4),
				'-',
				SUBSTR(ec.measure_end_date, 1, 2),
				'-',
				SUBSTR(ec.measure_end_date, 4, 2)
				)
		AS date) AS measure_end_date,
	CAST ( 'H' as string)  highval_good_ind ,	
	CAST(0.4  as decimal(2,1) ) measure_weight
FROM effective_care ec
WHERE ec.measure_id = 'IMM_3_OP_27_FAC_ADHPCT'
Union


SELECT
	distinct(re.measure_id) measure_id,
	re.measure_name measure_name,
	CAST (CONCAT(SUBSTR(re.measure_start_date, 7, 4),
				'-',
				SUBSTR(re.measure_start_date, 1, 2),
				'-',
				SUBSTR(re.measure_start_date, 4, 2)
				)
		AS date) AS measure_start_date,
	CAST (CONCAT (SUBSTR(re.measure_end_date, 7, 4),
				'-',
				SUBSTR(re.measure_end_date, 1, 2),
				'-',
				SUBSTR(re.measure_end_date, 4, 2)
				)
		AS date) AS measure_end_date,
	CAST ( 'L'   as string)  highval_good_ind ,	
	CAST(0.6  as decimal(1,1) ) measure_weight
FROM readmissions re
WHERE re.measure_id IN ( 'PSI_90_SAFETY', 'PSI_13_POST_SEPSIS',
				'PSI_12_POSTOP_PULMEMB_DVT', 'PSI_15_ACC_LAC',
				'PSI_4_SURG_COMP', 'PSI_3_ULCER', 'PSI_6_IAT_PTX',
                                'PSI_14_POSTOP_DEHIS', 'PSI_7_CVCBI', 'PSI_8_POST_HIP'    )


 ;

---------------------------------------------------------

DROP TABLE effective_care_tfm;

CREATE TABLE effective_care_tfm AS
SELECT
	provider_id,
	measure_id,
	cast(score as decimal(10,6)) score,
	cast(sample as decimal(6,0)) sample
	
FROM effective_care
where measure_id <> 'EDV';

-----------------------------------------------------------

DROP TABLE readmissions_tfm;

CREATE TABLE readmissions_tfm AS
SELECT
	provider_id,
	measure_id,
	case
		when compared_to_national like 'No Different%' then 0
		when compared_to_national like 'Better%' then 1
		when compared_to_national like 'Worse%' then -1
		else null
		end as national_comparison,
	cast(score as decimal(10,6)) score,
	cast(denominator as decimal(5,0)) sample,
	cast(lower_estimate as decimal(3,1)) lower_estimate,
	cast(higher_estimate as decimal(3,1)) higher_estimate
FROM readmissions;

------------------------------------------------------------
--Creating a table procedure_stats_tfm which stores the maximum 
--score for each measure.

DROP TABLE procedure_stats_tfm;

CREATE TABLE procedure_stats_tfm AS
SELECT
	measure_id,
        max(score) as max_score
	
FROM effective_care_tfm 
Group by measure_id

Union 

SELECT
	measure_id,
        max(score) as max_score
FROM readmissions_tfm 
Group by measure_id;


----------------------------------------------------------
---Creating a new entity which is a combination of all data from
---effective_care_tfm and readmissions. It has the score, normalized score
---as well as thw weighted normalized score.


DROP TABLE procedures_tfm;

CREATE TABLE procedures_tfm AS
SELECT
	provider_id,
	ec.measure_id,
	score,
	case when ms.highval_good_ind  = 'L'
		then (1 -(ec.score/ps.max_score))
	else ec.score/ps.max_score
	end as norm_score,
	case when ms.highval_good_ind  = 'L'
                then ms.measure_weight*(1 -(ec.score/ps.max_score))
        else ms.measure_weight*ec.score/ps.max_score
        end as weighted_norm_score

FROM effective_care_tfm ec
INNER JOIN procedure_stats_tfm ps
ON ec.measure_id = ps.measure_id
INNER JOIN measures_tfm ms
ON ec.measure_id = ms.measure_id
 
Union

SELECT
	provider_id,
	re.measure_id,
	score,
	case when ms.highval_good_ind ='L'
		then (1 -(re.score/ps.max_score))
		else re.score/ps.max_score
	end as norm_score,
	case when ms.highval_good_ind  = 'L'
                then ms.measure_weight*(1 -(re.score/ps.max_score))
        	else ms.measure_weight*re.score/ps.max_score
        end as weighted_norm_score

FROM readmissions_tfm re
INNER JOIN procedure_stats_tfm ps
ON re.measure_id = ps.measure_id
INNER JOIN measures_tfm ms
ON re.measure_id = ms.measure_id
;

----------------------------------------------------------------


--Creating  our main entity hospitals_tfm from hospitals
--Also added derived columns like normalized score, weighted normalized score
--and rank values. Got rid of rows with null values for aggregate score.




DROP TABLE hospitals_tfm;

CREATE TABLE hospitals_tfm AS
SELECT
        p.provider_id,
        hospital_name,
        city,
        state,
        p.agg_score,
	p.avg_score,
	p.med_score,
	p.std_weight_score,
        p.std_norm_score,
	p.num_high_priority_procs,
        p.num_low_priority_procs, 
        dense_rank() over (order by p.agg_score desc ) as rank_agg_score,
        dense_rank() over (order by p.avg_score desc ) as rank_avg_score,
        dense_rank() over (order by p.med_score desc ) as rank_med_score,
        dense_rank() over (order by p.std_weight_score asc) as rank_std_score,
        dense_rank() over (order by p.std_norm_score desc ) as rank_std_norm_score,

        case
                when meets_criteria_for_meaningful_use_of_ehrs like 'Y' then 1
                else 0
                end as meets_criteria_for_meaningful_use_of_ehrs,
        cast(hospital_overall_rating as decimal(1,0)) hospital_overall_rating,
        cast(case
                when mortality_national_comparison like 'Same%' then 0
                when mortality_national_comparison like 'Above%' then 1
                when mortality_national_comparison like 'Below%' then -1
                end as decimal(1,0)) mortality_national_comparison,
        case
                when safety_of_care_national_comparison like 'Same%' then 0
                when safety_of_care_national_comparison like 'Above%' then 1
                when safety_of_care_national_comparison like 'Below%' then -1
                end as safety_of_care_national_comparison,
        case
                when readmission_national_comparison like 'Same%' then 0
                when readmission_national_comparison like 'Above%' then 1
                when readmission_national_comparison like 'Below%' then -1
                end as readmission_national_comparison,
        case
                when patient_experience_national_comparison like 'Same%' then 0
                when patient_experience_national_comparison like 'Above%' then 1
                when patient_experience_national_comparison like 'Below%' then -1
                end as patient_experience_national_comparison,
        case
                when effectiveness_of_care_national_comparison like 'Same%' then 0
                when effectiveness_of_care_national_comparison like 'Above%' then 1
                when effectiveness_of_care_national_comparison like 'Below%' then -1
                end as effectiveness_of_care_national_comparison,
        case
                when timeliness_of_care_national_comparison like 'Same%' then 0
                when timeliness_of_care_national_comparison like 'Above%' then 1
                when timeliness_of_care_national_comparison like 'Below%' then -1
                end as timeliness_of_care_national_comparison,
        case
                when efficient_use_of_medical_imaging_national_comparison like 'Same%' then 0
                when efficient_use_of_medical_imaging_national_comparison like 'Above%' then 1
                when efficient_use_of_medical_imaging_national_comparison like 'Below%' then -1
                end as efficient_use_of_medical_imaging_national_comparison
                
FROM hospitals h
INNER JOIN 
  (Select 
  ps.provider_id,
  round(sum(ps.weighted_norm_score), 4)   as agg_score,
  round(avg(ps.weighted_norm_score), 4)   as avg_score,
  round(percentile_approx(ps.weighted_norm_score, 0.5), 4)  as med_score,
  round(stddev(ps.weighted_norm_score), 4)  as std_weight_score,
  round(stddev(ps.norm_score), 4)  as std_norm_score,
  sum(if(m.measure_weight = 0.6  and ps.score is not NULL, 1, 0)) as num_high_priority_procs,
  sum(if(m.measure_weight = 0.4 and ps.score is not NULL, 1, 0))  as num_low_priority_procs 

  from procedures_tfm ps
  inner join measures_tfm m
  on ps.measure_id = m.measure_id
 -- where ps.score is not NULL
  and m.measure_id <> 'EDV'
  group by ps.provider_id) p

ON h.provider_id = p.provider_id
where p.agg_score is not NULL
order by rank_med_score
;



--------------------------------------------------------------------
---Creating entity surveys_responses_tfm from survey responses 
---Removed a lot of fields. Calculated a mean_survey_score by taking means
---of individual score. Removed all scores on scale of 10 and just
--kept raw scores.


DROP TABLE surveys_responses_tfm;

CREATE TABLE surveys_responses_tfm AS
SELECT  
			cast(provider_number as decimal(6,0)) provider_id,
			cast(communication_with_nurses_performance_rate as decimal(4,2))
      communication_with_nurses_performance_rate,
			
			cast(communication_with_doctors_performance_rate as decimal(4,2))
      communication_with_doctors_performance_rate,

      cast(responsiveness_of_hospital_staff_performance_rate as decimal(4,2))
      responsiveness_of_hospital_staff_performance_rate,

      cast(pain_management_performance_rate as decimal(4,2))
      pain_management_performance_rate,

      cast(communication_about_medicines_performance_rate as decimal(4,2)) 
      communication_about_medicines_performance_rate,

      cast(cleanliness_and_quietness_of_hospital_environment_performance_rate as decimal(4,2))
      cleanliness_and_quietness_of_hospital_environment_performance_rate,

      cast(discharge_information_performance_rate as decimal(4,2)) 
      discharge_information_performance_rate,

      cast(overall_rating_of_hospital_performance_rate as decimal(4,2)) 
      overall_rating_of_hospital_performance_rate,


      cast((cast(communication_with_nurses_performance_rate as decimal(4,2)) +
      cast(communication_with_doctors_performance_rate as decimal(4,2)) +
      cast(responsiveness_of_hospital_staff_performance_rate as decimal(4,2)) +
      cast(pain_management_performance_rate as decimal(4,2)) +
      cast(communication_about_medicines_performance_rate as decimal(4,2))  +
      cast(cleanliness_and_quietness_of_hospital_environment_performance_rate as decimal(4,2)) +
      cast(discharge_information_performance_rate as decimal(4,2))) / 7 as decimal(4,2))  
      mean_survey_score 

      FROM    surveys_responses;
      

      

