CREATE PROCEDURE [dbo].[_KINIData] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT RTRIM(LTRIM(s.faknr)) COLLATE Hungarian_Technical_100_CS_AS AS Invoice_Number,
	   convert(varchar,k.fakdat,3) AS Invoice_Date, 
	   RTRIM(LTRIM(c1.ClassificationId)) COLLATE Hungarian_Technical_100_CS_AS AS Area, 
	   RTRIM(LTRIM(h.fullname)) COLLATE Hungarian_Technical_100_CS_AS AS Agent,
     RTRIM(LTRIM(k.fakdebnr)) COLLATE Hungarian_Technical_100_CS_AS AS Bill_To_Number,
	   RTRIM(LTRIM(c1.cmp_name))+ ' '+  RTRIM(LTRIM(CAST(ISNULL(c1.cmp_fadd1, '') AS varchar))) COLLATE Hungarian_Technical_100_CS_AS AS Bill_To_Name,
     RTRIM(LTRIM(k.orddeb)) COLLATE Hungarian_Technical_100_CS_AS AS Ship_To_Number,
	   RTRIM(LTRIM(c2.cmp_name))+ ' '+  RTRIM(LTRIM(CAST(ISNULL(c2.cmp_fadd1, '') AS varchar))) COLLATE Hungarian_Technical_100_CS_AS AS Ship_To_Name,
     RTRIM(LTRIM(s.artcode)) COLLATE Hungarian_Technical_100_CS_AS AS SKU,
     RTRIM(LTRIM(i.Description))+ ' '+  RTRIM(LTRIM(CAST(ISNULL(i.UserField_01, '') AS varchar))) COLLATE Hungarian_Technical_100_CS_AS AS SKU_Description,
	   RTRIM(LTRIM(s.unitcode)) COLLATE Hungarian_Technical_100_CS_AS AS InvUom, 
	   cast(s.esr_aantal as decimal(18,6)) AS InvQuantity_Shipped, 
	   cast(s.prijs_n as decimal(18,6)) AS InvSales_Price,
	   cast (s.bdr_ev_ed_val as decimal(18,6)) AS Sales_Value, k.valcode COLLATE Hungarian_Technical_100_CS_AS AS Currency, 
           CASE LTRIM(RTRIM(ISNULL(i.UserField_03,'-'))) WHEN '-' THEN (CASE s.unitcode WHEN 'szt' THEN 'pcs' ELSE LTRIM(RTRIM(s.unitcode)) END) 
		   WHEN 'tys' THEN '1000pcs' 
		   WHEN 'szt' THEN 'pcs' 
		   WHEN 'tys.m2' THEN '1000m2' 
		   WHEN 'rol' THEN 'rolls' 
		   WHEN 'tys.m3' THEN '1000m3'  
		   when 'opk' then 'pkg' 
		   when 'mb' then 'm' 
		   when 'krt' then 'crt' 
		   ELSE LTRIM(RTRIM(i.UserField_03)) END COLLATE Hungarian_Technical_100_CS_AS AS PPEUOM, 
           cast(s.esr_aantal*REPLACE(i.UserField_07,',','.') as decimal(18,6)) AS PPEQuantity_Shipped, 'Hungary' AS Company,
           CASE ISNULL(c1.cmp_fctry,'HU') WHEN '' THEN 'HU' ELSE ISNULL(c1.cmp_fctry,'HU') END COLLATE Hungarian_Technical_100_CS_AS AS Bill_to_Country,
           CASE ISNULL(c2.cmp_fctry,'HU') WHEN '' THEN 'HU' ELSE ISNULL(c2.cmp_fctry,'HU') END COLLATE Hungarian_Technical_100_CS_AS AS Ship_to_Country,
		   REPLACE(s.esr_aantal,',','.') AS test1,
		   REPLACE(i.UserField_07,',','.') AS test2
FROM      dbo.frhsrg s INNER JOIN
          dbo.frhkrg k ON s.faknr = k.faknr AND s.fakdat = k.fakdat INNER JOIN
          dbo.Items i ON s.artcode = i.ItemCode INNER JOIN
          dbo.cicmpy c1 ON k.fakdebnr = c1.debnr INNER JOIN
          dbo.cicmpy c2 ON k.orddeb = c2.debnr INNER JOIN
          dbo.humres h ON c1.cmp_acc_man = h.res_id
WHERE      (s.ar_soort <> 'P') AND (k.fak_soort <> 'Z') AND
           CONVERT(varchar,Year(s.fakdat))+RIGHT('0'+CONVERT(varchar,Month(s.fakdat)),2)+RIGHT('0'+CONVERT(varchar,Day(s.fakdat)),2) >= '20070101' and i.class_01<>0 
				   and i.UserField_07 IS NOT NULL 
