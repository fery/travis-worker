require 'faraday'

module Travis
  module Worker
    module Job
      # Build configuration job: read .travis.yml and return it
      class Config < Base
        attr_reader :config

        def start
        end

        def update(data)
          notify(:update, data)
        end

        def finish
          notify(:finish, :config => config)
        end

        protected

          def perform
            @config = fetch.merge('.configured' => true)
          end

          def fetch
            response = Faraday.get(url)
            response.success? ? parse(response.body) : {}
          end

          def url
            "#{repository.raw_url}/#{build.commit}/.travis.yml"
          end

          def parse(yaml)
            YAML.load(yaml) || {}
          rescue Exception => e
            # TODO should report this exception back as part of the log!
            {}
          end
      end
    end # Job
  end # Worker
end # Travis
