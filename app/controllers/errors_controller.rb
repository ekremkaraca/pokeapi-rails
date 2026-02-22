class ErrorsController < ActionController::API
  def not_found
    response.set_header("Cache-Control", "no-store")
    render plain: "Not Found\n", status: :not_found
  end
end
