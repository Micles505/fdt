CREATE OR REPLACE FORCE VIEW FDTV_DIFF_SCPTE_RES_TRAV_SCP_SCP2 AS
SELECT V_DIFF_SCP_SCP2."SCPCH_COD_TRAV",
           V_DIFF_SCP_SCP2."SCPCH_COD_ACT",
           V_DIFF_SCP_SCP2."SCPCH_COD_PROD",
           V_DIFF_SCP_SCP2."SCPCH_AN_PLAN",
           V_DIFF_SCP_SCP2."SCPCH_SIG_SYS",
           V_DIFF_SCP_SCP2."SCPCH_RE_STAT",
           V_DIFF_SCP_SCP2."SCPCH_RE_JP_PR",
           'SCP'     co_systeme
      FROM (SELECT SCPCH_COD_TRAV,
                   SCPCH_COD_ACT,
                   SCPCH_COD_PROD,
                   SCPCH_AN_PLAN,
                   SCPCH_SIG_SYS,
                   SCPCH_RE_STAT,
                   SCPCH_RE_JP_PR
              FROM SCP.SCPTE_RES_TRAV
            MINUS
            SELECT SCPCH_COD_TRAV,
                   SCPCH_COD_ACT,
                   SCPCH_COD_PROD,
                   SCPCH_AN_PLAN,
                   SCPCH_SIG_SYS,
                   SCPCH_RE_STAT,
                   SCPCH_RE_JP_PR
              FROM SCP2.SCPTE_RES_TRAV) V_DIFF_SCP_SCP2
     WHERE V_DIFF_SCP_SCP2.SCPCH_AN_PLAN = '2022-2023';

