SELECT B.debnr AS Kod, B.NAZWA, B.STATUS, B.PriceList AS [Cennik przypisany], p.KOD, p.NAZWA, p.KosztStandardowy, 
stl.prijs83 AS [Cena w cenniku Exact], curr.CurrencyCode AS Waluta, curr.Rate AS [Kurs w Exact], curr.Date AS [Kurs z dnia],
CASE WHEN Curr.Rate IS NOT NULL THEN Curr.Rate * (CASE WHEN stl.kort_pbn = 'M' THEN ((P.KosztStandardowy * ISNULL(stl.unitfactor, 1)) * ( 1 + stl.bedr1/100)) ELSE
(CASE WHEN stl.aantal1 is null THEN stl.prijs83 ELSE stl.prijs83 END) END) 
ELSE (CASE WHEN stl.kort_pbn = 'M' THEN ((P.KosztStandardowy * ISNULL(stl.unitfactor, 1)) * ( 1 + stl.bedr1/100)) ELSE
(CASE WHEN stl.aantal1 is null THEN stl.prijs83 ELSE stl.prijs83 END) END) END AS [Wartosc towaru wg cennika w PLN],
stl.validfrom AS [Cennik od], stl.validto AS [Cennik do], h.fullname,
fr.[Data Ostatniej Faktury],
fr.[Cena Sprzedazy Faktura],
fr.[Numer faktury]
FROM ZMPV_KLIENT B 
-- price lists
LEFT OUTER JOIN stfoms stf WITH (NOLOCK) ON stf.prijslijst = B.PriceList
INNER JOIN humres h WITH (NOLOCK) ON h.res_id = B.OPIEKUN
-- prices - details
LEFT OUTER JOIN staffl stl WITH (NOLOCK) ON stl.accountid IS NULL AND B.PriceList = stl.prijslijst -- AND stl.artcode = p.KOD
INNER JOIN ZMPV_PRODUKT p WITH (NOLOCK) ON p.KOD = stl.artcode
LEFT OUTER JOIN ( 
SELECT y.CurrencyCode AS CurrencyCode, v.oms30_0 AS Description, y.date_l AS Date, y.rate_exchange AS Rate, y.rate_official AS VatRate 
 	FROM (SELECT source_currency AS CurrencyCode,  rates.date_l, rates.rate_exchange, rates.rate_official 
    FROM rates WITH (NOLOCK) WHERE rates.target_Currency = 'PLN') y INNER JOIN valuta v ON y.CurrencyCode = v.valcode INNER JOIN 
		(SELECT DISTINCT s.Cur, max (s.date_l) AS LastDate FROM (SELECT source_currency AS Cur, date_l FROM Rates WITH (NOLOCK)) s 
        WHERE s.Date_l <= GETDATE() 
        GROUP BY s.cur) AS x ON x.Cur = y.currencycode AND x.LastDate = y.date_l 
        WHERE v.Active = 1 AND y.date_l <= GETDATE()
		) curr ON curr.CurrencyCode = stf.valcode 
-- invoices
LEFT OUTER JOIN (
	(
		SELECT
		  [Data Ostatniej Faktury], [Numer faktury], [Kod towaru], [Dluznik], [Cena Sprzedazy Faktura]
		FROM (
		  SELECT f.fakdat AS [Data Ostatniej Faktury], LTRIM(RTRIM(f.faknr)) AS [Numer faktury], 
			f.artcode AS [Kod towaru], f.prijs83 AS [Cena Sprzedazy Faktura], h.fakdebnr AS [Dluznik], max_date = MAX(f.fakdat) OVER (PARTITION BY f.artcode)
			FROM frhsrg f WITH (NOLOCK) INNER JOIN frhkrg h WITH (NOLOCK) ON h.faknr = f.faknr
			WHERE f.artcode IS NOT NULL AND LEN(f.artcode) > 2
		) AS s
		WHERE [Data Ostatniej Faktury] = max_date
	)
) fr ON fr.[Kod towaru] LIKE p.KOD AND fr.[Dluznik] = B.debnr
WHERE stl.prijs83 != 0 AND GetDate() < stl.validto 
AND B.STATUS LIKE 'A'
ORDER BY B.debnr
