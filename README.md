# Layoffs Dataset

This project aims to analyze and visualize global layoffs in the private sector for the years 2020-2023. The data is sourced from the [layoffs_dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022) and has been processed using SQL to create a database for easy management and analysis. The main focus of this project is to explore the trends in layoff during the covid-19 pandemic and the years following that. This project showcases my skills in Tableau and SQL as I go through data cleaning, analysing and visualizing the layoffs dataset.

## Reports

## Table of Contents
- [Data Sources](#data-sources)
- [Tools](#tools)
- [Data Cleaning](#data-cleaning)
- [Data Analysis](#data-analysis)
- [Visualizations](#visualizations)
- [Limitations/Assumptions](#limitations/assumptions)

### Data Sources
The layoffs dataset was sourced from https://www.kaggle.com/datasets/swaptr/layoffs-2022. You can find the raw file [layoffs_raw.csv](data)

### Tools
- SQL: For data extraction, transformation, and loading into the database.
- Database Management System: MySQL to host and manage the dataset.
- Programming Languages: SQL for data processing and scripting.

### Data Cleaning
The data cleaning process was performed to prepare the dataset for analysis. At the end of this process, the following checks were performed:
1. Handle NULL entries
2. Remove duplicates
3. Standardise data and remove errors
 
The resulting file [layoffs_cleaned.csv](data/layoffs_cleaned.csv) was then used for analysis and visualization.

### Data Analysis
The project attempted to answer the following questions via data analysis performed using SQL:

- Top 5 Companies with the most layoffs overall
- Top 5 Companies that laid off year-wise.
- Which companies perform layoffs most often
- When do layoffs peak within a year?
- Is there any corolation between number of layoffs in global and that in the US?
- Top 5 industries affected the most globally?
- Industries/Countries with most company ceased operations.
- In which stage of the company had the most lay-offs?

The insights to these questions were derived and displayed in the results section.

### Visualizations
Tableau was used to create some visualizations and 2 dashboards providing useful insights from the layoffs performed globally between 2020-2023.

<img width="680" alt="image" src="https://github.com/m0rningLight/Layoffs--Data-Analysis/assets/155348294/5a9dec7f-fe54-4baa-ac0e-33d90bf339d5">
The above visualization shows the top 5 companies that laid off the most people every year. There is an upwards trend as the years progress with companies laying off more people every subsequent year. This visual only shows the top 5 companies and therefore cannot represent the whole market. 
The visual below confirms the statement made above as it clearly shows an upwards trend in layoffs with time.

<img width="678" alt="image" src="https://github.com/m0rningLight/Layoffs--Data-Analysis/assets/155348294/76419974-ca01-4445-98ff-7475045297b3">


The rest of the visuals created as well as the 2 dashboards can be found in [Layoffs.twbx](results/Layoffs.twbx)

### Limitations/Assumptions
- The layoffs dataset included data spanning from 2020 to 2023. Consequently, we are unable to provide recommendations concerning chronological trends due to the limited timeframe of the data available for this analysis. For future analyses, it is essential to incorporate data on layoffs from at least the past decade to enhance the reliability and robustness of our findings.
- The project analysis was performed with the assumption that companies that had 100% of their staff laid off ceased operations. Hence, our results may be slightly deviated from reality when we discuss the industries and countries were companies have ceased operations.

