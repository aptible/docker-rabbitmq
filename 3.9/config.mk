export ALPINE_VERSION = 3.8

export MAJOR = 3
export MINOR = 9
export REVISION = 12

export RABBITMQ_VERSION = $(MAJOR).$(MINOR).$(REVISION)
export RABBITMQ_PLUGINS = $(MAJOR).$(MINOR).x
export RABBITMQ_SHA1SUM = 12a8b8a2368c87de5296508039b4d20d68f19d11
export ARCHIVE_FORMAT = xz
export RABBITMQ_DOWNLOAD_URL = https://github.com/rabbitmq/rabbitmq-server/releases/download/v$(RABBITMQ_VERSION)/rabbitmq-server-generic-unix-$(RABBITMQ_VERSION).tar.$(ARCHIVE_FORMAT)

export PLUGIN_FORMAT = zip
export DELAYED_MESSAGE_EXCHANGE_VERSION = 3.9.0
export DELAYED_MESSAGE_EXCHANGE_SHA1SUM = 45a02bca2ddc8f8b38fb41faed159160d39ba530
export DELAYED_MESSAGE_PLUGIN_DOWNLOAD = https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/archive/refs/tags/${DELAYED_MESSAGE_EXCHANGE_VERSION}.${PLUGIN_FORMAT}
