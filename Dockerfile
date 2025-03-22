FROM tomcat:9.0.73-jdk11
COPY target/tesla.war /usr/local/tomcat/webapps/
EXPOSE 8080
CMD ["catalina.sh", "run"]