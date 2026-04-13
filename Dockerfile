FROM tomcat:11.0.8
RUN rm -rf /opt/tomcat/tomcat-11/webapps/*

COPY target/StudentManagementApp-1.4-SNAPSHOT.war /opt/tomcat/tomcat-11/webapps/studentapp.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
