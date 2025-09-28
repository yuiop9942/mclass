FROM openjdk:17-jdk

# JAR file 저장 dir 설정
WORKDIR /app

# maven 혹은 gradle 빌드 후 생성된 jar를 container 내부 /app dir에 app.jar로 복사
# = jenkins host에 생성된 app.jar를 container 내부 /app dir에 app.jar로 복사
COPY app.jar app.jar

#container의 외부 통신 port 설정 -> spring instance의 inbound port 설정한 값
EXPOSE 8081

# container 기동 시 자동으로 java -jar app.jar 명령 실행 설정
ENTRYPOINT ["java", "-jar", "app.jar"]

