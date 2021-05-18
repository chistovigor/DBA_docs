-- connect as sys in remote DB and run the following sql for the DB_LINK user

GRANT "IMP_FULL_DATABASE","EXP_FULL_DATABASE" TO DB_LINK_user;
ALTER USER DB_LINK_user DEFAULT ROLE "CONNECT", "EXP_FULL_DATABASE", "IMP_FULL_DATABASE";