--liquibase formatted sql

--changeset vrafael:framework_20200312_Relationships_03_dboTypeCheckLinks logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
--проверка группы ссылок
CREATE OR ALTER PROCEDURE [dbo].[TypeCheckLinks]
    @ID dbo.link
   ,@TypeID dbo.link
   ,@FieldLinks dbo.listKeyValue READONLY
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @Identifier dbo.string
       ,@FieldLinkID bigint
       ,@ValueID bigint
       ,@ValueTypeID bigint
       ,@OwnerTypes dbo.listOrdered
       ,@TypeID_Relationship bigint = dbo.TypeIDByTag(N'Relationship')

    IF @TypeID IS NULL
    BEGIN
        EXEC dbo.Error
            @Message = N'Не указан тип'
    END

    --заполняем список владельцев проверяемого типа
    INSERT INTO @OwnerTypes
        (ID, [Order])
    SELECT
        pt.ID
       ,pt.Lvl
    FROM dbo.DirectoryOwnersInline(@TypeID, N'Type', 1) pt;

    --ToDo сделать проверку на обязательность (Required) поля ссылки

    WITH FieldLinksTypes AS
    (
        SELECT
            fl.KeyID as FieldLinkID
           ,vt.ID as ValueOwnerTypeID
        FROM @FieldLinks fl
            JOIN dbo.TObject vo ON vo.ID = fl.ValueID --объект ссылки
            CROSS APPLY dbo.DirectoryOwnersInline(vo.TypeID, N'Type', 1) vt --родительские типы объекта ссылки
    )
   ,FieldLinksWithCheck AS
    (   --получаем список проверенных значений
        SELECT
            flt.FieldLinkID
        FROM FieldLinksTypes flt
            JOIN dbo.TLink l ON l.OwnerID = flt.FieldLinkID
                AND l.TypeID = @TypeID_Relationship
                AND l.TargetID = flt.ValueOwnerTypeID
         WHERE (l.CaseID IS NULL --или условие не задано
                OR EXISTS(SELECT 1 FROM @OwnerTypes ot WHERE ot.ID = l.CaseID)) --в поле условие указан тип являющийся предком текущего типа 
        GROUP BY flt.FieldLinkID
    )
    SELECT TOP (1)
        @FieldLinkID = fl.KeyID
       ,@ValueID = fl.ValueID
       ,@ValueTypeID = vo.TypeID
    FROM @FieldLinks fl
        JOIN dbo.TObject vo ON vo.ID = fl.ValueID
    WHERE (fl.ValueID > 0)
        AND NOT EXISTS --разрешение не найдено
        (
            SELECT 1
            FROM FieldLinksWithCheck flwc
            WHERE flwc.FieldLinkID = fl.KeyID
        )

    IF @ValueID IS NOT NULL
    BEGIN
        SELECT TOP (1)
            @Identifier = d.[Tag]
        FROM @OwnerTypes ot
            JOIN dbo.TObject o ON o.OwnerID = ot.ID
            JOIN dbo.TDirectory d ON d.ID = ot.ID
            JOIN dbo.TDirectory td ON td.ID = o.TypeID
                AND td.Tag = N'FieldIdentifier'
        ORDER BY ot.[Order]

        EXEC dbo.Error
            @Message = N'Отсутствует разрешение поля ID=%s для %s=%s типа ID=%s иметь значение ID=%s типа ID=%s'
           ,@p0 = @FieldLinkID
           ,@p1 = @Identifier
           ,@p2 = @ID
           ,@p3 = @TypeID
           ,@p4 = @ValueID
           ,@p5 = @ValueTypeID
    END
END