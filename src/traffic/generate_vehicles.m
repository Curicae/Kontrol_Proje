function vehicle_queues = generate_vehicles(vehicle_queues, current_time, arrival_rates, current_arrival_profile, time_step_size)
% generate_vehicles - Simulates vehicle arrivals at the intersection
% Inputs:
%   vehicle_queues - Current state of vehicle queues in all directions
%   current_time - Current simulation time
%   arrival_rates - Structure containing arrival rates for different directions
%   current_arrival_profile - Current traffic profile ('peak' or 'normal')
%   time_step_size - Time step size of the simulation
% Output:
%   vehicle_queues - Updated vehicle queues with new arrivals

% Get the appropriate arrival rate field names based on current profile
north_rate_field = ['North_' current_arrival_profile];
south_rate_field = ['South_' current_arrival_profile];
east_rate_field = ['East_' current_arrival_profile];
west_rate_field = ['West_' current_arrival_profile];

% Custom Poisson distribution implementation
% For small lambda values, we can use the direct method
function n = custom_poisson(lambda)
    L = exp(-lambda);
    k = 0;
    p = 1;
    while p > L
        k = k + 1;
        p = p * rand();
    end
    n = k - 1;
end

% Generate new vehicles for each direction using custom Poisson distribution
% North direction
new_vehicles_north = custom_poisson(arrival_rates.(north_rate_field) * time_step_size);
vehicle_queues.north = [vehicle_queues.north; current_time * ones(new_vehicles_north, 1)];

% South direction
new_vehicles_south = custom_poisson(arrival_rates.(south_rate_field) * time_step_size);
vehicle_queues.south = [vehicle_queues.south; current_time * ones(new_vehicles_south, 1)];

% East direction
new_vehicles_east = custom_poisson(arrival_rates.(east_rate_field) * time_step_size);
vehicle_queues.east = [vehicle_queues.east; current_time * ones(new_vehicles_east, 1)];

% West direction
new_vehicles_west = custom_poisson(arrival_rates.(west_rate_field) * time_step_size);
vehicle_queues.west = [vehicle_queues.west; current_time * ones(new_vehicles_west, 1)];

% Display new arrivals if any
if new_vehicles_north > 0 || new_vehicles_south > 0 || new_vehicles_east > 0 || new_vehicles_west > 0
    fprintf('New vehicles arrived - North: %d, South: %d, East: %d, West: %d\n', ...
        new_vehicles_north, new_vehicles_south, new_vehicles_east, new_vehicles_west);
end

end 