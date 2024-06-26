# Курсовая работа на профессии "DevOps-инженер с нуля" - `Курапов Антон`
## Задача

Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в Yandex Cloud.

### Инфраструктура

Для развёртки инфраструктуры используйте Terraform и Ansible.
Параметры виртуальной машины (ВМ) подбирайте по потребностям сервисов, которые будут на ней работать.
Ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. Пункты взаимосвязаны и могут влиять друг на друга.

### Сайт

Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.
Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.
Создайте Target Group, включите в неё две созданных ВМ.
Создайте Backend Group, настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.
Создайте HTTP router. Путь укажите — /, backend group — созданную ранее.
Создайте Application load balancer для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.
Протестируйте сайт curl -v <публичный IP балансера>:80

### Мониторинг

Создайте ВМ, разверните на ней Prometheus. На каждую ВМ из веб-серверов установите Node Exporter и Nginx Log Exporter. Настройте Prometheus на сбор метрик с этих exporter.
Создайте ВМ, установите туда Grafana. Настройте её на взаимодействие с ранее развернутым Prometheus. Настройте дешборды с отображением метрик, минимальный набор — Utilization, Saturation, Errors для CPU, RAM, диски, сеть, http_response_count_total, http_response_size_bytes. Добавьте необходимые tresholds на соответствующие графики.

### Логи

Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch. 
Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

### Сеть

Разверните один VPC. Сервера web, Prometheus, Elasticsearch поместите в приватные подсети. Сервера Grafana, Kibana, application load balancer определите в публичную подсеть.
Настройте Security Groups соответствующих сервисов на входящий трафик только к нужным портам.
Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh. Настройте все security groups на разрешение входящего ssh из этой security group. Эта вм будет реализовывать концепцию bastion host. Потом можно будет подключаться по ssh ко всем хостам через этот хост.

### Резервное копирование

Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

### Дополнительно

Не входит в минимальные требования.
Для Prometheus можно реализовать альтернативный способ хранения данных — в базе данных PpostgreSQL. Используйте Yandex Managed Service for PostgreSQL. Разверните кластер из двух нод с автоматическим failover. Воспользуйтесь адаптером с https://github.com/CrunchyData/postgresql-prometheus-adapter для настройки отправки данных из Prometheus в новую БД.
Вместо конкретных ВМ, которые входят в target group, можно создать Instance Group, для которой настройте следующие правила автоматического горизонтального масштабирования: минимальное количество ВМ на зону — 1, максимальный размер группы — 3.
Можно добавить в Grafana оповещения с помощью Grafana alerts. Как вариант, можно также установить Alertmanager в ВМ к Prometheus, настроить оповещения через него.
В Elasticsearch добавьте мониторинг логов самого себя, Kibana, Prometheus, Grafana через filebeat. Можно использовать logstash тоже.
Воспользуйтесь Yandex Certificate Manager, выпустите сертификат для сайта, если есть доменное имя. Перенастройте работу балансера на HTTPS, при этом нацелен он будет на HTTP веб-серверов.


## Выполнение

### Инфраструктура - Сеть - Резервное копирование 

* Вся инфраструктура поднимается с помощью файла https://github.com/AntonKurapov66/course-work/blob/main/terraform/main.tf 
* С помощью скрипта https://github.com/AntonKurapov66/course-work/blob/main/terraform/output.sh формируется inventory.ini и некоторые yml-файлы ролей для Ansible.
* С помощью playbook  https://github.com/AntonKurapov66/course-work/blob/main/Ansible/bastion_update.yml происходит настройка bastion-host 
* Все ansible playbooks запускаются автоматически с помощью скрипта https://github.com/AntonKurapov66/course-work/blob/main/Ansible/run_playbooks_deploy.sh 
  * во время выполнения playbook по графане необходимо вначале войти в веб и авторизироваться под admin, это необходимо чтобы таска по добавлению дашборда отработала. 
* Shapshot расписание поднимается так же через terraform 

  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/01_0.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/01_1.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/01_3.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/01_3_1.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/01_3_2.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/01_2.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/01_2_1.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/01_4.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/01_4_1.PNG)

### Сайт

  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/02_5.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/02_4.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/02_0.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/02_1.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/02_2.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/02_3.PNG)

### Мониторинг

  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/03_1.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/03_2.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/03_3.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/03_0.PNG)

### Логи 

  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/04_0.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/04_1.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/04_2_1.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/04_2_2.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/04_2_3.PNG)
  * ![alt text](https://github.com/AntonKurapov66/course-work/blob/main/img/04_2.PNG)

* дополнительно настроил отслеживание логом prometheus, elasticsearch, kibana, grafana.
