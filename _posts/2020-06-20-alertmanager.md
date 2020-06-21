---\ncategories: General\n---\n
# 知识点总结

## 1 http router v.s. net/http中的默认mux

- 性能高，内存小

- radix tree，采用压缩动态词典树进行路由算法的匹配

- gin是基于http router的

## 2 gin框架回顾

## 2.1 知识点回顾（github）

- 对路由分组，grouping routes
- 可以使用middleware，可以对分组使用middleware
- 优雅重启

## 2.2 案例回顾（https://book.eddycjy.com/golang/gin/api-01.html）

### 2.2.1 应用的配置管理方案：viper

- 统一的配置管理方案
- 基本支持所有的常见配置文件格式
- 支持与flag的适配
- 支持远程配置读取（etcd/consul），可以watch配置变化
- 支持参数重命名

整体感觉，viper方案比flag好用

