import Ahorro from '../models/ahorro.js';
import User from '../models/users.js';
import { validationResult } from 'express-validator';
import nodemailer from 'nodemailer';

 const generateAccountNumber = () => {
    return '1' + Math.floor(Math.random() * 1e12).toString().padStart(12, '0');
};

 export const crearCuentaAhorro = async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { userId, email, fullName } = req.body;

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ msg: 'Usuario no encontrado' });
        }

        const numeroCuenta = generateAccountNumber();

        const saldoInicial = 'RD $500';

        const nuevaCuenta = new Ahorro({
            userId,
            email,
            fullName,
            numeroCuenta,
            balance: saldoInicial
        });

        await nuevaCuenta.save();

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
            subject: 'Detalles de tu cuenta de ahorro',
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
                            <h1>¡Bienvenido a tu cuenta de ahorro, ${fullName}!</h1>
                            <p>Gracias por crear una cuenta de ahorro con nosotros. A continuación, te proporcionamos los detalles de tu cuenta:</p>
                            <ul>
                                <li><span class="highlight">Número de cuenta:</span> ${numeroCuenta}</li>
                                <li><span class="highlight">Saldo inicial:</span> ${saldoInicial}</li>
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

        res.status(201).json({ msg: 'Cuenta de ahorro creada exitosamente', nuevaCuenta });

    } catch (error) {
        console.error(error.message);
        res.status(500).json({ msg: 'Error en el servidor' });
    }
};

 export const obtenerCuentasAhorro = async (req, res) => {
    try {
        const cuentas = await Ahorro.find();
        res.status(200).json({ cuentas });
    } catch (error) {
        console.error(error.message);
        res.status(500).json({ msg: 'Error en el servidor' });
    }
};

 export const obtenerCuentasAhorroPorUsuario = async (req, res) => {
    try {
        const { userId } = req.params;
        
         const cuentas = await Ahorro.find({ userId });
        
        if (!cuentas || cuentas.length === 0) {
            return res.status(404).json({ msg: 'No se encontraron cuentas de ahorro' });
        }

         res.status(200).json({ cuenta: cuentas });
    } catch (error) {
        console.error(error.message);
        res.status(500).json({ msg: 'Error en el servidor' });
    }
};


 export const actualizarSaldoAhorro = async (req, res) => {
    try {
        const { userId, nuevoSaldo } = req.body;

        const cuenta = await Ahorro.findOne({ userId });
        if (!cuenta) {
            return res.status(404).json({ msg: 'Cuenta no encontrada' });
        }

        cuenta.balance = nuevoSaldo;
        await cuenta.save();

        res.status(200).json({ msg: 'Saldo actualizado exitosamente', cuenta });
    } catch (error) {
        console.error(error.message);
        res.status(500).json({ msg: 'Error en el servidor' });
    }
};
