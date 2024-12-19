import { validationResult } from 'express-validator';
import nodemailer from 'nodemailer';
import User from '../models/users.js';
import TarjetaCredito from '../models/TarjetaCredito.js'; 

const generateCardNumber = () => {
    return '4' + Math.floor(Math.random() * 1e15).toString().padStart(16, '0');
};

const calculateCutoffDate = () => {
    const currentDate = new Date();
    currentDate.setFullYear(currentDate.getFullYear() + 2); 
    return currentDate;
};

const formatDate = (date) => {
    return date.toLocaleDateString();
};

export const crearTarjetaCredito = async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { userId, fullName, email, cedula } = req.body; 

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ msg: 'Usuario no encontrado' });
        }

        if (!cedula) {
            return res.status(400).json({ msg: 'La cédula es requerida' });
        }

        const numeroTarjeta = generateCardNumber();

        const balanceInicial = 5000;

        const fechaCorte = calculateCutoffDate();
        
        const limiteCredito = 50000; 

        const nuevaTarjeta = new TarjetaCredito({
            userId,
            numeroTarjeta,
            limiteCredito,
            balanceActual: balanceInicial,
            fechaCorte,
            fullName,
            email,
            cedula  
        });

        await nuevaTarjeta.save();

         const ultimosDosDigitos = numeroTarjeta.slice(-2);

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
            subject: 'Tarjeta de Crédito Creada Exitosamente',
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
                            <h1>¡Bienvenido a tu tarjeta de crédito, ${fullName}!</h1>
                            <p>Gracias por confiar en nosotros. A continuación, te proporcionamos los detalles de tu nueva tarjeta de crédito:</p>
                            <ul>
                                <li><span class="highlight">Número de tarjeta:</span> **** **** **** ${numeroTarjeta.slice(-4)}</li>
                                <li><span class="highlight">Límite de crédito:</span> RD $${limiteCredito}</li>
                                <li><span class="highlight">Fecha de corte:</span> ${formatDate(fechaCorte)}</li>
                            </ul>
                            <p>Los últimos dos dígitos de tu tarjeta son: <span class="highlight">${ultimosDosDigitos}</span></p>
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

        res.status(201).json({ msg: 'Tarjeta de crédito creada exitosamente', nuevaTarjeta });

    } catch (error) {
        console.error(error.message);
        res.status(500).json({ msg: 'Error en el servidor' });
    }
};

export const obtenerTarjetasCreditoPorUsuario = async (req, res) => {
    try {
        const { userId } = req.params;

         const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

         const tarjetas = await TarjetaCredito.find({ userId });

        if (!tarjetas || tarjetas.length === 0) {
            return res.status(404).json({ msg: 'No se encontraron tarjetas de crédito' });
        }

         res.status(200).json({ tarjetas });

    } catch (error) {
        console.error(error.message);
        res.status(500).json({ msg: 'Error en el servidor' });
    }
};

export const eliminarTarjetaCredito = async (req, res) => {
    try {
        const { numeroTarjeta } = req.params;

         const tarjeta = await TarjetaCredito.findOneAndDelete({ numeroTarjeta });

        if (!tarjeta) {
            return res.status(404).json({ msg: 'Tarjeta de crédito no encontrada' });
        }

         const transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: process.env.EMAIL_USER,
                pass: process.env.EMAIL_PASS
            }
        });

         const mailOptions = {
            from: process.env.EMAIL_USER,
            to: tarjeta.email,  
            subject: 'Tarjeta de crédito eliminada exitosamente',
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
                                color: #cc0000;
                                font-size: 28px;
                            }
                            p {
                                font-size: 16px;
                                line-height: 1.6;
                            }
                            .highlight {
                                font-weight: bold;
                                color: #cc0000;
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
                        </style>
                    </head>
                    <body>
                        <div class="container">
                            <h1>Tu Tarjeta de Crédito ha sido Eliminada</h1>
                            <p>Hola ${tarjeta.fullName},</p>
                            <p>Queremos informarte que tu tarjeta de crédito terminada en ${tarjeta.numeroTarjeta.slice(-4)} ha sido eliminada correctamente.</p>
                            <p>Si no realizaste esta acción o tienes alguna duda, por favor contáctanos de inmediato.</p>
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

        res.status(200).json({ msg: 'Tarjeta de crédito eliminada exitosamente' });

    } catch (error) {
        console.error(error.message);
        res.status(500).json({ msg: 'Error en el servidor' });
    }
};
