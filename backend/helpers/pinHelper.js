import bcrypt from 'bcryptjs';

const salt = await bcrypt.genSalt(10);
const hashedPin = await bcrypt.hash(pin, salt);

newUser.pin = hashedPin;
