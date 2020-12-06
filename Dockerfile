FROM openjdk:8-jdk-alpine
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring
ARG DEPENDENCY=target/dependency
COPY ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY ${DEPENDENCY}/META-INF /app/META-INF
COPY ${DEPENDENCY}/BOOT-INF/classes /app
ADD target/toDoAppWithLogin.jar toDoAppWithLogin.jar
ENTRYPOINT ["java","-cp","app:DevOps/src/main/java/gr/athtech/toDoAppWithLogin/*","ToDoAppWithLoginApplication.java"]
