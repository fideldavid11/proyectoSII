import mongoose from "mongoose";

const ahorroSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'user',
        required: true
    },
    email: {
        type: String,
        required: true
    },
    fullName: {
        type: String,
        required: true
    },
    numeroCuenta: {
        type: String,
        required: true,
        unique: true
    },
    balance: {
        type: String,
        required: true
    },
    fechaApertura: {
        type: Date,
        default: Date.now
    }
}, { timestamps: true });

export default mongoose.model('Ahorro', ahorroSchema);
