# ETAPA 1: Construcción (Build)
# Usamos Node para compilar el código React (JSX -> HTML/JS)
FROM node:lts-alpine as build-stage
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# ETAPA 2: Producción (Nginx)
# Usamos un servidor web ligero para mostrar la web
FROM nginx:alpine as production-stage

# Copiamos la carpeta 'build' generada en la etapa 1 a la carpeta pública de Nginx
COPY --from=build-stage /app/build /usr/share/nginx/html

# CONFIGURACIÓN CRÍTICA PARA REACT (SPA):
# React maneja las rutas en el navegador. Si recargas una página interna (ej: /login),
# Nginx buscará ese archivo y dará error 404.
# Esta configuración redirige todo al index.html para que React se encargue.
RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html index.htm; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
