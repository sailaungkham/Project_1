const express = require('express');
const app = express();
const con = require("./db");
const bcrypt = require('bcrypt');
app.use(express.json());

app.post('/login', (req, res)=>{
    const {username, password} = req.body;
    const sql = 'SELECT password FROM users WHERE username=?'
    con.query(sql ,[username], (err, results)=>{
        if(err){
            return res.status(400).send('DB error');
        } 
        if(results.length != 1) {
            return res.status(400).send('Wrong Password');
        }
        // compare raw and hash password
        const hash = results[0].password;
        bcrypt.compare(password, hash, (err, same)=>{
            if(err){
                return res.status(400).send('DB error');
            } 
            if(!same) {
                return res.status(400).send('Login Failed');
            }
            res.send("Login OK");
        })
    });
});

app.get('/password/:raw', (req, res)=>{
    const raw = req.params.raw;
    bcrypt.hash(raw, 10, (err, hash)=>{
        if(err){
            return res.status(500).send('Hash error')
        }
        else{
            return res.send(hash);
        }
    })
})

app.get('/', (req, res) => {
    res.send('hello');
});

app.get('/expenses', (req, res) => {
    const sql = 'SELECT * FROM expense';
    con.query(sql, (err, results) => {
        if (err) {
            console.error(err); 
            return res.status(500).send('DB error');
        }
        res.json(results);
    });
});

app.listen(3000, () => {
    console.log('Server is running on port 3000');
});
