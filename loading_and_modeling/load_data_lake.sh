


#!/bin/bash

# save my current directory
MY_CWD=($pwd)

#creating staging directories
mkdir ~/staging
mkdir ~/staging/exercise_1

#change to staging/exerice_1 directory
cd ~/staging/exercise_1

#get file from data.medicare.gov
MY_URL="https://data.medicare.gov/views/bg9k-emty/files/4a66c672-a92a-4ced-82a2-033c28581a90?content_type=application%2Fzip%3B%20charset%3Dbinary&filename=Hospital_Revised_Flatfiles.zip"
wget "$MY_URL" -O medicare_data.zip

#unzip the medicare data
unzip  medicare_data.zip

#remove first line of file and rename
OLD_FILE="Hospital General Information.csv"
NEW_FILE="hospitals.csv"


OLD_FILE_1="Measure Dates.csv"
NEW_FILE_1="measures.csv"

OLD_FILE_2="Timely and Effective Care - Hospital.csv" 
NEW_FILE_2="effective_care.csv"

OLD_FILE_3="Complications and Deaths - Hospital.csv"
NEW_FILE_3="readmissions.csv"

OLD_FILE_4="hvbp_hcahps_11_10_2016.csv"
NEW_FILE_4="surveys_responses.csv"

tail -n +2 "$OLD_FILE" >"$NEW_FILE"

tail -n +2 "$OLD_FILE_1" >"$NEW_FILE_1"

tail -n +2 "$OLD_FILE_2" >"$NEW_FILE_2"

tail -n +2 "$OLD_FILE_3" >"$NEW_FILE_3"

tail -n +2 "$OLD_FILE_4" >"$NEW_FILE_4"


#create our hdfs directory
hdfs dfs -mkdir /user/w205/hospital_compare

#copy all  5 files to hdfs
hdfs dfs -mkdir /user/w205/hospital_compare/hospitals

hdfs dfs -put "$NEW_FILE" /user/w205/hospital_compare/hospitals

hdfs dfs -mkdir /user/w205/hospital_compare/measures

hdfs dfs -put "$NEW_FILE_1" /user/w205/hospital_compare/measures

hdfs dfs -mkdir /user/w205/hospital_compare/effective_care


hdfs dfs -put "$NEW_FILE_2" /user/w205/hospital_compare/effective_care

hdfs dfs -mkdir /user/w205/hospital_compare/readmissions

hdfs dfs -put "$NEW_FILE_3" /user/w205/hospital_compare/readmissions

hdfs dfs -mkdir /user/w205/hospital_compare/surveys_responses

hdfs dfs -put "$NEW_FILE_4" /user/w205/hospital_compare/surveys_responses

#change dir back to original 
cd $MY_CWD

exit 
