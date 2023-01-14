string strQuery = @"SELECT s.nr_kolejny AS NRKOL, s.begin_begrenzer_iagebied, s.begin_begrenzer_objectnaam, s.begin_begrenzer_objecttype, s.begin_begrenzer_kantcode,
		s.eind_begrenzer_iagebied, s.eind_begrenzer_objectnaam, s.eind_begrenzer_objecttype, s.eind_begrenzer_kantcode, s.tak_type, s.processed,
		n1.ia_gebied AS GEBIEDBEGIN, n1.objectnaam AS OBJNAMEBEGIN, n1.hoofd_kmwaarde AS HOODFKMBEGIN,
		n1.hoekverhouding AS HOEKVBEGIN, n1.symmetrisch AS SYMBEGIN, n1.kaartnaam AS KAARTNAAMBEGIN, n1.kaarttype,
		n2.ia_gebied AS GEBIEDEND, n2.objectnaam AS OBJNAMEEND, n2.hoofd_kmwaarde AS HOODFKMEND,
		n2.hoekverhouding AS HOEKVEND, n2.symmetrisch AS SYMEND, n2.kaartnaam AS KAARTNAAMEND, n2.kaarttype,
		g1.gebiednaam AS GEBIEDNAAMBEGIN, g1.gebiedtype, g1.geocode AS GEBIEDGEOCODES1,
		g2.gebiednaam AS GEBIEDNAAMEND, g2.gebiedtype, g2.geocode AS GEBIEDGEOCODES2
	FROM (" + IAVisualization.DAL.DatabaseDataAccess.InfraGeoTecAccess.IAConnectionTableName + @" s LEFT OUTER JOIN " + IAVisualization.DAL.DatabaseDataAccess.InfraGeoTecAccess.TopologyCarriersTableName + @" n1
			 ON s.begin_begrenzer_iagebied LIKE n1.ia_gebied AND s.begin_begrenzer_objectnaam LIKE n1.objectnaam
			 LEFT OUTER JOIN " + IAVisualization.DAL.DatabaseDataAccess.InfraGeoTecAccess.TopologyCarriersTableName + @" n2
			 ON s.eind_begrenzer_iagebied LIKE n2.ia_gebied AND s.eind_begrenzer_objectnaam LIKE n2.objectnaam)
			 LEFT OUTER JOIN " + IAVisualization.DAL.DatabaseDataAccess.InfraGeoTecAccess.IAAreasTableName + @" g1 ON
			 (n1.kaartnaam LIKE g1.gebiednaam AND n1.kaarttype LIKE g1.gebiedtype AND n1.kaarttype = 'OBEBLAD')
			 LEFT OUTER JOIN " + IAVisualization.DAL.DatabaseDataAccess.InfraGeoTecAccess.IAAreasTableName + @" g2 ON
			 (n2.kaartnaam LIKE g2.gebiednaam AND n2.kaarttype LIKE g2.gebiedtype AND n2.kaarttype = 'OBEBLAD')
	WHERE s.processed = 0
	ORDER BY s.begin_begrenzer_iagebied, s.begin_begrenzer_objectnaam";