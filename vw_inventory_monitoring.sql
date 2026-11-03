USE [db_inventory_daily]
GO

/****** Object:  View [dbo].[vw_inventory_monitoring]    Script Date: 03/11/2026 17:56:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vw_inventory_monitoring]
AS

SELECT

    MV.PostingDate,

    M.MATNR AS ProductCode,

    MA.MAKTX AS ProductName,

    MR.MATKL AS Category,

    T.LGOBE AS Warehouse,

    TRY_CAST(REPLACE(M.LABST, ',', '.') AS FLOAT) AS CurrentStock,

    CASE
        WHEN TRY_CAST(REPLACE(M.LABST, ',', '.') AS FLOAT) = 0
            THEN 'Out of Stock'

        WHEN TRY_CAST(REPLACE(M.LABST, ',', '.') AS FLOAT) <= 10
            THEN 'Low Stock'

        WHEN TRY_CAST(REPLACE(M.LABST, ',', '.') AS FLOAT) >= 500
            THEN 'Overstock'

        ELSE 'Normal'
    END AS StockStatus,

    CASE
        WHEN TRY_CAST(REPLACE(M.LABST, ',', '.') AS FLOAT) = 0
            THEN 'High'

        WHEN TRY_CAST(REPLACE(M.LABST, ',', '.') AS FLOAT) <= 10
            THEN 'Medium'

        ELSE 'Low'
    END AS Priority

FROM dbo.MARD$ M

LEFT JOIN dbo.MAKT$ MA
    ON M.MATNR = MA.MATNR

LEFT JOIN dbo.MARA$ MR
    ON M.MATNR = MR.MATNR

LEFT JOIN dbo.T001L$ T
    ON M.LGORT = T.LGORT

LEFT JOIN
(
    SELECT
        S.MATNR,
        MAX(CAST(K.BUDAT AS BIGINT)) AS PostingDate
    FROM dbo.MSEG$ S
    LEFT JOIN dbo.MKPF$ K
        ON S.MBLNR = K.MBLNR
    GROUP BY S.MATNR
) MV
    ON M.MATNR = MV.MATNR;
GO


