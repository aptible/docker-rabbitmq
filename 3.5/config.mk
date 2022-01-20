export ALPINE_VERSION = 3.5

export MAJOR = 3
export MINOR = 5
export REVISION = 8

export RABBITMQ_VERSION = $(MAJOR).$(MINOR).$(REVISION)
export RABBITMQ_PLUGINS = $(MAJOR).$(MINOR).x
export RABBITMQ_SHA1SUM = 5e89d61291b4bc6865097fa57c92e5214dce239a
export ARCHIVE_FORMAT = gz
export RABBITMQ_DOWNLOAD_URL = https://github.com/rabbitmq/rabbitmq-server/releases/download/rabbitmq_v$(MAJOR)_$(MINOR)_$(REVISION)/rabbitmq-server-generic-unix-$(RABBITMQ_VERSION).tar.$(ARCHIVE_FORMAT)

export PLUGIN_FORMAT = ez
export DELAYED_MESSAGE_EXCHANGE_VERSION = 0.0.1-rmq$(RABBITMQ_PLUGINS)-9bf265e4
export DELAYED_MESSAGE_EXCHANGE_SHA1SUM = 76926ef077c2cedb25e026369528ac293dbf0f41
export DELAYED_MESSAGE_PLUGIN_DOWNLOAD = https://dl.bintray.com/rabbitmq/community-plugins/rabbitmq_delayed_message_exchange-$(DELAYED_MESSAGE_EXCHANGE_VERSION).$(PLUGIN_FORMAT)

export ERLANG_APK_PACKAGES="erlang erlang-mnesia erlang-public-key erlang-crypto erlang-ssl erlang-sasl erlang-asn1 erlang-inets erlang-os-mon erlang-xmerl erlang-eldap"
