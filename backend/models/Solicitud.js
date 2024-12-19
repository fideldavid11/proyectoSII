import mongoose from "mongoose";

const solicitudSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'user',
        required: true
    },
    tipoSolicitud: {
        type: String,
        enum: ['Crédito', 'Actualización de Datos', 'Bloqueo de Tarjeta'],
        required: true
    },
    fechaSolicitud: {
        type: Date,
        default: Date.now
    },
    estado: {
        type: String,
        enum: ['Pendiente', 'Aprobada', 'Rechazada'],
        default: 'Pendiente'
    },
    detalles: {
        type: String
    }
}, { timestamps: true });

export default mongoose.model('Solicitud', solicitudSchema);
