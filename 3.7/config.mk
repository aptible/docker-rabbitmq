export ALPINE_VERSION = 3.8

export MAJOR = 3
export MINOR = 7
export REVISION = 15

export RABBITMQ_VERSION = $(MAJOR).$(MINOR).$(REVISION)
export RABBITMQ_PLUGINS = $(MAJOR).$(MINOR).x
export RABBITMQ_SHA1SUM = 2a951144d590a4328e5190d6005e044f1416d5f1
export ARCHIVE_FORMAT = xz
export RABBITMQ_DOWNLOAD_URL = https://github.com/rabbitmq/rabbitmq-server/releases/download/v$(RABBITMQ_VERSION)/rabbitmq-server-generic-unix-$(RABBITMQ_VERSION).tar.$(ARCHIVE_FORMAT)

export PLUGIN_FORMAT = zip
export DELAYED_MESSAGE_EXCHANGE_VERSION = 20171201-$(RABBITMQ_PLUGINS)
export DELAYED_MESSAGE_EXCHANGE_SHA1SUM = b878e3f5bcd80e90e73d01f672f9ead022141275
export DELAYED_MESSAGE_PLUGIN_DOWNLOAD = https://dl.bintray.com/rabbitmq/community-plugins/$(RABBITMQ_PLUGINS)/rabbitmq_delayed_message_exchange/rabbitmq_delayed_message_exchange-$(DELAYED_MESSAGE_EXCHANGE_VERSION).$(PLUGIN_FORMAT)
