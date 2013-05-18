module Restaurant
  module Actions
    def self.included(base)
      base.before_filter :require_valid_id, :require_resource, :only => [:show, :update, :destroy]
      base.before_filter :add_created_at, :only => :create
      base.before_filter :add_updated_at, :only => :update
    end

    def index
      respond_with collection.find(filter_params).sort(sort_params).skip(skip_params).limit(limit_params)
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

    def require_valid_id
      head 404 unless Moped::BSON::ObjectId.legal?(params[:id])
    end

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
      @resource_params ||= params[resource_name] || {}
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

    def filter_params
      params[:filter] || {}
    end

    def sort_params
      Hash[(params[:sort] || []).map {|key, value| [key, value.to_i] }]
    end

    def skip_params
      ([params[:page].to_i, 1].max - 1) * per_page
    end

    def limit_params
      per_page
    end

    def per_page
      10
    end

    def add_created_at
      resource_params[:created_at] = resource_params[:updated_at] = Time.now
    end

    def add_updated_at
      resource_params[:updated_at] = Time.now
    end
  end
end
