# Copyright 2015 Google, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

defmodule Strabo.Router do
  use Strabo.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Strabo do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", Strabo do
    pipe_through :api
    get "/", PageController, :api_index

    get "/query", QueryController, :run

    get "/admin/shapefiles", ShapefileController, :show_shapefiles
    post "/admin/shapefiles/install", ShapefileController, :install_shapefile
    post "/admin/shapefiles/uninstall", ShapefileController, :uninstall_shapefile

    post "/location", LocationController, :create
    post "/location/batch", LocationController, :upload
  end
end
