const express = require("express");
const bodyParser = require("body-parser");
const { sequelize, User, Category, Product } = require("./models");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { body, validationResult } = require("express-validator");
const app = express();
const PORT = process.env.PORT || 3000;

require('dotenv').config(); // Load environment variables

app.use(bodyParser.json());

// Middleware for authentication
const authenticateJWT = (req, res, next) => {
  const token = req.header("Authorization")?.split(" ")[1];

  if (token) {
    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
      if (err) {
        return res.status(403).json({ message: "Token is not valid" });
      }
      req.user = user;
      next();
    });
  } else {
    res.status(401).json({ message: "Authentication token is missing" });
  }
};

// Middleware to add user info to request
const addUserToRequest = async (req, res, next) => {
  if (req.user && req.user.id) {
    const user = await User.findByPk(req.user.id);
    if (user) {
      req.user = user;
    }
  }
  next();
};

// Unified error handler
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array().map(error => error.msg) });
  }
  next();
};

// Register
app.post(
  "/register",
  [
    body("username").notEmpty().withMessage("Username is required"),
    body("password").isLength({ min: 6 }).withMessage("Password must be at least 6 characters long"),
  ],
  handleValidationErrors,
  async (req, res) => {
    const { username, password } = req.body;

    try {
      // Check if the username already exists
      const existingUser = await User.findOne({ where: { username } });
      if (existingUser) {
        return res.status(400).json({ message: "Username already exists" });
      }

      const hashedPassword = await bcrypt.hash(password, 10);
      const user = await User.create({ username, password: hashedPassword });
      res.status(201).json(user);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

// Login
app.post(
  "/login",
  [
    body("username").notEmpty().withMessage("Username is required"),
    body("password").notEmpty().withMessage("Password is required"),
  ],
  handleValidationErrors,
  async (req, res) => {
    const { username, password } = req.body;
    try {
      const user = await User.findOne({ where: { username } });
      if (!user || !(await bcrypt.compare(password, user.password))) {
        return res.status(401).json({ message: "Invalid credentials" });
      }
      const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: "1h" });
      res.json({ token });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

// Get all categories
app.get("/categories", authenticateJWT, async (req, res) => {
  try {
    const categories = await Category.findAll();
    res.json(categories);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create new category
app.post("/categories", authenticateJWT, addUserToRequest, async (req, res) => {
  try {
    const category = await Category.create(req.body);
    res.status(201).json(category);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Delete category
app.delete("/categories/:id", authenticateJWT, addUserToRequest, async (req, res) => {
  try {
    const products = await Product.findAll({ where: { categoryId: req.params.id } });

    if (products.length > 0) {
      return res.status(400).json({ message: "Cannot delete category with associated products" });
    }

    const deleted = await Category.destroy({ where: { id: req.params.id } });

    if (!deleted) {
      return res.status(404).json({ message: "Category not found" });
    }

    res.json({ message: "Category deleted" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get all products
app.get("/products", authenticateJWT, async (req, res) => {
  try {
    const products = await Product.findAll();
    const formattedProducts = products.map(product => ({
      ...product.get(),
      createdAt: product.createdAt.toISOString(),
      updatedAt: product.updatedAt.toISOString()
    }));
    res.json(formattedProducts);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});



// Get product by id
app.get("/products/:id", authenticateJWT, async (req, res) => {
  try {
    const product = await Product.findByPk(req.params.id);
    if (!product) {
      return res.status(404).json({ message: "Product not found" });
    }
    const formattedProduct = {
      ...product.get(),
      createdAt: product.createdAt.toISOString(),
      updatedAt: product.updatedAt.toISOString()
    };
    res.json(formattedProduct);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});



// Create new product
app.post("/products", authenticateJWT, addUserToRequest, async (req, res) => {
  try {
    const { name, qty, categoryId, url } = req.body;
    const product = await Product.create({
      name,
      qty,
      categoryId,
      url,
      createdBy: req.user.username, // menggunakan username dari req.user
      updatedBy: req.user.username, // menggunakan username dari req.user
    });
    res.status(201).json(product);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update product
app.put("/products/:id", authenticateJWT, addUserToRequest, async (req, res) => {
  try {
    const { name, qty, categoryId, url } = req.body;
    const [updated] = await Product.update(
      {
        name,
        qty,
        categoryId,
        url,
        updatedBy: req.user.username, // menggunakan username dari req.user
      },
      { where: { id: req.params.id } }
    );
    if (!updated) {
      return res.status(404).json({ message: "Product not found" });
    }
    res.json({ message: "Product updated" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Delete product
app.delete("/products/:id", authenticateJWT, addUserToRequest, async (req, res) => {
  try {
    const deleted = await Product.destroy({ where: { id: req.params.id } });
    if (!deleted) {
      return res.status(404).json({ message: "Product not found" });
    }

    res.json({ message: "Product deleted" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, async () => {
  console.log(`Server is running on port ${PORT}`);
  await sequelize.sync();
});
