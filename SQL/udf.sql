DROP FUNCTION zmWHIndSymbol

CREATE FUNCTION [dbo].[zmWHIndSymbol] (@CustomerCode varchar(30), @ItemCode varchar(30))
RETURNS @Result TABLE
(
ex_ItemCodeID int,
ex_ArtCode nvarchar(30),
ex_ExtraItemDesc nvarchar(25),
ex_Description nvarchar(160),
ex_ExDescCode nvarchar(2),
ex_CmpCode nvarchar(20),
ex_RecordNum int
)
AS
BEGIN
INSERT @Result
		SELECT Items.ID AS ex_ItemCodeID, LTRIM(RTRIM(artext.artcode)) AS eX_ItemCode, (artoms.ex_artcode + ' - ' + ISNULL(artoms.oms20_0,'')) AS ExtraItemDesc, 
		REPLACE(REPLACE(artext.tekst, CHAR(13) + CHAR(10), ' '), CHAR(13), ' ') AS Description, 
		artoms.ex_artcode AS Ex_DescCode, LTRIM(RTRIM(cicmpy.cmp_code)) AS ex_CustomerCode, artext.ID AS RecordNum 
		FROM artext LEFT JOIN Items ON Items.ItemCode = artext.artcode  AND Items.ItemCode IS NOT NULL AND artext.artcode IS NOT NULL  
		JOIN artoms ON artext.ex_artcode = artoms.ex_artcode 
		JOIN cicmpy ON artoms.ex_artcode = cicmpy.ItemCode
		WHERE artext.artcode = @ItemCode AND LTRIM(RTRIM(cicmpy.cmp_code)) =  @CustomerCode
		order by artcode
RETURN
END

exec zmWHIndSymbol

select fun.ex_ItemCodeID, fun.ex_CmpCode, fun.ex_ArtCode, fun.ex_ExtraItemDesc, fun.ex_Description, fun.ex_ExDescCode
from [dbo].[zmWHIndSymbol] ('101003', '200720') fun