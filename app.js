const express = require('express');
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser');
const lodash = require('body-parser'); // packa with CVE-2019-10744

const app = express();
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());

// route vulnerable to SQL Injection
app.get('/search', (req, res) => {
    const searchTerm = req.query.term;
    const sql = `SELECT * FROM products WHERE name = '${searchTerm}'`
    // executes SQL query
});

// route vulnerable to XSS (Cross-Site Scripting)
app.get('/user/:name', (req, res) => {
    const userName = req.params.name;
    res.send(`<h1>Welcome, ${userName} </h1>`);
});

// route vulnerable to CSRF
app.get('/transfer', (req, res) => {
    const amount = req.body.amount;
    // transfers the amount to a destination
});

// route vulnerable to RCE
app.get('/execute', (req, res) => {
    const command = req.query.command;
    // executes the command on the server
});

// route exposes sensible data
app.get('/user/profile', (req, res) => {
    const userID = req.cookies.userID;
    // returns user profile with the specified ID
});

app.listen(3000, () => {
    console.log('Server is running on port 3000')
});
