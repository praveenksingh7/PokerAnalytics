USE    PokerAnalytics;
GO

DROP VIEW IF EXISTS cosmos.RawData;
GO

CREATE VIEW cosmos.RawData
AS 
SELECT  *
FROM OPENROWSET( 
    'CosmosDB',
    'account=<cosmosdbacct>;database=Data;region=eastus;key=<key value>',
    <container>)
    WITH ( id char(20),
            timestamp char(30),
            tablename char(50),
           actions varchar(max)
    ) AS docs;
GO

DROP VIEW IF EXISTS cosmos.GameDetails ;
GO

CREATE VIEW cosmos.GameDetails (GameId, TableName, GameTime, GameActionId, Player, StreetName, Action, Amount, StreetSort) 
AS 
WITH L1 AS (
    select  [id] as GameId
            , TableName
            , [TimeStamp] as GameTime
            , JSON_Value(j1.value, '$.GameActionId') as GameActionId
            , json_value(j1.value, '$.actor') Player
            , json_value(j1.value, '$.streetname') StreetName
            , json_value(j1.value, '$.action') Action
            , cast(json_value(j1.value, '$.amount') as decimal(9,2)) Amount
    from cosmos.RawData rd
    CROSS APPLY OPENJSON(rd.actions) j1
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

FROM L1
;
GO

DROP VIEW IF EXISTS cosmos.PreFlop_Summary ;
GO

CREATE VIEW cosmos.PreFlop_Summary (Player, VPIP_Ct, PFR_Ct, Game_Ct) 
AS 
SELECT Player
    , sum(vpip_ct) VPIP_Ct
    , sum(PFR_CT) PFR_Ct
    , sum(Game_Ct) Game_Ct
FROM (
    SELECT Player
            , GameId
            , MAX(
                    CASE WHEN action = 'bet' THEN 1
                        WHEN action = 'raise' THEN 1
                        WHEN action = 'call' THEN 1
                        ELSE 0 END
                )  AS VPIP_CT
            , MAX(
                    IIF(action = 'raise', 1, 0)
            ) AS PFR_CT
            , COUNT(Distinct GameId) Game_Ct
    FROM cosmos.GameDetails gameDetails
    WHERE Streetname = 'Pre-Flop'
    GROUP BY Player
            , GameId
) t GROUP BY player;
GO



    