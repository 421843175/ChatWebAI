# 前端/Dockerfile
FROM nginx:alpine

# 删除默认配置
RUN rm /etc/nginx/nginx.conf

# 拷贝前端静态文件和 Nginx 配置 这里是从宿主机拷贝到容器
COPY dist/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
