



select
provider_id,
hospital_name,
city,
state,
avg_score,
agg_score,
std_weight_score,
(rank_med_score + rank_std_score) as ranking
from hospitals_tfm
where num_high_priority_procs > 8
and num_low_priority_procs > 8
and med_score is not null
and std_weight_score is not null
order by ranking
limit 10;
