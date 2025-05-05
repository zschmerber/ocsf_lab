
!/bin/bash
set -e 
clickhouse client -n <<-EOSQL
CREATE OR REPLACE TABLE dns_activity ( class_name string, time_dt Date);
EOSQL
