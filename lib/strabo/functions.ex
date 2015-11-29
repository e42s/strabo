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

defmodule Strabo.Functions do
  alias Strabo.Types, as: T
  alias Strabo.Util, as: U
  alias Strabo.DataAccess
  require Logger

  #####################
  # Generic Functions #
  #####################

  def map(function, %T.LocationSet{batch_id: batch_id}) do
    batch_id
    |> DataAccess.Locations.locations_from_batch
    |> Enum.map function
  end

  ######################
  # Location Functions #
  ######################

  @spec nearest_neighbors(%T.Location{}, %T.LocationSet{}, Integer) :: [%T.Location{}]
  def nearest_neighbors(%T.Location{lat: lat, lon: lon},
                        %T.LocationSet{batch_id: batch_id}, n) do
    DataAccess.Locations.get_nearest(lat, lon, batch_id, n)
  end

  @spec nearest_neighbor(%T.Location{}, %T.LocationSet{}) :: %T.Location{}
  def nearest_neighbor(%T.Location{lat: lat, lon: lon},
                       %T.LocationSet{batch_id: batch_id}) do
    [loc] = DataAccess.Locations.get_nearest(lat, lon, batch_id, 1)
    loc
  end

  @spec location(float, float) :: %T.Location{}
  def location(lat, lon) do
    {[:lat, :lon] = symbols, _} = T.Location.get_fields()
    points = Enum.map([lat, lon], &U.sanitize_float/1)

    T.Location.from_row(symbols, points)
  end

  @spec locations_from_batch(Integer) :: %T.LocationSet{}
  def locations_from_batch(batch_id) do
    %T.LocationSet{batch_id: batch_id}
  end

  @spec clear_location_set(%T.LocationSet{}) :: :ok
  def clear_location_set(%T.LocationSet{batch_id: batch_id}) do
    {:ok, num_rows_affected} = DataAccess.Locations.clear_batch(batch_id)
    %{num_rows_affected: num_rows_affected}
  end

  #######################
  # Shapefile Functions #
  #######################

  @spec surrounding_polygons(%T.Location{}, String.t) :: [%T.Polygon{}]
  def surrounding_polygons(location, shapefile_name) when is_binary(shapefile_name) do
    {:ok, shapefile} = DataAccess.Shapefiles.get_shapefile_by_name(shapefile_name)
    surrounding_polygons(location, shapefile)
  end


  @spec surrounding_polygons(%T.Location{}, %T.Shapefile{}) :: [%T.Polygon{}]
  def surrounding_polygons(location, shapefile) do
    DataAccess.Shapefiles.get_containing_shapes(location.lat,
                                                location.lon,
                                                shapefile)
  end
end
