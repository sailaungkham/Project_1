const con = require("./db");
const express = require("express");
const bcrypt = require("bcrypt");
const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
// app.use(bodyParser.json());

// password generator
app.get("/password/:pass", (req, res) => {
  const password = req.params.pass;
  bcrypt.hash(password, 10, function (err, hash) {
    if (err) {
      return res.status(500).send("Hashing error");
    }
    res.send(hash);
  });
});

// search
app.post("/search", (req, res) => {
  const { userid, itemsearch } = req.body;
  // console.log('Received userid: ', userid);
  const sql = "SELECT * FROM expense WHERE user_id = ? AND  item LIKE ?";

  // console.log('Executing query:', sql, [userid, ]);
  con.query(sql, [userid, `%${itemsearch}%`], (err, results) => {
    if (err) {
      return res.status(500).send("DB error");
    }
    res.json(results);
    console.log(results);
  });
});

// login
app.post("/login", (req, res) => {
  const { username, password } = req.body;
  const sql = "SELECT id, password FROM users WHERE username = ?";
  con.query(sql, [username], function (err, results) {
    if (err) {
      return res.status(500).send("Database server error");
    }
    if (results.length != 1) {
      return res.status(401).send("Wrong username");
    }
    // compare passwords
    bcrypt.compare(password, results[0].password, function (err, same) {
      if (err) {
        return res.status(500).send("Hashing error");
      }
      if (same) {
        return res.json({ message: "Login OK", user_id: results[0].id }); // Return user_id in JSON
      }
      return res.status(401).send("Wrong password");
    });
  });
});

app.get("/account", (req, res) => {
  const userId = req.query.user_id; // Get user ID from query parameter

  const sql = "SELECT * FROM expense WHERE user_id = ?";
  con.query(sql, [userId], (err, results) => {
    if (err) {
      console.error(err);
      return res.status(500).send("Error fetching expenses");
    }

    // Filter expenses based on today's date
    const today = new Date();
    const todayExpenses = results.filter((expense) => {
      const expenseDate = new Date(expense.date);
      return expenseDate.toDateString() === today.toDateString();
    });
    console.log(results);
    res.json({
      allExpenses: results,
      todayExpenses: todayExpenses,
    });
  });
});

// ADD
// Endpoint to add a new expense
app.post("/add_expense", async (req, res) => {
  const { user_id, item, paid, date } = req.body;

  const sql =
    "INSERT INTO expense (user_id, item, paid, date) VALUES (?, ?, ?, ?);";

  con.query(sql, [user_id, item, paid, date], function (err, results) {
    if (err) {
      return res.status(500).send("Database server error");
    }
    else{
        return res.status(200).send("Ok");
    }
  });
});

// ---------- Server starts here ---------
const port = 3000;
app.listen(port, () => {
  console.log("Server is running at " + port);
});
