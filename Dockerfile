# Use latest wordpress image
FROM wordpress:latest

# Install default-mysql-client to be able to run mysql commands
RUN apt-get update && apt-get install -y default-mysql-client