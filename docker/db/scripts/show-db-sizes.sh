psql -d ecoman_01_10 -c "SELECT pg_database.datname,pg_size_pretty(pg_database_size(pg_database.datname)) AS size FROM pg_database;"

#   datname    |  size   
# --------------+---------
# template1    | 6857 kB
# template0    | 6857 kB
# postgres     | 6976 kB
# ecoman_01_10 | 704 MB
#(4 rows)


