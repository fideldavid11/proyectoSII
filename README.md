## Capturas de la aplicacion 

## Login
![image](https://github.com/user-attachments/assets/fe7dae42-3efb-4b8f-90be-6398d3b519fd)

## Registro
![image](https://github.com/user-attachments/assets/b2dcfa66-680d-48d6-b4b9-e9bd5929f3d1)

## Inicio de sesion exitoso y menu de navegacion:
![image](https://github.com/user-attachments/assets/5e37e938-eee9-4acb-b0dc-5aa8dd05ada5)

## Para agregar una cuenta de ahorro el sistema las crea automaticamente:
## 1. Si le damos click aqui
![photo_2024-12-19_10-27-43](https://github.com/user-attachments/assets/edeb55ca-1d4f-43a8-84a2-7b8f66deee5b)

## 2. Aparecera esta pestaña:
![image](https://github.com/user-attachments/assets/ab04054b-4927-4efc-a535-460464c1629e)

## 3. Al darle a siguiente aparecera esto:
![image](https://github.com/user-attachments/assets/1cabda86-b10c-4511-a847-562ee90ff0bc)

## 4. Al hacerle click a siguiente se creara la cuenta mandando un correo electronico y aparecera en lista todas las cuentas de ahorro:
![image](https://github.com/user-attachments/assets/28e8ae91-f5e0-4852-aca2-5dda4c105721)

## 5. Si vamos a esta parte del menu: 
![photo_2024-12-19_10-27-43 (2)](https://github.com/user-attachments/assets/35894e05-6aec-43e1-b56f-08713468972b)

## 6. Aparecera esta pestaña:
![image](https://github.com/user-attachments/assets/93e0274a-e9b3-448b-9cc8-6de714aff036)

## 7. Al darle click a realizar solicitud aparece este formulario simple: (ya que en la data los campos se generan automaticamente y no hay necesidad de agregar otros campos)
![image](https://github.com/user-attachments/assets/32a1b791-6cca-46bb-ac15-c8cd9806209d)

## 8. Una vez realizada recibiras una notificacion via correo electronico con la informacion de las tarjetas de credito, en este ejemplo se crearon dos: 
![image](https://github.com/user-attachments/assets/51376c08-aa55-4abc-ad0d-8dba7c0284e2)
![image](https://github.com/user-attachments/assets/57126f6e-2610-472c-bc47-5e6809193482)

## 9. Ahora si vamos a esta parte del menu y hacemos clickc aqui aparecera lo que se ve en la siguiente foto: 
![photo_2024-12-19_10-27-43 (3)](https://github.com/user-attachments/assets/a1d02d28-bbdd-40eb-9a2f-5b42a87097b0)
![image](https://github.com/user-attachments/assets/bb58f2cb-d3f5-42a4-9879-e5078ca8584d)

## 10. Si le damos click a eliminar, se eliminara la tarjeta (en este ejemplo eliminaremos los dos) y estas apareceran en el correo: 
![image](https://github.com/user-attachments/assets/11399230-0b54-4c55-817b-d3badc9d130d)
![image](https://github.com/user-attachments/assets/69da01cd-1bf1-478a-91fc-cc6f14c8ce2b)

## Nota las APIs se estan ejecutando desde mi IP por ejemplo: `http://192.168.0.4:7575/api/users/login` para que funcionen deberias editar todas las APIS de esta forma: `http:<tu-IP>:7575/api/users/login`

## Backend 

## 1. Al clonar el repositorio abre una terminal y digita el comando `npm install` y presiona enter.

## 2. Al instalarse los modulos de node deberan agregarse las variables de entorno, estas deben crearse en el backend en un archivo `.env` las estare adjuntando en el correo electronico de la prueba.

## 3. Una vez todo configurado ejecutar el comando `npm run dev` y listo. 

## Funcionamiento:
- Algunas de las APIs estan configuradas para que el usuario pueda ver sus datos, no podra ver la informacion de otros usuarios.
- La aplicacion usa middlewares para regular los inicios de sesion y estan presentes el uso de authToken tanto en el backend como en la aplicacion misma.
- En la parte del cluster la parte del PIN esta encriptada tomando en cuenta medidas de seguridad en aplicaciones modernas como lo pueden ver aqui:
![image](https://github.com/user-attachments/assets/8feea9ac-f889-49df-b088-de6a74ca7335)



Video tutorial de la aplicacion en dispositivo fisico: https://drive.google.com/file/d/11ydctZ-bEZQXR9SuTWy9v0XgMyB5YGbX/view?usp=drivesdk


Captura del envio por correo de la tarjeta de credito eliminada: 
![image](https://github.com/user-attachments/assets/9177ee87-7307-43af-ac51-9e2a25021c0b)






