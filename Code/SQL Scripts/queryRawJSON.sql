-- This is auto-generated code
WITH S0 AS (
SELECT jsonContent --N'[' + REPLACE(REPLACE(REPLACE(jsonContent, CHAR(13), ''), CHAR(10), ''), '}{', '},{') + ']' as jsonContent
FROM
    OPENROWSET(
        BULK 'https://<storageacct>.dfs.core.windows.net/default/JSON/2019/12/20/Table00015_20191220.json.gz',
        FORMAT = 'CSV',
        FIELDQUOTE = '0x0b',
        FIELDTERMINATOR ='0x0b',
        --ROWTERMINATOR = '0x0b',
        DATA_COMPRESSION = 'GZIP'
    )
    WITH (
        jsonContent varchar(MAX)
    ) AS [result]
) , S1 AS (
select J1.Value as jsonContent
from S0
cross APPLY OPENJSON(S0.jsonContent) J1
), L1 AS (
    select  json_value(rd.jsoncontent, '$.id') GameId
            , json_value(rd.jsoncontent, '$.tablename') TableName
            , json_value(rd.jsoncontent, '$.timestamp') as GameTime--, j1.*
            , json_query(rd.jsoncontent, '$.actions') as actions
            , json_value(rd.jsoncontent, '$.board') as board
    from S1 rd
) --select * from L1
, L2 AS (
select --cast(L1.GameId as bigint) GameId
    L1.GameId
    , L1.TableName
    , cast(replace(L1.GameTime, ' ET', '') as datetime2) GameTime
    , cast(json_value(j.value, '$.GameActionId') as bigint) GameActionId
    , json_value(j.value, '$.actor') Player
    , json_value(j.value, '$.streetname') StreetName
    , json_value(j.value, '$.action') Action
    , cast(json_value(j.value, '$.amount') as decimal(9,2)) Amount
    , L1.board
    , json_value(j.value, '$.cards') as Cards
from L1
CROSS APPLY OPENJSON(L1.actions) j
) --select * from L2
, D1 AS (
SELECT GameId
        , TableName
        , GameTime
        , GameActionId
        , Player
        , StreetName
        , board
        , cards
        , Action
        --, IIF(Action in ( 'win', 'bet_returned', 'rake'), Amount, Amount * -1) as 
        , Amount
        , CASE StreetName
            WHEN 'Pre-Flop' THEN 1
            WHEN 'Flop' THEN 2
            WHEN 'Turn' THEN 3
            WHEN 'River' THEN 4
            ELSE 99 END AS StreetSort

FROM L2
)
select 
--count(distinct gameid) 
gameid, abs(sum(amount))
from d1
--where tablename = 'Table00678' and GameTime = '2019/12/20 19:27:18'
group by gameid
--group by  tablename
order by 2 desc, 1;
