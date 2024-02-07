# 使用官方的 Ubuntu 最新长期支持版本作为基础镜像
FROM ubuntu:latest

# 环境变量已通过envsubst设置
ENV SCRAPE_INTERVAL=15
ENV EVALUATION_INTERVAL=15
ENV PROMETHEUS_HOST=localhost
ENV PROMETHEUS_PORT=9090

# 添加镜像元数据标签
LABEL maintainer="lja"
LABEL version="1.0.0"
LABEL description="A Docker image with Ubuntu and Prometheus."

# 更新系统软件包及安装wget
RUN apt-get update && \
    apt-get install -y wget gettext-base && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 设置Prometheus用户及目录
RUN useradd -m -s /bin/false prometheus && \
    mkdir /etc/prometheus && \
    mkdir /usr/local/prometheus && \
    chown -R prometheus /etc/prometheus && \
    chown -R prometheus /usr/local/prometheus && \
    chown -R prometheus /home/prometheus

# 设置工作目录
WORKDIR /home/prometheus

# 下载并安装Prometheus
RUN wget https://hub.yzuu.cf/prometheus/prometheus/releases/download/v2.49.1/prometheus-2.49.1.linux-amd64.tar.gz && \
    tar -xvzf prometheus-2.49.1.linux-amd64.tar.gz && \
    mv prometheus-2.49.1.linux-amd64/* /usr/local/prometheus && \
    cd /usr/local/prometheus && \
    chmod +x prometheus && \
    cp prometheus.yml /etc/prometheus/ && \
    chmod 777 /etc/prometheus/prometheus.yml && \
    rm -rf /home/prometheus/prometheus-2.49.1.linux-amd64*

# Prometheus配置应用文件复制到容器内部的工作目录下
COPY prometheus.yml /home/prometheus/

# 赋予文件权限
RUN chmod 777 /home/prometheus/prometheus.yml

# 配置默认环境变,命令无效
#RUN ["bash", "-c", "envsubst < /home/prometheus/prometheus.yml > /etc/prometheus/prometheus.yml"]
#RUN envsubst < /home/prometheus/prometheus.yml > /etc/prometheus/prometheus.yml

# 切换用户到Prometheus用户
USER prometheus

# 运行prometheus应用
CMD ["bash", "-c", "envsubst < /home/prometheus/prometheus.yml > /etc/prometheus/prometheus.yml && /usr/local/prometheus/prometheus --config.file=/etc/prometheus/prometheus.yml"]

# 可选：添加健康检查命令

# 启动命令
# docker run -d --name=ljaprometheus7 -p 9090:9090   -e SCRAPE_INTERVAL=15   -e EVALUATION_INTERVAL=15   -e PROMETHEUS_HOST=localhost   -e PROMETHEUS_PORT=9090   lja/prometheus