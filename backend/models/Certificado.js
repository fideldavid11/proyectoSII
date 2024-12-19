import mongoose from "mongoose";

const certificadoSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'user',
        required: true
    },
    numeroCertificado: {
        type: String,
        required: true,
        unique: true
    },
    montoInvertido: {
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

export default mongoose.model('Certificado', certificadoSchema);
