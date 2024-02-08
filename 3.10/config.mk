export ALPINE_VERSION = 3.18

export MAJOR = 3
export MINOR = 10
export REVISION = 25

export RABBITMQ_VERSION = $(MAJOR).$(MINOR).$(REVISION)
export RABBITMQ_PLUGINS = $(MAJOR).$(MINOR).x
export RABBITMQ_SHA1SUM = 563926d880a8ba2d5bc16b74a06dfdd9d4177e13
export ARCHIVE_FORMAT = xz
export RABBITMQ_DOWNLOAD_URL = https://github.com/rabbitmq/rabbitmq-server/releases/download/v$(RABBITMQ_VERSION)/rabbitmq-server-generic-unix-$(RABBITMQ_VERSION).tar.$(ARCHIVE_FORMAT)

export PLUGIN_FORMAT = ez
export DELAYED_MESSAGE_EXCHANGE_VERSION = 3.10.0
export DELAYED_MESSAGE_EXCHANGE_SHA1SUM = 42890017ee8987d1f5df4ce9b2472ec59b969457
export DELAYED_MESSAGE_PLUGIN_DOWNLOAD = https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases/download/${DELAYED_MESSAGE_EXCHANGE_VERSION}/rabbitmq_delayed_message_exchange-${DELAYED_MESSAGE_EXCHANGE_VERSION}.${PLUGIN_FORMAT}

export ERLANG_APK_PACKAGES="erlang"
