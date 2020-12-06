FROM openjdk:8-jdk-alpine
EXPOSE 8080
ADD target/toDoAppWithLogin.jar toDoAppWithLogin.jar
ENTRYPOINT ["java","-jar","/toDoAppWithLogin.jar"]
