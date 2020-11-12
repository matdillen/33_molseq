`docker-compose up --build` 
`docker exec -it app_web_1 /bin/bash`
In the shell, `cd molseq`, `python manage.py migrate` to build the database, `python manage.py createsuperuser` to create a user for the admin interface
