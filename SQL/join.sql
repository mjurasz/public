SELECT I.[Invoice_Number] AS Invoice_Number,
			   -- convert(nvarchar,I.[Invoice_Date],120) AS Invoice_Date,
			   convert(datetime, I.[Invoice_Date],120) AS Invoice_Date,
			   CASE WHEN SUBSTRING(I.[Invoice_Number],1,1)='B' THEN 'Bopfingen' ELSE I.Company END AS Division,		
               D.[DirectorAscii] AS Sales_Director,
               D.[managerascii] AS Sales_Manager,
               D.[AgentAscii] AS Sales_Person,
               I.[Bill_To_Number] AS Bill_To_Number,
               I.[Bill_To_Name] AS Bill_To_Name,
               I.[Ship_To_Number] AS Ship_To_Number,
               I.[Ship_To_Name] AS Ship_To_Name,
               I.[SKU] AS SKU,
               I.[SKU_Description] AS SKU_Description,
               I.[InvUom] AS InvUom,
               convert(decimal(24,4), I.[InvQuantity_Shipped]) AS InvQuantity_Shipped,
               convert(decimal(24,4), I.[InvSales_Price]) AS InvSales_Price,
               convert(decimal(24,4), I.[Sales_Value]) AS Sales_Value,
               I.[Currency] AS [Currency],
               I.[PPEUom] AS PPEUom,
               convert(decimal(24,4), I.[PPEQuantity_Shipped]) AS PPEQuantity_Shipped,
               M.[PPEMappingID] AS PPEMappingID,
               M.[DetermineLevel] AS DetermineLevel,
               M.[PLevel1] AS PLevel1,
               M.[PLevel2] AS PLevel2,
               M.[PLevel3] AS PLevel3,
               M.[PLevel4] AS PLevel4,
               M.[PLevel5] AS PLevel5,
               M.[PLevel6] AS PLevel6,
               M.[PLevel7] AS PLevel7,
               M.[PLevel8] AS PLevel8,
               C1.[CountryCode] + ' ' + CO1.CountryName AS Bill_To_Country,
               C2.[CountryCode] + ' ' + CO2.CountryName AS Ship_To_Country,
			   CASE WHEN CGM.CustomerGroupName IS NULL THEN 'NONE' ELSE CGM.CustomerGroupName END AS GroupName,
			   CASE WHEN CG.AccountType='SAM' THEN CG.AccountType ELSE 'NONE' END AS AccountType,
			   convert(decimal(24,4), Sales_Value * ccd1.DollarExchangeRate / ccd3.DollarExchangeRate) AS LC_Sales_Value,
			   ct.LocalCurrencyCode AS LC_Currency,
			   convert(decimal(24,4), Sales_Value * ccd1.DollarExchangeRate / ccd2.DollarExchangeRate) AS EUR_Sales_Value,
			   'EUR' as EUR_Currency 
		INTO [dbo].Pricing_Currency
		FROM Invoicing AS I
		LEFT OUTER JOIN SKUMapping AS S ON I.SKU = S.SKU AND I.Company = S.Company
		LEFT OUTER JOIN PPESKU AS M ON S.PPESKU = M.PPEMappingID 
		LEFT OUTER JOIN Employee AS D ON I.Agent = D.Agent AND I.Company = D.Company
		LEFT OUTER JOIN CountryMapping AS C1 ON I.Bill_to_Country = c1.LocalCountryCode AND I.company=c1.company
		LEFT OUTER JOIN Country CO1 ON C1.countryCode = CO1.CountryCode
		LEFT OUTER JOIN CountryMapping AS C2 ON I.Ship_to_Country = c2.LocalCountryCode AND I.company=c2.company
		LEFT OUTER JOIN Country CO2 ON C2.countryCode = CO2.CountryCode		
		LEFT OUTER JOIN CustomerGroupMapping AS CGM ON I.Bill_to_number = cgm.CustomerCode AND I.company = cgm.company
		LEFT OUTER JOIN CustomerGroup AS CG ON CG.CustomerGroupName = CGM.CustomerGroupName
		LEFT OUTER JOIN CurrencyConversionDollar AS ccd1 ON I.[Currency] = ccd1.currencycode AND Year(I.[Invoice_Date])= ccd1.SalesYear AND Month(I.[Invoice_Date])=ccd1.SalesMonth
		LEFT OUTER JOIN CurrencyConversionDollar AS ccd2 ON ccd2.currencycode='EUR' AND Year(I.[Invoice_Date])= ccd2.SalesYear AND Month(I.[Invoice_Date])=ccd2.SalesMonth
	    LEFT OUTER JOIN company cp ON cp.companyKININame=i.company
		LEFT OUTER JOIN country ct ON cp.countrycode=ct.countrycode
		LEFT OUTER JOIN CurrencyConversionDollar AS ccd3 ON ccd3.currencycode=ct.LocalCurrencyCode AND Year(I.[Invoice_Date])= ccd3.SalesYear AND Month(I.[Invoice_Date])=ccd3.SalesMonth
