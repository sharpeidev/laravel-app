# Usa a imagem FPM do PHP 8.2
FROM php:8.2-fpm

# Atualiza a lista de pacotes e instala as dependências necessárias
RUN apt-get update && apt-get install -y \
    curl \
    git \
    libzip-dev \
    unzip \
    libonig-dev \
    libpq-dev

# Habilita o módulo MySQL no PHP
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-enable pdo_mysql

# Habilita o módulo ZIP no PHP
RUN docker-php-ext-install zip

# Habilita o módulo BCMath no PHP
RUN docker-php-ext-install bcmath

# Habilita o módulo PostgreSQL no PHP
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-install pdo pdo_pgsql pgsql

# Instala o Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Configura o diretório de trabalho inicial
WORKDIR /usr/share/nginx

# Apaga e recria pasta padrão do NGINX
RUN rm -rf html \
    && mkdir html

# Configura o diretório de trabalho inicial
WORKDIR /usr/share/nginx/html

# Copia o arquivo composer.json para o container
COPY composer.json .

# Instala as dependências do Laravel usando o composer
RUN composer install --no-plugins --no-scripts

# Copia os arquivos do aplicativo para o container
COPY . .

# Instala o Node Package Manager
RUN apt-get install -y npm

# Instala dependências do Node
RUN npm install

# Define as permissões necessárias para o Laravel
RUN chown -R www-data:www-data /usr/share/nginx/html

# Define o usuário padrão como www-data
USER www-data

# Cria link simbólico para a pasta "public"
RUN ln -s public html

# Configura permissões de escrita para "storage" e "bootstrap/cache"
RUN chmod -R 775 storage \
    && chmod -R 777 storage/logs \
    && chmod -R 775 bootstrap/cache

# Cria o .env
RUN cp .env.example .env

# Cria a app key do Laravel
RUN php artisan key:generate

# Expoe a porta 9000
EXPOSE 9000

# Define o comando padrão do container
CMD ["php-fpm"]
