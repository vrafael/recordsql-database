--liquibase formatted sql

--changeset vrafael:framework_20200603_Test_03_TestRecord logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true context:dev,test
EXEC dbo.TestSet
    @TypeTag = N'Test'
   ,@StateID = NULL
   ,@Name = N'Test string'
   ,@Boolean = 1
   ,@Money = 2.34
   ,@Float = -13123.123
   ,@Varbinary = NULL
   ,@Datetime = N'20200808 01:12:31.33333'
   ,@Text = N'Lorem ipsum ..'
   ,@Bigint = 12341273490712
   ,@Integer = 238479
   ,@Color = 'FFFFFFFF'
   ,@Date = N'20200808'
   ,@Time = N'01:12:31.33333'

--EXEC dbo.TestFind
--EXEC dbo.TestGet @ID = 215