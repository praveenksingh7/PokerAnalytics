/*********************************************************

1.) Browse linked data lake:

2.) Right click to auto generate SQL and Spark queries (use \2021\01\01\222076238840000.json)

3.) Create VIEW from Query

4.) Use Synapse Link for Cosmos DB to take advantage of no code data lake stored in parquet for optimized performance

5.) Create federated queries to UNION Cosmos and raw data
*/


-- This is auto-generated code
SELECT TOP 100
    jsonContent
/* --> place the keys that you see in JSON documents in the WITH clause:
       , JSON_VALUE (jsonContent, '$.key1') AS header1
       , JSON_VALUE (jsonContent, '$.key2') AS header2
*/
FROM
    OPENROWSET(
        BULK 'https://<storageacct>.dfs.core.windows.net/default/JSON/*/*/*/*.json.gz',
        FORMAT = 'CSV',
        FIELDQUOTE = '0x0b',
        FIELDTERMINATOR ='0x0b',
        --ROWTERMINATOR = '0x0b',
        DATA_COMPRESSION = 'GZIP'
    )
    WITH (
        jsonContent varchar(MAX)
    ) AS [result]