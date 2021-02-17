USE    PokerAnalytics;
GO;
/****** CREATE Main fact table ********/
--this will eventually contain UNION with cosmos data
DROP VIEW IF EXISTS pbi.GameDetails
GO;
CREATE VIEW pbi.gameDetails 
AS
select GameId
        , TableName as tableName
        , cast(replace(GameTime, ' ET', '') as datetime2) as gameTime
        , GameActionId as gameActionId
        , Player as player
        , Streetname as streetName
        , Action as action
        , Amount as amount
FROM [pokerdata].dbo.gamedetails
GO;


/****** CREATE Main dim tables ******/
--this will probably be unnecessary since we can just use player summary table create below
DROP VIEW IF EXISTS pbi.players
GO;
CREATE VIEW pbi.players
AS
select player, playertype, labels
FROM [pokerdata].dbo.playersummary
GO;


DROP VIEW IF EXISTS pbi.games
GO;
CREATE VIEW pbi.games
AS
select DISTINCT GameId, TableName
FROM [pokerdata].dbo.gamedetails
GO;

/********* CREATE SUMMARY TABLES ******/
DROP VIEW IF EXISTS pbi.playerGameSummary
GO;
CREATE VIEW pbi.playerGameSummary
AS
SELECT player, gameId, gameDate, vpipCt, pfrCt, gameCt, profit
FROM [pokerdata].dbo.playergamesummary
GO;

DROP VIEW IF EXISTS pbi.playerSummary
GO;
CREATE VIEW pbi.playerSummary
AS
SELECT [player]
,[VPIP_Ct]
,[PFR_Ct]
,[Game_Ct]
,[Winnings]
,[WinningsPer100]
,[PFR]
,[VP$IP]
,[pfr_rate]
FROM [pokerdata].dbo.playersummary
GO;


DROP VIEW IF EXISTS pbi.dailyGameStats
GO;
CREATE VIEW pbi.dailyGameStats
AS
SELECT  gameCt
        ,1 as playerCt
        ,pgs.player
        ,gameDate
        ,profit
FROM pbi.playerGameSummary pgs
GO;


