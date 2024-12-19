import express from 'express';
import { 
    obtenerTarjetasCreditoPorUsuario, 
    crearTarjetaCredito, 
    eliminarTarjetaCredito 
} from '../controllers/TarjetaController.js';

import authMiddleware from '../middleware/authMiddleware.js';

const router = express.Router();

router.post('/crear', authMiddleware, crearTarjetaCredito);

router.get('/:userId', authMiddleware, obtenerTarjetasCreditoPorUsuario);

router.delete('/eliminar/:numeroTarjeta', authMiddleware, eliminarTarjetaCredito);

export default router;
