DECLARE @Nar float(8)
DECLARE @AgeQty float(8)
DECLARE @PrevArtcode CHAR(30)
DECLARE @PrevWarehouse CHAR(4)
DECLARE @WartWiekowIlosci float(8)

DECLARE @id INT
DECLARE @artcode CHAR(30)
DECLARE @warehouse CHAR(30)
DECLARE @RecQty float(8)
DECLARE @Stock float(8)
DECLARE @WartoscTransakcji float(8)
DECLARE @CenaJedn float(8)

-- Init
SET @PrevArtcode = ''
SET @PrevWarehouse = ''
SET @Nar = 0
SET @AgeQty = 0
SET @WartWiekowIlosci = 0

DECLARE cum CURSOR FOR 
SELECT ID, Towar, Magazyn,  
IloscOtrzymana, ZapasWmagazynie, WartoscTransakcji, CenaJedn 
FROM #PZ2a

OPEN cum

-- get first row
FETCH NEXT FROM cum
INTO @ID, @artcode, @warehouse, RecQty, @Stock, @WartoscTransakcji, @CenaJedn  

WHILE @@FETCH_STATUS = 0
BEGIN

	-- Business logic - if warehouse or article code has been changed
	IF @PrevArtcode <> @artcode OR @PrevWarehouse <> @warehouse
	BEGIN
		SET @AgeQty = CASE WHEN @RecQty <= @Stock THEN @RecQty ELSE @Stock END 
			         
		SET @WartWiekowIlosci = CASE WHEN @RecQty <= @Stock THEN @WartoscTransakcji ELSE  
        	CASE WHEN @Stock - @RecQty < 0 THEN  @Stock * @CenaJedn ELSE 0 END
			 END 

		UPDATE #PZ2a SET IloscWiekowana = @AgeQty, WartWiekowIlosci = @WartWiekowIlosci WHERE ID = @ID
		SET @Nar=@RecQty
	END ELSE BEGIN
		SET @AgeQty = CASE WHEN @RecQty <= @Stock - @Nar THEN @RecQty ELSE  
			           CASE WHEN @Stock - @Nar >=0 THEN @Stock - @Nar ELSE 0 END 
			      END
		SET @WartWiekowIlosci = CASE WHEN @RecQty <= @Stock - @Nar THEN @WartoscTransakcji ELSE  
			           CASE WHEN @Stock - @Nar >=0 THEN (@Stock - @Nar)* @CenaJedn ELSE 0 END 
			      END

		UPDATE #PZ2a SET NarastPoprzTrans = @Nar, IloscWiekowana = @AgeQty, WartWiekowIlosci = @WartWiekowIlosci WHERE ID = @ID
		SET @Nar = @Nar + @RecQty
	END		
	SET @PrevArtcode = @artcode 
	SET @PrevWarehouse = @warehouse

	FETCH NEXT FROM cum
	INTO @ID, @artcode, @warehouse, --@datum, 
	@RecQty, @Stock, @WartoscTransakcji, @CenaJedn   

END

CLOSE cum
DEALLOCATE cum
