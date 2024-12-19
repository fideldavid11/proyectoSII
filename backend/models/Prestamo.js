import mongoose from "mongoose";

const prestamoSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'user',
        required: true
    },
    tipoPrestamo: {
        type: String,
        enum: ['Personal', 'Hipotecario', 'Auto', 'Educativo'],
        required: true
    },
    montoTotal: {
        type: Number,
        required: true
    },
    balanceRestante: {
        type: Number,
        required: true
    },
    tasaInteres: {
        type: Number,
        required: true
    },
    fechaVencimiento: {
        type: Date,
        required: true
    }
}, { timestamps: true });

export default mongoose.model('Prestamo', prestamoSchema);
