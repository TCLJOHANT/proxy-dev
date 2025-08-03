# 🔐 proxy-dev

Entorno de desarrollo local con HTTPS usando Docker y certificados personalizados.

Este Conetenedor te permite levantar un proxy inverso (basado en Nginx) para servir tus aplicaciones locales a través de HTTPS usando certificados generados con OpenSSL o `mkcert`.


🚀 ¿Cómo usar?
1. Elige un dominio local (ej: miapp.localhost o miapp.local)
Agrega una línea a tu archivo de hosts:
```
127.0.0.1 miapp.localhost
```

2. Generar certificados HTTPS
🛠 Opción A: Usar OpenSSL (autofirmado)

```
./generate-cert-openssl.sh miapp.localhost
```

Genera un certificado autofirmado para el dominio.

Puede mostrar advertencias de seguridad en el navegador.

No requiere instalar nada adicional.


✅ Opción B: Usar mkcert (recomendado)

```
./generate-cert-mycert.sh miapp.localhost
```

Genera certificados confiables (sin advertencias).

Necesita que mkcert esté instalado y registrado con mkcert -install.

Busca las popciones de intalacion, esta en culquieuiera de los sistemas operativos

3. Levantar el proxy

```
docker-compose up -d
```

Esto iniciará:

nginx-proxy: Contenedor que actúa como proxy inverso

Tu certificado será usado automáticamente para https://miapp.localhost

🧠 Notas importantes
Si usas OpenSSL, verás advertencias en el navegador porque el certificado no está firmado por una CA confiable.

Si usas mkcert, asegúrate de ejecutar mkcert -install al menos una vez en tu sistema.

Brave/Chrome a veces muestran advertencias extra en dominios .local. Usa .localhost o .lan para mejores resultados.


🔗 Cómo usar este proxy con otras aplicaciones
🐳 A. Con otros contenedores Docker locales
Asegúrate de que el otro contenedor esté en la misma red que el proxy:

# aca un ejemplo competo en donde
```yaml
services:
  miapp:
    image: tuimagen
    networks:
      - proxy-net-dev
    environment:
      - VIRTUAL_HOST=miapp.localhost #el dominio que quieras
      - VIRTUAL_PORT=80              # o el puerto interno que exponga tu app
      - HTTPS_METHOD=noredirect      # o redirect si quieres forzar HTTPS
    expose:
      - "80"

  # indicando que use una red externa (la del contenedor proxy-dev)
  networks:
    proxy-net-dev:
        external: true
```

💻 B. Con apps fuera de Docker (como XAMPP, Node.js, etc.)
Sí, también puedes usar este proxy con apps locales que no están en Docker, mientras estén accesibles desde localhost.

🔧 Pasos:
Tu app debe estar escuchando en localhost:PUERTO

Ej: Node en localhost:3000

Ej: XAMPP en localhost:8080

Crear un archivo de configuración de Nginx para esa app

Crea un archivo en ./vhost.d/miapp.localhost con algo como:

```nginx
location / {
  proxy_pass http://host.docker.internal:3000;
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
}

```

Esto redirige el tráfico desde el proxy al servicio local.

🔍 host.docker.internal funciona en macOS y Windows.
En Linux, puedes usar la IP del host o configurar una red host.

📂 Estructura típica del proyecto

proxy-dev/
├── certs/                     # Certificados generados (.crt y .key)
├── vhost.d/                   # Configuraciones personalizadas Nginx
├── generate-cert-openssl.sh   # Script para generar certificados con OpenSSL
├── generate-cert-mycert.sh    # Script para generar certificados con mkcert
├── docker-compose.yml         # Servicio nginx-proxy

#refrescar contenedor si crea mas certicficao y el serviio estaba levnatado,
```
  docker exec <nombre_o_id_contenedor_proxy-dev> nginx -s reload
```