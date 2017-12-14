require 'addressable/template'
require 'faraday'
require 'json'

module EversignClient
	class Client
		attr_accessor :access_key
		BUSINESS_PATH = 'https://api.eversign.com/api/business{?access_key}'
		DOCUMENT_PATH = 'https://api.eversign.com/api/document{?access_key,business_id,type}'
		
		def initialize(access_key)
			self.access_key = access_key
		end

		def list_buisnesses
	  	template = Addressable::Template.new(BUSINESS_PATH)
	  	response = Faraday.get template.partial_expand({access_key: access_key}).pattern
	  	extract_response(response.body, EversignClient::Mappings::Business)
		end

		def list_document(business_id, doc_type)
	  	template = Addressable::Template.new(DOCUMENT_PATH)
	  	url = template.partial_expand({access_key: access_key, business_id: business_id, type: doc_type}).pattern
	  	response = Faraday.get url
	  	extract_response(response.body, EversignClient::Mappings::Document)
		end

		private
			def extract_response(body, mapping)
				if JSON.parse(body).kind_of?(Array)
					mapping.extract_collection(body, nil)
				else
					EversignClient::Mappings::Exception.extract_single(body, nil)
				end
			end
	end
end