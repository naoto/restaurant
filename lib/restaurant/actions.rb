module Restaurant
  module Actions
    def self.included(base)
      base.before_filter :require_resource, :only => [:show, :update, :destroy]
      base.rescue_from Moped::Errors::InvalidObjectId do
        head 404
      end
    end

    def index
      respond_with collection.find
    end

    def show
      respond_with @resource
    end

    def create
      collection.insert(resource_params.merge(:_id => resource_id))
      respond_with collection.find(:_id => resource_id).first, :location => { :action => :show, :id => resource_id }
    end

    def update
      respond_with collection.find(:_id => resource_id).update(:$set => resource_params)
    end

    def destroy
      respond_with collection.find(:_id => resource_id).remove_all
    end

    private

    def require_resource
      @resource = collection.find(:_id => resource_id).first || head(404)
    end

    def collection
      Mongoid.default_session[resources_name]
    end

    def resource_name
      resources_name.singularize
    end

    def resources_name
      params[:resource]
    end

    def resource_params
      params[resource_name]
    end

    def resource_id
      @resource_id ||= begin
        if params[:id]
          Moped::BSON::ObjectId.from_string(params[:id])
        else
          Moped::BSON::ObjectId.new
        end
      end
    end
  end
end
