This project involved using data from the government medicare site https://data.medicare.gov/data/hospital-compare to answer following questions about Medicare patients.

	•	What hospitals are models of high-quality care? That is, which hospitals have the most consistently high scores for a variety of procedures. 

	•	What states are models of high-quality care? 

	•	Which procedures have the greatest variability between hospitals? 

	•	Are average scores for hospital quality or procedural variability correlated with patient survey responses? 

 
Steps involved

	•	Figure out the datasets to be used by looking at the data dictionary. Reach out to  medicare contact with any questions.

	•	Transfer data in a HDFS-backed Data Lake, impose that schema in the Hive Metastore, and  design a schema( demonstrate the ER diagram) into which the data will be transformed. 

	•	Transform the raw data into a set of tables as per the ER diagram, using Hive’s SQL interface.

	•	Write sqls to answer the questions. Justify the choices made.


Solution


In order to see the ERD and data load sals, please click on the loading_and_modeling folder https://github.com/sinha-anamika/Hospital_quality_comparison_sql/tree/master/loading_and_modeling.

In order to see the data transformation sals, please click on transforming folder. https://github.com/sinha-anamika/Hospital_quality_comparison_sql/blob/master/transforming/transform.sql

Solution to best hospitals, best States, most variable procedures etc can be found in investigations folder. https://github.com/sinha-anamika/Hospital_quality_comparison_sql/tree/master/investigations

