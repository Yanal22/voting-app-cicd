const express = require('express');
const { Pool } = require('pg');
const path = require('path');

const app = express();
const port = 80;

const pool = new Pool({
    host: process.env.POSTGRES_HOST || 'db',
    port: 5432,
    database: process.env.POSTGRES_DB || 'postgres',
    user: process.env.POSTGRES_USER || 'postgres',
    password: process.env.POSTGRES_PASSWORD || 'postgres'
});

app.use(express.static('public'));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.get('/results', async (req, res) => {
    try {
        const result = await pool.query(
            'SELECT vote, COUNT(*) as count FROM votes GROUP BY vote'
        );
        const votes = { a: 0, b: 0 };
        result.rows.forEach(row => {
            votes[row.vote] = parseInt(row.count);
        });
        res.json(votes);
    } catch (err) {
        res.json({ a: 0, b: 0 });
    }
});

app.listen(port, () => {
    console.log(`Results app listening on port ${port}`);
});
