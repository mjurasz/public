SELECT t.towar AS [valTowar], 
CASE WHEN i.class_02 LIKE '01' THEN 'Folia' 
	ELSE CASE WHEN i.class_02 IN ('02') THEN 'Pianka' 
		ELSE CASE WHEN i.class_02 LIKE ('05') THEN 'Pianka techniczna' 
			ELSE 'INNY' 
		END 
	END 
END AS [evRodzajTowaru],
t.data AS [valData], t.Nazwa_maszyny AS [valNazwaMaszyny],
t.wyprodukowano AS [valWyprodukwoano],
CASE WHEN i.class_02 IN ('02', '05') THEN CAST(REPLACE(i.userfield_07, ',', '.') AS DECIMAL(18,6)) * t.wyprodukowano ELSE NULL END AS [valExM3Wyprodukowano], 
CASE WHEN i.class_02 LIKE '01' THEN CAST(REPLACE(i.userfield_05, ',', '.') AS DECIMAL(18,6)) * CAST(REPLACE(i.userfield_06, ',', '.') AS DECIMAL(18,6)) * t.wyprodukowano ELSE NULL END AS [valExM2Wyprodukowano]
FROM zpln_tr_hist t WITH (NOLOCK) INNER JOIN items i WITH (NOLOCK) ON t.towar LIKE i.itemcode
WHERE t.Data >= '2013-11-01 00:00:00' AND t.Data <= '2013-11-30 23:59:59' AND t.Nazwa_maszyny NOT LIKE 'EREMA%'
ORDER BY t.towar, t.Data, t.nazwa_maszyny 
