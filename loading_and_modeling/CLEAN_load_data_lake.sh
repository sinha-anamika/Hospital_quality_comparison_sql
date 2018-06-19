



 
#!/bin/bash

# save my current directory
MY_CWD=($pwd)

#remove staging directories
rm ~/staging/exercise_1/*

rmdir ~/staging/exercise_1
rmdir ~/staging


#file names

NEW_FILE="hospitals.csv"

NEW_FILE_1="measures.csv"

NEW_FILE_2="effective_care.csv"

NEW_FILE_3="readmissions.csv"

NEW_FILE_4="surveys_responses.csv"

##remove files from hdfs
hdfs dfs -rm /user/w205/hospital_compare/hospitals/$NEW_FILE

hdfs dfs -rm /user/w205/hospital_compare/measures/$NEW_FILE_1

hdfs dfs -rm /user/w205/hospital_compare/effective_care/$NEW_FILE_2

hdfs dfs -rm /user/w205/hospital_compare/readmissions/$NEW_FILE_3

hdfs dfs -rm /user/w205/hospital_compare/surveys_responses/$NEW_FILE_4

#remove  hdfs

hdfs dfs -rmdir /user/w205/hospital_compare/hospitals
hdfs dfs -rmdir /user/w205/hospital_compare/measures
hdfs dfs -rmdir /user/w205/hospital_compare/effective_care
hdfs dfs -rmdir /user/w205/hospital_compare/readmissions
hdfs dfs -rmdir /user/w205/hospital_compare/surveys_responses

hdfs dfs -rmdir /user/w205/hospital_compare


#change dir back to original 
cd $MY_CWD

exit 
