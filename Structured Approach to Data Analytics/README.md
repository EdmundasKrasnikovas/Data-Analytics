# Structured Approach to Data Analytics Project

# Weekly Heart Rate & Routine Analysis

## ASK 

#### Problem: 
Understanding how physiological stress markers (Resting Heart Rate) fluctuate throughout the standard work week versus the weekend.

#### Problem I want to solve:
•	Identify if work-related routines are negatively impacting recovery.
•	Determine if specific days of the week correlate with heightened physiological stress.

#### Key questions: 
•	Does my heart rate trend upward as the work week progresses?
•	Are workdays noticeably different from weekends in terms of recovery?
•	Is Resting HR a sensitive enough metric to track daily stress?

#### What would qualify as a successful result: 
•	Clear visualization of Heart Rate (HR) trends between Monday–Friday and Saturday–Sunday.
•	Confirmation or rejection of the hypothesis that workdays increase physiological stress.

#### Determining solution:
•	Develop a clear baseline of weekly physiological patterns.
•	Determine if lifestyle adjustments (e.g., sleep, caffeine) are necessary based on data.

## PREPARE

#### Needed data:
•	Daily Resting Heart Rate (HR) values.
•	Date stamps to distinguish Weekday vs. Weekend.

#### Used data source: Apple Health Data from Apple watch

## PROCESS

•	**Data Collection:** Extracted daily average resting HR data from Watch and after Google Sheets where used for accessibility.

•	**Data Protection:** Preserved the original raw dataset and created a separate working copy for manipulation to ensure data integrity.

•	**Data Cleaning:** 
    • Identified and removed rows with missing `Resting_HR` values (null handling) to prevent skewed averages.
    • Standardized numerical precision: Converted values from floats (decimals) to integers/strings where appropriate for clearer visual interpretation.


## ANALYZE

During the analysis, I visualized the daily average Resting Heart Rate (RHR) to identify correlations between the day of the week and physiological stress markers.

**Key Findings:**

•	**Stability over volatility:** Contrary to the initial hypothesis, the data does not confirm any particular trends in the heart rate moving upwards or downwards on the weekend.

•	**Workday vs. Weekend:** The variance between the two categories was minimal. The difference in averages was too small to draw a legitimate conclusion regarding work-induced stress.

•	**Metric limitations:** I considered if "Walking Heart Rate Average" would show more variance. However, preliminary looks suggest those trends are also quite low and stable.

**Conclusion:**
The analysis reveals that my current weekly routine maintains a stable physiological baseline, with no detectable "stress spikes" affecting my resting heart rate. 

Since no negative trends were identified, no immediate intervention is required. The data suggests that my current lifestyle maintains a healthy balance between work and recovery. Future iterations of this project would benefit from analyzing **Heart Rate Variability (HRV)** to find more sensitive indicators of daily stress, as Resting HR proved to be a very stable metric.


- **[Link to a Google sheet](https://docs.google.com/spreadsheets/d/1xnzJiogBvNRRpNoCFV0ZH8PtnqX_Xi7lWEumen5bvLY/edit?gid=506607108#gid=506607108)** 
