Celero new CI 4 integration project.

old one
<VirtualHost *:80>
  DocumentRoot /var/www/celero/public
  ServerName 32038.hostserv.eu

  <Directory /var/www/celero/public>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
  </Directory>
RewriteEngine on
RewriteCond %{SERVER_NAME} =32038.hostserv.eu
RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>

<IfModule mod_rewrite.c>
RewriteEngine on

RewriteCond %{HTTPS} off
RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]

RewriteCond $1 !^(index\.php|resources|vendor|assets|css|js|img|images|robots\.txt)
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php?/$1 [QSA,L]
</IfModule>