# docker-dspace
[![Docker Images](https://github.com/cuhk-library-lits/docker-dspace/actions/workflows/deploy.yml/badge.svg)](https://github.com/cuhk-library-lits/docker-dspace/actions/workflows/deploy.yml)

## Docker images for
- DSpace backend: **docker-dspace**
- Default DSpace frontend: **docker-dspace-angular**

### Backend (docker-dspace)

#### Required docker external network
- `dspace_network`: Overlay

#### Required docker external configs
- `haproxy.cfg`: Contents of **haproxy.cfg**
- `initdb.sql`: Contents of **initdb.sql**

#### Required docker external secrets
- `dspace_db_password`
- `dspace_smtp_password`
- A secret containing SSL certificate for HTTPS defined by environment variable **SSL_PEM_SECRET**

#### Container environment variables
- The container will add any environment variables starting with `DSPACE_CFG_` to **local.cfg** by converting the variable name in the following convention:
1. Remove prefix `DSPACE_CFG_`.
2. Replace all `__` with `-`.
3. Replace all `_` with `.`.
4. Character casing are **preserved** to cater for case sensitive variables.
5. Environment variables ending with `_FILE` are expected to be files (E.g. mounted via docker secret) containing the value of the corresponding variables.

- Example
  ```
  DSPACE_CFG_dspace_name → dspace.name
  DSPACE_CFG_plugin_sequence_org_dspace_authenticate_AuthenticationMethod → plugin.sequence.org.dspace.authenticate.AuthenticationMethod
  DSPACE_CFG_authentication__ip_Group → authentication-ip.Group
  DSPACE_CFG_db_password_FILE → db.password (Value obtained from content of the corresponding file)
  ```

### Frontend (docker-dspace-angular)

#### Default theme
- If the image is used directly, default DSpace theme will be applied.

#### Building Frontend with customized theme

- The following example builds from the docker image with default frontend `7.5`.
- Create the following `Dockerfile` alongside the `themes` folder which contains the customized theme folder.

- **Dockerfile**
  ```
  FROM ghcr.io/cuhk-library-lits/docker-dspace-angular:7.5 AS build-frontend-7.5
  COPY  --chown=node  ./themes/.  /usr/src/app/src/themes/
  USER node
  RUN rm -rf dist && \
      yarn install && \
      yarn build:prod

  FROM node:16-slim
  COPY --from=build-frontend-7.5  --chown=node  /usr/src/app/dist  /usr/src/app/dist
  USER node
  EXPOSE 4000
  WORKDIR /usr/src/app
  CMD [ "node", "/usr/src/app/dist/server/main.js" ]
  ```

&nbsp;

## Docker stack
-  Expected environment variables for the sample **docker-compose.yml** stack (`*` = madatory)

| Variable                       | Description                                                  | Alternative                                         |
| ------------------------------ | ------------------------------------------------------------ | --------------------------------------------------- |
| **REST_HOST`*`**               | Host name of DSpace backend for the frontend                 |                                                     |
| **REST_NAMESPACE`*`**          | Base path of DSPace backend (E.g. /server) for the frontend  |                                                     |
| **ADMIN_EMAIL`*`**             | Email address for initial administrator account              | Use **ADMIN_EMAIL_FILE** if using docker secret     |
| **ADMIN_PASSWORD`*`**          | Password for initial administrator account                   | Use **ADMIN_PASSWORD_FILE** if using docker secret  |
| **ADMIN_FIRSTNAME**            | First name for initial administrator account (default: N/A)  | Use **ADMIN_FIRSTNAME_FILE** if using docker secret |
| **ADMIN_LASTNAME**             | Last name for initial administrator account (default: N/A)   | Use **ADMIN_LASTNAME_FILE** if using docker secret  |
| **DSPACE_NAME`*`**             | DSpace site name                                             |                                                     |
| **DSPACE_SERVER_URL`*`**       | DSpace backend full URL                                      |                                                     |
| **DSPACE_UI_URL`*`**           | DSpace frontend full URL                                     |                                                     |
| **SMTP_HOST`*`**               | Host name for SMTP server                                    |                                                     |
| **SMTP_USER`*`**               | User name for SMTP login                                     |                                                     |
| **DEFAULT_LANGUAGE**           | Default language (E.g. en)                                   |                                                     |
| **HANDLE_PREFIX**              | Unique UUID handle (or valid handle from handle.net)         |                                                     |
| **MAIL_FROM_ADDRESS**          | Email from address                                           |                                                     |
| **MAIL_ADMIN_ADDRESS**         | Email admin address                                          |                                                     |
| **USER_DOMAIN_VALID**          | Only allow user from specified domain                        |                                                     |
| **GOOGLE_ANALYTICS_KEY**       | Enabling Google Analytics by setting the key value           |                                                     |
| **DSPACE_INIT_STUCTURE_FILE**  | File path for initial community/collection structure in XML  |                                                     |
| **ENTITY_MODELS_FILE**         | File path for entity model definitions in XML                |                                                     |
| **SSL_PEM_SECRET**             | The secret containing SSL certificate for HTTPS              |                                                     |
