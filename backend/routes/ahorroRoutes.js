import express from 'express';
import { 
    crearCuentaAhorro, 
    obtenerCuentasAhorro, 
    obtenerCuentasAhorroPorUsuario, 
    actualizarSaldoAhorro,
} from '../controllers/ahorroController.js';

import authMiddleware from '../middleware/authMiddleware.js';


const router = express.Router();

router.post('/crear', authMiddleware, crearCuentaAhorro);

router.get('/todas', authMiddleware, obtenerCuentasAhorro);

router.get('/:userId', authMiddleware, obtenerCuentasAhorroPorUsuario);

router.put('/actualizar-saldo', authMiddleware, actualizarSaldoAhorro);


export default router;
