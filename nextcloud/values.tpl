image:
  repository: gcr.io/${gcp_project}/nextcloud
  tag: 21.0.1-apache

ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx

nextcloud:
  host: nextcloud.kube.home
  existingSecret:
    secretName: nextcloud-admin
    usernameKey: username
    passwordKey: password
  configs:
    gcs.config.php: |-
      <?php
      $CONFIG = array(
        'objectstore' => array(
          'class' => '\\OC\\Files\\ObjectStore\\S3',
          'arguments' => array(
            'bucket'         => '${gcp_project}-nextcloud-external-data',
            'autocreate'     => false,
            'key'            => '${storage_key}',
            'secret'         => '${storage_secret}',
            'hostname'       => 'storage.googleapis.com',
            'region'         => 'auto',
            'use_ssl'        => true,
            'use_path_style' => false,
          )
        )
      );
    memorystore.config.php: |-
      <?php
      $CONFIG = array(
        'memcache.local' => '\OC\Memcache\Redis',
        'redis' => array(
          'host' => '${redis_ip_address}',
          'port' => 6379,
        ),
      );
internalDatabase:
  enabled: false

externalDatabase:
  enabled: true
  type: mysql
  host: ${mysql_ip_address}
  database: nextcloud
  existingSecret:
    secretName: nextcloud-mysql
    usernameKey: username
    passwordKey: password

service:
  type: NodePort
  nodePort: 30000

persistence:
  enabled: true