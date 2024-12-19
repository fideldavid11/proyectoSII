import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        default: new mongoose.Types.ObjectId(),
        unique: true
    },
    nombres: {
        type: String,
        required: true
    },
    apellidos: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true,
        unique: true 
    },
    numero_telefonico: {
        type: String,
        required: true
    },
    numero_cuenta: {
        type: String,
        required: true
    },
    pin: {
        type: String,
        required: true,
        minlength: 4, // Se asegura de que el PIN tenga al menos 4 caracteres
        maxlength: 100 
    },
    dinero: {
        type: String, 
        required: true 
    },
    cedula: {
        type: String,
        required: true,
        unique: true 
    }
}, { timestamps: true });

export default mongoose.model('user', userSchema);
