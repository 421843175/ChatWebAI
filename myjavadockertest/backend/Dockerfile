# backend/Dockerfile
FROM eclipse-temurin:17-jre-alpine

# 拷贝 JAR 包
COPY CHATWEBAI.jar /app.jar

# 暴露端口  这里有8091是因为我们现在服务是需要websocket 端口 8091
EXPOSE 8090 8091

# 启动命令
ENTRYPOINT ["java", "-jar", "/app.jar"]
