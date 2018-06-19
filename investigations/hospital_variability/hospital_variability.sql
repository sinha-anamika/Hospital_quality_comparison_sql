


SELECT
h.measure_id,
h.measure_name,
h.proc_std_dev,
h.num_hospitals
FROM 
(SELECT
  ps.measure_id,
  measure_name,
  round(stddev(norm_score), 4)  as proc_std_dev,
  sum(if(score is not null, 1, 0)) as num_hospitals
  FROM procedures_tfm ps
  inner JOIN MEASURES_TFM m
  ON ps.measure_id = m.measure_id
  GROUP BY ps.measure_id,
	   measure_name) h
--where h.num_hospitals   > 360 
  
ORDER BY proc_std_dev DESC
limit 10;
