-include .postgres.env

postgres_env:
	echo "POSTGRES_USER=stringer\nPOSTGRES_PASSWORD=`pwgen -s 20`\nPOSTGRES_HOSTNAME=stringer-postgres\nPOSTGRES_DB=stringer\n" >> .postgres.env

stringer_env:
	echo "SECRET_KEY_BASE=`openssl rand -hex 64`\nENCRYPTION_PRIMARY_KEY=`openssl rand -hex 64`\nENCRYPTION_DETERMINISTIC_KEY=`openssl rand -hex 64`\nENCRYPTION_KEY_DERIVATION_SALT=`openssl rand -hex 64`\n\nDATABASE_URL=postgres://`echo ${POSTGRES_USER}`:`echo ${POSTGRES_PASSWORD}`@`echo ${POSTGRES_HOSTNAME}`/`echo ${POSTGRES_DB}`\nFETCH_FEEDS_CRON='*/5 * * * *'\nCLEANUP_CRON='0 0 * * *'\n" >> .stringer.env
