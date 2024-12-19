import mongoose from "mongoose";

const tarjetaCreditoSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'user',
        required: true
    },
    numeroTarjeta: {
        type: String,
        required: true,
        unique: true
    },
    limiteCredito: {
        type: Number,
        required: true
    },
    balanceActual: {
        type: Number,
        required: true
    },
    fechaCorte: {
        type: Date,
        required: true
    },
    fullName: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true
    },

     cedula: {
        type: String,
        required: true
    }
}, { timestamps: true });

export default mongoose.model('TarjetaCredito', tarjetaCreditoSchema);
