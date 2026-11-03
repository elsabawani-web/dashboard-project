USE [db_inventory_daily]
GO

/****** Object:  View [dbo].[vw_inventory_movement]    Script Date: 03/11/2026 17:57:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vw_inventory_movement] AS

SELECT

    S.MATNR AS ProductCode,

    SUM(
        CASE
            WHEN S.BWART = 101
            THEN TRY_CAST(S.MENGE AS FLOAT)
            ELSE 0
        END
    ) AS StockIn,

    SUM(
        CASE
            WHEN S.BWART = 201
            THEN TRY_CAST(S.MENGE AS FLOAT)
            ELSE 0
        END
    ) AS StockOut

FROM dbo.MSEG$ S

GROUP BY
    S.MATNR
GO


