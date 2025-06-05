json.extract! tenancy, :id, :user_id, :room_id, :start_date, :end_date, :comments, :created_at, :updated_at
json.url tenancy_url(tenancy, format: :json)
