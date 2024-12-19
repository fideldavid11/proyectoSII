import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
import userRoutes from './routes/userRoutes.js';
import ahorroRoutes from './routes/ahorroRoutes.js';
import creditRoutes from './routes/tarjetaRoute.js'

dotenv.config();

const app = express();

app.use(express.json());

mongoose.connect(process.env.MONGO_URL)
.then(() => {
    console.log('Conectado a MongoDB');
})
.catch((error) => {
    console.error('Error al conectar a MongoDB:', error);
});

app.use('/api/users', userRoutes); 
app.use('/api/ahorro', ahorroRoutes);
app.use('/api/credit', creditRoutes);

const PORT = process.env.PORT || 7575; 
app.listen(PORT, () => {
    console.log(`La app atiende el puerto: ${PORT}`);
});
