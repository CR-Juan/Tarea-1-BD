const express = require('express');
const sql = require('mssql');

const app = express();
app.use(express.json());

const dbConfig = {
    user: 'sa',
    password: 'Majd-0723',
    server: 'localhost',
    database: 'AdventureWorks2025',
    options: {
        encrypt: false,
        trustServerCertificate: true
    }
};

app.get('/locations', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request().execute('sp_GetProductLocation');
        res.json(result.recordset);
    } catch (err) {
        res.status(500).send(err.message);
    }
});

app.get('/locations/:id', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('LocationID', sql.SmallInt, req.params.id)
            .execute('sp_GetProductLocationById');
        res.json(result.recordset);
    } catch (err) {
        res.status(500).send(err.message);
    }
});

app.post('/locations', async (req, res) => {
    try {
        const { name, costRate, availability, modifiedDate } = req.body;
        const pool = await sql.connect(dbConfig);
        await pool.request()
            .input('Name', sql.NVarChar(50), name)
            .input('CostRate', sql.SmallMoney, costRate)
            .input('Availability', sql.Decimal(8,2), availability)
            .input('ModifiedDate', sql.DateTime, modifiedDate)
            .execute('sp_InsertProductLocation');
        res.status(201).send('Ubicación creada');
    } catch (err) {
        res.status(500).send(err.message);
    }
});

app.put('/locations/:id', async (req, res) => {
    try {
        const { name, costRate, availability, modifiedDate } = req.body;
        const pool = await sql.connect(dbConfig);
        await pool.request()
            .input('LocationID', sql.SmallInt, req.params.id)
            .input('Name', sql.NVarChar(50), name)
            .input('CostRate', sql.SmallMoney, costRate)
            .input('Availability', sql.Decimal(8,2), availability)
            .input('ModifiedDate', sql.DateTime, modifiedDate)
            .execute('sp_UpdateProductLocation');
        res.send('Ubicación actualizada');
    } catch (err) {
        res.status(500).send(err.message);
    }
});

app.delete('/locations/:id', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        await pool.request()
            .input('LocationID', sql.SmallInt, req.params.id)
            .execute('sp_DeleteProductLocation');
        res.send('Ubicación eliminada');
    } catch (err) {
        res.status(500).send(err.message);
    }
});

app.get('/locations/:id/stock', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('LocationID', sql.SmallInt, req.params.id)
            .execute('sp_GetProductStockByLocation');
        res.json(result.recordset);
    } catch (err) {
        res.status(500).send(err.message);
    }
});

app.listen(8081, () => {
    console.log('API corriendo en http://localhost:8081');
});