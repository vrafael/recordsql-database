--liquibase formatted sql

--changeset vrafael:framework_20200229_Generators_21_GlobalNormalize logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
--запуск нормализации базы
EXEC dbo.GlobalNormalize