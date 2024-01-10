export ALPINE_VERSION = 3.19

export MAJOR = 3
export MINOR = 12
export REVISION = 12

export RABBITMQ_VERSION = $(MAJOR).$(MINOR).$(REVISION)
export RABBITMQ_PLUGINS = $(MAJOR).$(MINOR).x
export RABBITMQ_SHA1SUM = 6ea6557f0d756ada8cd3cf1758f6fc00efe49bde
export ARCHIVE_FORMAT = xz
export RABBITMQ_DOWNLOAD_URL = https://github.com/rabbitmq/rabbitmq-server/releases/download/v$(RABBITMQ_VERSION)/rabbitmq-server-generic-unix-$(RABBITMQ_VERSION).tar.$(ARCHIVE_FORMAT)

export PLUGIN_FORMAT = ez
export DELAYED_MESSAGE_EXCHANGE_VERSION = 3.12.0
export DELAYED_MESSAGE_EXCHANGE_SHA1SUM = 63f97ae850411da4d099611b83b040f962d47b67
export DELAYED_MESSAGE_PLUGIN_DOWNLOAD = https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases/download/${DELAYED_MESSAGE_EXCHANGE_VERSION}/rabbitmq_delayed_message_exchange-${DELAYED_MESSAGE_EXCHANGE_VERSION}.${PLUGIN_FORMAT}

export ERLANG_APK_PACKAGES="erlang"
