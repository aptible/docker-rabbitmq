export ALPINE_VERSION = 3.16

export MAJOR = 3
export MINOR = 9
export REVISION = 29

export RABBITMQ_VERSION = $(MAJOR).$(MINOR).$(REVISION)
export RABBITMQ_PLUGINS = $(MAJOR).$(MINOR).x
export RABBITMQ_SHA1SUM = 9c63a1b0c5f000d04b8ddfd596843c313542e95d
export ARCHIVE_FORMAT = xz
export RABBITMQ_DOWNLOAD_URL = https://github.com/rabbitmq/rabbitmq-server/releases/download/v$(RABBITMQ_VERSION)/rabbitmq-server-generic-unix-$(RABBITMQ_VERSION).tar.$(ARCHIVE_FORMAT)

export PLUGIN_FORMAT = ez
export DELAYED_MESSAGE_EXCHANGE_VERSION = 3.9.0
export DELAYED_MESSAGE_EXCHANGE_SHA1SUM = 9716b10b19f6c8cbc5384b9253c7ed75d23995ba
export DELAYED_MESSAGE_PLUGIN_DOWNLOAD = https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases/download/${DELAYED_MESSAGE_EXCHANGE_VERSION}/rabbitmq_delayed_message_exchange-${DELAYED_MESSAGE_EXCHANGE_VERSION}.${PLUGIN_FORMAT}

export ERLANG_APK_PACKAGES="erlang"
