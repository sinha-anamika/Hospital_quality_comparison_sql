



select
state,
round(avg(avg_score),4),
round(percentile_approx(med_score, 0.5),4),
round(percentile_approx(std_weight_score, 0.5),4),
round(percentile_approx(rank_med_score, 0.5)  +
percentile_approx(rank_std_score, 0.5))  as ranking
from hospitals_tfm
where num_high_priority_procs > 8
and num_low_priority_procs > 8
group by state
order by ranking
limit 10;
