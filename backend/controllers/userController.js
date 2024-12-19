import bcrypt from 'bcryptjs';
import User from '../models/users.js';
import { validationResult } from 'express-validator';
import nodemailer from 'nodemailer';
import jwt from 'jsonwebtoken';

const generateAccountNumber = () => {
    return '1' + Math.floor(Math.random() * 1e12).toString().padStart(12, '0');
};

const generatePin = () => {
    return Math.floor(100000 + Math.random() * 900000).toString();
};

export const register = async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { nombres, apellidos, email, numero_telefonico, dinero, cedula } = req.body;
        const initialMoney = dinero || 'RD $500'; // Monto inicial

         const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ msg: 'El correo electrónico ya está registrado' });
        }

         const existingCedula = await User.findOne({ cedula });
        if (existingCedula) {
            return res.status(400).json({ msg: 'La cédula ya está registrada' });
        }

        const numero_cuenta = generateAccountNumber();
        const pin = generatePin();

        const salt = await bcrypt.genSalt(10);
        const hashedPin = await bcrypt.hash(pin, salt);

        const newUser = new User({
            nombres,
            apellidos,
            email,
            numero_telefonico,
            numero_cuenta,
            pin: hashedPin,
            dinero: initialMoney,
            cedula
        });

        await newUser.save();

        const { pin: _, ...userResponse } = newUser.toObject();

         const transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: process.env.EMAIL_USER,
                pass: process.env.EMAIL_PASS
            }
        });

         const mailOptions = {
            from: process.env.EMAIL_USER,
            to: email,
            subject: 'Detalles de tu cuenta en Smart Banking',
            html: `
                <html>
                    <head>
                        <style>
                            body {
                                font-family: 'Arial', sans-serif;
                                background-color: #f4f7fa;
                                color: #333;
                                margin: 0;
                                padding: 0;
                            }
                            .container {
                                max-width: 600px;
                                margin: 30px auto;
                                background-color: #ffffff;
                                padding: 20px;
                                border-radius: 8px;
                                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
                            }
                            h1 {
                                text-align: center;
                                color: #0066cc;
                                font-size: 28px;
                            }
                            p {
                                font-size: 16px;
                                line-height: 1.6;
                            }
                            ul {
                                list-style: none;
                                padding: 0;
                            }
                            li {
                                font-size: 16px;
                                margin-bottom: 10px;
                            }
                            .highlight {
                                font-weight: bold;
                                color: #0066cc;
                            }
                            .footer {
                                text-align: center;
                                margin-top: 20px;
                                font-size: 14px;
                                color: #888;
                            }
                            .footer a {
                                color: #0066cc;
                                text-decoration: none;
                            }
                            .button {
                                display: inline-block;
                                padding: 12px 20px;
                                background-color: #0066cc;
                                color: #fff;
                                text-align: center;
                                text-decoration: none;
                                border-radius: 5px;
                                margin-top: 20px;
                            }
                            .button:hover {
                                background-color: #004da1;
                            }
                        </style>
                    </head>
                    <body>
                        <div class="container">
                            <h1>¡Bienvenido a Smart Banking, ${nombres} ${apellidos}!</h1>
                            <p>¡Gracias por registrarte con nosotros! En Smart Banking, estamos comprometidos a ofrecerte un servicio financiero de alta calidad y adaptado a tus necesidades.</p>
                            <p>Como agradecimiento por unirte a nuestra comunidad, te otorgamos un saldo inicial de <strong>${initialMoney}</strong> en tu cuenta.</p>
                            <p>Este saldo se te otorga como parte de nuestra política de bienvenida, para que puedas comenzar a disfrutar de todos los servicios que ofrecemos.</p>
                            <p>Ahora que tu cuenta ha sido creada, aquí tienes tus detalles:</p>
                            <ul>
                                <li><span class="highlight">Número de cuenta:</span> ${numero_cuenta}</li>
                                <li><span class="highlight">PIN:</span> ${pin} (Este PIN es sensible, por favor mantenlo seguro)</li>
                                <li><span class="highlight">Saldo inicial:</span> ${initialMoney}</li>
                            </ul>
                            <p>Si tienes alguna pregunta o necesitas asistencia, no dudes en contactarnos. Estamos aquí para ayudarte.</p>
                            <a href="mailto:fideldavidjobs@gmail.com" class="button">Contáctanos</a>
                            <div class="footer">
                                <p>El equipo de <strong>Smart Banking</strong></p>
                                <p>Si no has solicitado este registro, por favor ignora este correo.</p>
                                <p><a href="https://github.com/fideldavid11" target="_blank">Visita nuestra página web</a></p>
                            </div>
                        </div>
                    </body>
                </html>
            `
        };

         transporter.sendMail(mailOptions, (error, info) => {
            if (error) {
                console.log('Error al enviar el correo:', error);
                return res.status(500).json({ msg: 'Error al enviar el correo' });
            }
            console.log('Correo enviado: ' + info.response);
        });

        res.status(201).json({ msg: 'Usuario registrado exitosamente', user: userResponse });

    } catch (error) {
        console.error(error.message);
        res.status(500).json({ msg: 'Error en el servidor' });
    }
};


export const login = async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { numero_cuenta, pin } = req.body;

         if (!numero_cuenta || !pin) {
            return res.status(400).json({ msg: 'El número de cuenta y el PIN son requeridos.' });
        }

         const user = await User.findOne({ numero_cuenta });
        if (!user) {
            return res.status(404).json({ msg: 'Usuario no encontrado.' });
        }

         const isMatch = await bcrypt.compare(pin, user.pin);
        if (!isMatch) {
            return res.status(400).json({ msg: 'El PIN es incorrecto.' });
        }

         const payload = {
            userId: user._id,
            numero_cuenta: user.numero_cuenta
        };

        const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' }); 

         res.status(200).json({
            msg: 'Inicio de sesión exitoso',
            token
        });

    } catch (error) {
        console.error(error.message);
        res.status(500).json({ msg: 'Error en el servidor' });
    }
};


export const getUserInfo = async (req, res) => {
    try {
        const userId = req.user;  

        const user = await User.findById(userId);
        
        if (!user) {
            return res.status(404).json({ msg: 'Usuario no encontrado.' });
        }

        res.status(200).json({
            msg: 'Información del usuario obtenida exitosamente',
            user 
        });

    } catch (error) {
        console.error(error.message);
        res.status(500).json({ msg: 'Error en el servidor' });
    }
};