FROM registry.redhat.io/rhel8/httpd-24:latest

# Add application sources
ADD index.html /var/www/html/index.html

ADD images /var/www/html/images

# The run script uses standard ways to run the application
CMD run-httpd

