class ServerBuilder
	@@apps = []
	@@server_configs = []

	class << self
		attr_accessor :capistrano

		def build_applications(node)
			node[:active_applications] = {}
			@@apps.each { |app| app.call(node[:active_applications]) }
		end

		def build_server_config(node)
			@@server_configs.each { |config| config.call(node) }
		end

		def build_app(&block)
			@@apps << block
		end
		def server_config(&block)
			@@server_configs << block
		end

		def build
			node = {}
			build_server_config(node)
			build_applications(node)
			node
		end
	end
end