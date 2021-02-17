# PokerAnalytics


Basic Environment Setup
1. Navigate to https://aka.ms/PokerAnalytics
1. Clone Repo localy (assumes you have github.  As an alterantive you could download the repo as a zip)
1. Create Synapse Workspace
1. Create Spark Pool with default settings
1. Copy Data folder from repo into root of default storage

Order of Execution
1. queryRawJson.sql - shows how serverless sql can query a gzipped json file, and the basics of parsing the file in servereless sql.
1. 0 - Master.sql - shows how to query a series of files and do post processing to add schema in serverless sql.
1. 1 - CreateDatabase - sets up the basic database and schemas for serverles sql endpoint
1. 2 - Create Batch Views - creates sql serverless views on source files for easier repeatable queries
    Note:  is this right, or should we be doing this off the data turned into parquet from the spark notebooks?  is this step necessary?
1. 3 - Create cosmos views -
1. 4 - CREATE gamedetails - this reads the raw json files and builds a couple parquet tables in the spark database 
1. 5 - createPlayerGameSummary - this takes the raw gamedetails data from the spark db and creates additional spark parquet tables for playerGameSummary
1. 6 - Poker Player Segmentation - this takes the player data and scores player behavior to classify users.
1. 7 - Power BI Data Model - this creates views in the serverless sql database over the processed spark data for consumption in Power BI.
