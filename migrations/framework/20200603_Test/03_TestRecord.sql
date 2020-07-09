--liquibase formatted sql

--changeset vrafael:framework_20200603_Test_03_TestRecord logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true context:dev,test
EXEC dbo.TestSet
    @TypeTag = N'Test'
   ,@StateID = NULL
   ,@Name = N'Test string'
   ,@FieldBool = 1
   ,@FieldMoney = 2.34
   ,@FieldFloat = -13123.123
   ,@FieldVarbinary = NULL
   ,@FieldDatetime = '20200808 01:12:31.33333'
   ,@FieldText = N'Lorem ipsum ..'
   ,@FieldBigint = 12341273490712
   ,@FieldInt = 238479
   ,@FieldColor = '#FFFFFFFF'

--EXEC dbo.TestFind
--EXEC dbo.TestGet @ID = 211