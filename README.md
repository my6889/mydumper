## mydumper
此项目可以备份`Mysql数据库`的`全库`、`指定库`、`指定库的指定表`，备份后可以选择将备份文件同步到`AWS S3`、`阿里云OSS`、`腾讯云COS对象存储`上,
如果不指定对象存储，则会把备份文件保存到本地。         

### 如何使用
**克隆项目**
```
$ git clone https://github.com/my6889/mydumper
```
**设置环境变量**      
详情见mydumper.env文件

**启动备份**
```
docker-compose up
```
