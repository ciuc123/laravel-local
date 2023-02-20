#!/usr/bin/env sh
set -e

echo "env file exists."
if [ ! -f .env ]; then
  if [ -f .env.example ]; then
    cp .env.example .env
    echo "Created .env from .env.example"
  elif [ -f .env.bk ]; then
    cp .env.bk .env
    echo "Created .env from .env.bk"
  fi
fi

# Install vendors if missing
if [ ! -d vendor ]; then
  echo "Installing Composer dependencies..."
  composer install --no-interaction --prefer-dist
fi

# Generate key if missing
if ! grep -q "^APP_KEY=base64:" .env 2>/dev/null; then
  php artisan key:generate --force || true
fi

# Wait for DB if configured (best-effort)
if [ -n "$DB_HOST" ]; then
  echo "Waiting for database at $DB_HOST:$DB_PORT..."
  for i in 1 2 3 4 5 6 7 8 9 10; do
    php -r 'exit((bool)@fsockopen(getenv("DB_HOST")?: "127.0.0.1", getenv("DB_PORT")?: 3306) ? 0 : 1);' && break
    sleep 2
  done
fi

ROLE="${CONTAINER_ROLE:-app}"

case "$ROLE" in
  queue)
    echo "Running the queue ..."
    exec php artisan queue:work --verbose --tries=3 --timeout=90
    ;;
  app|web|php)
    echo "Starting Laravel dev server on 0.0.0.0:${PORT:-8000} ..."
    exec php artisan serve --host=0.0.0.0 --port="${PORT:-8000}"
    ;;
  *)
    echo "Unknown CONTAINER_ROLE '$ROLE', defaulting to app"
    exec php artisan serve --host=0.0.0.0 --port="${PORT:-8000}"
    ;;
esac
