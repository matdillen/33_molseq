`docker-compose up --build` 
`docker exec -it app_web_1 /bin/bash`
You are now in the docker container's shell, you should be in /code, then you can do: `cd django`, `python manage.py createsuperuser` to create a user for the admin interface
