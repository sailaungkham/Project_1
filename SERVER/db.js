const mysql = require('mysql2');
// const app = express();
// const con = require('./db');

const con = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'expenses'
});

module.exports = con;
