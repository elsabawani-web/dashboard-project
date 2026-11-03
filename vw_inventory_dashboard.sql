USE [db_inventory_daily]
GO

/****** Object:  View [dbo].[vw_inventory_dashboard]    Script Date: 03/11/2026 17:45:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






ALTER VIEW [dbo].[vw_inventory_dashboard] AS

SELECT
    M.MATNR,
    M.WERKS,
    M.LGORT,
    M.LABST,

    MA.MAKTX AS ProductName,

    MR.MATKL AS Category,

  T.LGOBE AS WarehouseName,

  MV.PostingDate,
--PD.PostingDate,

ISNULL(MV.StockIn,0) AS StockIn,

ISNULL(MV.StockOut,0) AS StockOut,

    CASE
        WHEN M.LABST = 0 THEN 'Out of Stock'
        WHEN M.LABST <= 10 THEN 'Low Stock'
        WHEN M.LABST >= 500 THEN 'Overstock'
        ELSE 'Normal'
    END AS StockStatus,

    CASE
    WHEN M.LABST >= 500 THEN 'A'
    WHEN M.LABST >= 11 THEN 'B'
    ELSE 'C'
END AS ABCClass,

    CASE
        WHEN M.LABST = 0 THEN 'High'
        WHEN M.LABST <= 10 THEN 'Medium'
        ELSE 'Low'
    END AS Priority,

    CASE
        WHEN M.LABST < 50 THEN 50 - M.LABST
        ELSE 0
    END AS SuggestedOrderQty

FROM dbo.MARD$ M

LEFT JOIN dbo.MAKT$ MA
    ON M.MATNR = MA.MATNR

LEFT JOIN dbo.MARA$ MR
    ON M.MATNR = MR.MATNR

LEFT JOIN dbo.T001L$ T
    ON M.LGORT = T.LGORT
--   LEFT JOIN
--(
--    SELECT
--        S.MATNR,
--        MAX(K.BUDAT) AS PostingDate
--    FROM MSEG$ S
--    LEFT JOIN MKPF$ K
--        ON S.MBLNR = K.MBLNR
--    GROUP BY S.MATNR
--) PD
--    ON M.MATNR = PD.MATNR
--    LEFT JOIN
--(
--    SELECT
--        MATNR,

--        SUM(
--            CASE
--                WHEN BWART = 101
--                THEN TRY_CAST(MENGE AS FLOAT)
--                ELSE 0
--            END
--        ) AS StockIn,

--        SUM(
--            CASE
--                WHEN BWART = 201
--                THEN TRY_CAST(MENGE AS FLOAT)
--                ELSE 0
--            END
--        ) AS StockOut

--    FROM dbo.MSEG$

--    GROUP BY MATNR

--) MV
--    ON M.MATNR = MV.MATNR

LEFT JOIN
(
    SELECT
        S.MATNR,

        MAX(CAST(K.BUDAT AS BIGINT)) AS PostingDate,

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

    LEFT JOIN dbo.MKPF$ K
        ON S.MBLNR = K.MBLNR

    GROUP BY
        S.MATNR

) MV
ON M.MATNR = MV.MATNR
GO


