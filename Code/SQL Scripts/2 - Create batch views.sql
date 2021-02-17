USE    PokerAnalytics;
GO

--drop external data source sqlondemanddemo
DROP VIEW IF EXISTS batch.RawData;
GO

CREATE VIEW batch.RawData
AS 
SELECT
    *
FROM
    OPENROWSET(
        BULK 'https://<storageacct>.dfs.core.windows.net/default/JSON/*/*/*/*.json.gz',
        FORMAT = 'CSV',
        FIELDQUOTE = '0x0b',
        FIELDTERMINATOR ='0x0b',
        DATA_COMPRESSION = 'GZIP'
    )
    WITH (
        jsonContent varchar(max) 
    ) AS [r];
GO


DROP VIEW IF EXISTS batch.GameDetails ;
GO

CREATE VIEW batch.GameDetails (GameId, TableName, GameTime, GameActionId, Player, StreetName, Action, Amount, StreetSort) 
AS 
WITH L1 AS (
    select  json_value(rd.jsoncontent, '$.id') GameId
            , json_value(rd.jsoncontent, '$.tablename') TableName
            , json_value(rd.jsoncontent, '$.timestamp') as GameTime--, j1.*
            , json_query(rd.jsoncontent, '$.actions') as actions
    from batch.RawData rd
), L2 AS (
select cast(L1.GameId as bigint) GameId
    , L1.TableName
    , cast(replace(L1.GameTime, ' ET', '') as datetime2) GameTime
    , cast(json_value(j.value, '$.GameActionId') as bigint) GameActionId
    , json_value(j.value, '$.actor') Player
    , json_value(j.value, '$.streetname') StreetName
    , json_value(j.value, '$.action') Action
    , cast(json_value(j.value, '$.amount') as decimal(9,2)) Amount
from L1
CROSS APPLY OPENJSON(L1.actions) j
)
SELECT GameId
        , TableName
        , GameTime
        , GameActionId
        , Player
        , StreetName
        , Action
        , IIF(Action in ( 'win', 'bet_returned', 'rake'), Amount, Amount * -1) as Amount
        , CASE StreetName
            WHEN 'Pre-Flop' THEN 1
            WHEN 'Flop' THEN 2
            WHEN 'Turn' THEN 3
            WHEN 'River' THEN 4
            ELSE 99 END AS StreetSort

FROM L2
;
GO
