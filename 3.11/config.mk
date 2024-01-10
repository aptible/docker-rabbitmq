export ALPINE_VERSION = 3.19

export MAJOR = 3
export MINOR = 11
export REVISION = 28

export RABBITMQ_VERSION = $(MAJOR).$(MINOR).$(REVISION)
export RABBITMQ_PLUGINS = $(MAJOR).$(MINOR).x
export RABBITMQ_SHA1SUM = fed77ae00c8dfffc83d2d3c7dac64402add9bf08
export ARCHIVE_FORMAT = xz
export RABBITMQ_DOWNLOAD_URL = https://github.com/rabbitmq/rabbitmq-server/releases/download/v$(RABBITMQ_VERSION)/rabbitmq-server-generic-unix-$(RABBITMQ_VERSION).tar.$(ARCHIVE_FORMAT)

export PLUGIN_FORMAT = ez
export DELAYED_MESSAGE_EXCHANGE_VERSION = 3.11.1
export DELAYED_MESSAGE_EXCHANGE_SHA1SUM = 83cf176f7f67d3d3e7f19f5de065a274f3f6dc9f
export DELAYED_MESSAGE_PLUGIN_DOWNLOAD = https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases/download/${DELAYED_MESSAGE_EXCHANGE_VERSION}/rabbitmq_delayed_message_exchange-${DELAYED_MESSAGE_EXCHANGE_VERSION}.${PLUGIN_FORMAT}

export ERLANG_APK_PACKAGES="erlang"
