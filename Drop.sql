USE AIRPORT;

EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';

EXEC sp_MSforeachtable 'DELETE FROM ?';

DECLARE @tableName NVARCHAR(128);

DECLARE tablesCursor CURSOR FOR
    SELECT t.name
    FROM sys.tables t
    WHERE EXISTS (
        SELECT 1 
        FROM sys.foreign_keys fk
        WHERE fk.parent_object_id = t.object_id
    );

OPEN tablesCursor;

FETCH NEXT FROM tablesCursor INTO @tableName;
WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @constraintName NVARCHAR(128);
    SELECT @constraintName = name
    FROM sys.foreign_keys
    WHERE parent_object_id = OBJECT_ID(@tableName);
    
    IF @constraintName IS NOT NULL
    BEGIN
        DECLARE @sql NVARCHAR(MAX);
        SET @sql = 'ALTER TABLE ' + @tableName + ' DROP CONSTRAINT ' + @constraintName;
        EXEC sp_executesql @sql;
    END

    FETCH NEXT FROM tablesCursor INTO @tableName;
END

CLOSE tablesCursor;
DEALLOCATE tablesCursor;

EXEC sp_MSforeachtable 'DROP TABLE ?';

EXEC sp_MSforeachtable 'EXEC sp_dropextendedproperty @name=N''MS_Description'', @level0type=N''SCHEMA'', @level0name=N''dbo'', @level1type=N''TABLE'', @level1name=?';

EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';
