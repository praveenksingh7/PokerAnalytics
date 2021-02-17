USE master;
GO
IF DB_ID (N'PokerAnalytics') IS NULL
CREATE DATABASE PokerAnalytics;
GO

USE PokerAnalytics;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas where name = 'batch')
EXEC ('CREATE SCHEMA batch');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas where name = 'cosmos')
EXEC ('CREATE SCHEMA cosmos');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas where name = 'pbi')
EXEC ('CREATE SCHEMA pbi');
GO





