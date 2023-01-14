CREATE VIEW vCOG_PrehledProduktuZakladniCeny AS
SELECT p.PrezentovatNaWebu AS PrezentovatNaWebu, p.Aktivni AS Aktivni, 
      p.SysDatAktualizace AS SysDatAktualizace, 
      p.KodProduktu AS KodProduktu, p.NazevProduktu AS NazevProduktu, 
      fn_Popis = (cast(replace(cast (p.TextSpecifikace as varchar(1024)),char(13)+char(10), ' '  ) as varchar(1024))), 
      p.KodSlevoveSkupiny AS KodSlevoveSkupiny, p.KodSkupiny1 AS KodSkupiny1, 
      fn_NakupniCena = (select top 1 max(Cena1BezDPH) from vCenyNakupniAktualni WITH (NOLOCK) where KodProduktu = p.KodProduktu), 
      fn_MenaNakupniCeny = (
          select top 1 cnn.KodMeny  from CenyNakupni as cn WITH (NOLOCK) join CenikyNakupni as cnn on cn.IDCeniku = cnn.IDCeniku where KodProduktu = p.KodProduktu), 
          fn_NakladovaCena = (select max(Cena1BezDPH) from vCenyProdejniAktualni as cp WITH (NOLOCK) where cp.IDCeniku = 109 and cp.KodProduktu = p.KodProduktu), 
          fn_ProdejniCena = (select max(Cena1BezDPH) from vCenyProdejniAktualni as cp WITH (NOLOCK) where cp.IDCeniku = 106 and cp.KodProduktu = p.KodProduktu),        
          p.KodMjProd AS KodMjProd, 
      fn_StavPraha = (select cast (sum(Stav) as decimal(12,2)) from SkladKarty as sk WITH (NOLOCK) where sk.KodProduktu = p.KodProduktu and sk.KodKnihy in ('001','002','003','201','301') group by sk.KodProduktu), 
       fn_StavBrno = (select cast (sum(Stav) as decimal(12,2)) from SkladKarty as sk WITH (NOLOCK) where sk.KodProduktu = p.KodProduktu and sk.KodKnihy in ('101','103','302') group by sk.KodProduktu), 
      p.KodMjSkl AS KodMjSkl, 
      fn_Rezervováno = (select cast (sum(Rezervovano) as decimal(12,2)) from SkladKarty as sk WITH (NOLOCK) where sk.KodProduktu = p.KodProduktu and sk.KodKnihy in ('001') group by sk.KodProduktu), 
      fn_Požadováno = (select cast (sum(Pozadovano) as decimal(12,2)) from SkladKarty as sk WITH (NOLOCK) where sk.KodProduktu = p.KodProduktu and sk.KodKnihy in ('001') group by sk.KodProduktu)
FROM Produkty AS p WITH(NOLOCK)
