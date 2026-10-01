FROM wordpress:latest

# Fix Apache "More than one MPM loaded" on Railway.
# Railway can leave both mpm_event and mpm_prefork enabled;
# mod_php requires mpm_prefork only.
# Disable event/worker at runtime, then run the official WordPress entrypoint
# so /var/www/html is populated and wp-config.php is generated correctly.

CMD ["bash", "-c", "\
  a2dismod mpm_event mpm_worker 2>/dev/null || true; \
  rm -f /etc/apache2/mods-enabled/mpm_event.* /etc/apache2/mods-enabled/mpm_worker.* 2>/dev/null || true; \
  a2enmod mpm_prefork 2>/dev/null || true; \
  exec docker-entrypoint.sh apache2-foreground \
"]
