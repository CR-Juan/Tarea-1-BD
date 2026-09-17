-- Procedure de Inserción
CREATE PROCEDURE sp_InsertProductLocation
    @Name NVARCHAR(50),
    @CostRate SMALLMONEY,
    @Availability DECIMAL(8,2),
    @ModifiedDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Production.Location (Name, CostRate, Availability, ModifiedDate)
    VALUES (@Name, @CostRate, @Availability, @ModifiedDate);
END;

EXEC sp_InsertProductLocation @Name = 'Almacén Principal', @CostRate = 10.50, @Availability = 95.50, @ModifiedDate = '2026-09-13';
GO

-- Procedure de Actualización
CREATE PROCEDURE sp_UpdateProductLocation
    @LocationID INT,
    @Name NVARCHAR(50),
    @CostRate SMALLMONEY,
    @Availability DECIMAL(8,2),
    @ModifiedDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Production.Location
    SET
        Name = @Name,
        CostRate = @CostRate,
        Availability = @Availability,
        ModifiedDate = @ModifiedDate
    WHERE LocationID = @LocationID;
END;

EXEC sp_UpdateProductLocation @LocationID = 61, @Name = 'Almacén Secundario', @CostRate = 12.00, @Availability = 90.00, @ModifiedDate = '2026-09-14';
GO

-- Procedure de Borrado
CREATE PROCEDURE sp_DeleteProductLocation
    @LocationID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Production.Location
    WHERE LocationID = @LocationID;
END;

EXEC sp_DeleteProductLocation @LocationID = 61;
GO

-- Procedure de Selección
CREATE PROCEDURE sp_GetProductLocation
AS
BEGIN
    SET NOCOUNT ON;

    SELECT LocationID, Name, CostRate, Availability, ModifiedDate
    FROM Production.Location;
END;

EXEC sp_GetProductLocation;
GO

-- Procedure de Selección por ID
CREATE PROCEDURE sp_GetProductLocationById
    @LocationID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT LocationID, Name, CostRate, Availability, ModifiedDate
    FROM Production.Location
    WHERE LocationID = @LocationID;
END;
GO

-- Procedure de Selección con Join
CREATE PROCEDURE sp_GetProductStockByLocation
    @LocationID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        L.LocationID,
        L.Name AS LocationName,
        I.ProductID,
        I.Shelf,
        I.Bin,
        I.Quantity
    FROM Production.Location AS L
    INNER JOIN Production.ProductInventory AS I 
        ON L.LocationID = I.LocationID
    WHERE L.LocationID = @LocationID;
END;

EXEC sp_GetProductStockByLocation @LocationID = 1;
GO