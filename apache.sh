#1. Installation des dépendances
apt install build-essential libssl-dev libxml2-dev libpcre3-dev libpcre2-dev libapr1-dev libaprutil1-dev ssl-cert uuid -y

#2. Copie des fichiers binaires dans le répertoire /opt
wget https://archive.apache.org/dist/httpd/httpd-2.4.49.tar.gz -P /opt

#3. Déplacement dans le dossier /opt
cd /opt

#4. Décompression et déplacement dans le dossier décompressé Apache
tar -xf httpd-2.4.49.tar.gz
cd httpd-2.4.49

#5. Renommage/Sauvegarde du fichier layout existant 
mv config.layout config.layout.bak

#6. Création d'un nouveau fichier layout avec customisation Debian
cat > config.layout << 'EOF'
##
##  config.layout -- Pre-defined Installation Path Layouts
##

#   Classical Apache path layout.
<Layout Apache>
    prefix:        /usr/local/apache2
    exec_prefix:   ${prefix}
    bindir:        ${exec_prefix}/bin
    sbindir:       ${exec_prefix}/bin
    libdir:        ${exec_prefix}/lib
    libexecdir:    ${exec_prefix}/modules
    mandir:        ${prefix}/man
    sysconfdir:    ${prefix}/conf
    datadir:       ${prefix}
    installbuilddir: ${datadir}/build
    errordir:      ${datadir}/error
    iconsdir:      ${datadir}/icons
    htdocsdir:     ${datadir}/htdocs
    manualdir:     ${datadir}/manual
    cgidir:        ${datadir}/cgi-bin
    includedir:    ${prefix}/include
    localstatedir: ${prefix}
    runtimedir:    ${localstatedir}/logs
    logfiledir:    ${localstatedir}/logs
    proxycachedir: ${localstatedir}/proxy
</Layout>

# Debian layout
<Layout Debian>
    prefix:        
    exec_prefix:   ${prefix}/usr
    bindir:        ${exec_prefix}/bin
    sbindir:       ${exec_prefix}/sbin
    libdir:        ${exec_prefix}/lib
    libexecdir:    ${exec_prefix}/lib/apache2/modules
    mandir:        ${exec_prefix}/share/man
    sysconfdir:    ${prefix}/etc/apache2
    datadir:       ${exec_prefix}/share/apache2
    iconsdir:      ${datadir}/icons
    htdocsdir:     ${prefix}/var/www/html
    manualdir:     ${datadir}/manual
    cgidir:        ${prefix}/usr/lib/cgi-bin
    includedir:    ${exec_prefix}/include/apache2
    localstatedir: ${prefix}/var/lock/apache2
    runtimedir:    ${prefix}/var/run/apache2
    logfiledir:    ${prefix}/var/log/apache2
    proxycachedir: ${prefix}/var/cache/apache2/proxy
    infodir:       ${exec_prefix}/share/info
    installbuilddir: ${prefix}/usr/share/apache2/build
    errordir:      ${datadir}/error
</Layout>
EOF

#7. Configuration et préparation compilation Debian avec nom de programme Apache2, afin de réfleter une installation classique Debian
./configure --enable-layout=Debian --with-program-name=apache2

#8. Compilation et installation Apache 
make && make install

#9 Installation du service Apache

cp /usr/sbin/apachectl /etc/init.d
/usr/sbin/update-rc.d -f apachectl defaults

#9.. Création du fichier du service Apache

cat > /etc/systemd/system/apache2.service << EOF
[Unit]
Description=The Apache Webserver
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
ExecStart=/usr/sbin/apachectl start
ExecReload=/usr/sbin/apachectl reload
ExecStop=/usr/sbin/apachectl stop
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

#10. Modification du fichier de configuration (complétion variable ServerRoot)

sed -i 's/ServerRoot ".*/ServerRoot "\/etc\/apache2"/' /etc/apache2/apache2.conf

#11. Activation du service Apache et démarrage du service

systemctl daemon-reload
systemctl enable apache2.service
systemctl start apache2

