FROM postgres:17-alpine
COPY init-schema.sql /docker-entrypoint-initdb.d/