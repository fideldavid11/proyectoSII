import express from 'express';
import { register, login, getUserInfo } from '../controllers/userController.js';
import authMiddleware from '../middleware/authMiddleware.js';

const router = express.Router();

router.post('/register', register); 

router.post('/login', login);

router.get('/user/info', authMiddleware, getUserInfo);  


export default router;
