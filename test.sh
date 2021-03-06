#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

nginx_exec() {
    docker-compose -f test/docker-compose.yml exec nginx "${@}"
}

check_endpoint() {
    nginx_exec curl -s -I "localhost/${1}" | grep -q "${2}"
    echo "OK"
}

docker-compose -f test/docker-compose.yml up -d

nginx_exec make check-ready -f /usr/local/bin/actions.mk

echo -n "Checking homepage endpoint... "
check_endpoint "" "302 Found"

echo -n "Checking setup page endpoint... "
check_endpoint "wp-admin/setup-config.php" "200 OK"

echo -n "Checking static endpoint (jpg)... "
check_endpoint "wp-content/themes/twentyseventeen/assets/images/coffee.jpg" "200 OK"

echo -n "Checking static endpoint (js)... "
check_endpoint "wp-content/themes/twentyseventeen/assets/js/global.js" "200 OK"

echo -n "Checking static endpoint (css)... "
check_endpoint "wp-content/themes/twentyseventeen/assets/css/editor-style.css" "200 OK"

echo -n "Checking readme.html endpoint... "
check_endpoint "readme.html" "404 Not Found"

echo -n "Checking static endpoint (txt)... "
check_endpoint "license.txt" "404 Not Found"

echo -n "Checking .htaccess endpoint... "
check_endpoint ".htaccess" "404 Not Found"

echo -n "Checking favicon endpoint... "
check_endpoint "favicon.ico" "204 No Content"

echo -n "Checking non-existing php endpoint... "
check_endpoint "non-existing.php" "404 Not Found"

docker-compose -f test/docker-compose.yml down