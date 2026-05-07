import express from "express";
import dotenv from "dotenv";
import referralRoutes from "./routes/referral.js";
import cors from 'cors';

dotenv.config();

const app = express();
app.use(express.json());
app.use(cors({
  origin: 'https://coruscating-selkie-75aefa.netlify.app',
  credentials: true
}));
// Routes
app.use(referralRoutes);

// Health check
app.get("/", (req, res) => res.send("TokenTrove API running ✅"));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
