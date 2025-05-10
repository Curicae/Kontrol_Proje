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

% API verilerini kullan (config'de tanımlanmışsa)
try
    % Config dosyasını yükle - yalnızca API ayarları için
    if exist('config.mat', 'file')
        % Değişken adı çakışmasını önlemek için farklı bir isimle yükle
        config_data = load('config.mat');
        config_settings = config_data.configuration;
        
        % API seçeneği etkinleştirildi mi kontrol et
        if isfield(config_settings, 'use_overpass') && config_settings.use_overpass || ...
           isfield(config_settings, 'use_osm') && config_settings.use_osm || ...
           isfield(config_settings, 'use_tomtom') && config_settings.use_tomtom
            
            % API güncelleştirme aralığını kontrol et
            persistent last_api_update;
            persistent api_traffic_data;
            
            if isempty(last_api_update) || ...
               (current_time - last_api_update >= config_settings.api_update_interval)
                % API'den trafik verilerini al
                api_traffic_data = traffic_data();
                last_api_update = current_time;
                fprintf('API verileri güncellendi: Zaman = %d saniye\n', current_time);
            end
            
            % API verisini kullanarak varış oranlarını ölçeklendir
            if ~isempty(api_traffic_data)
                % Trafik yoğunluğu değerlerini kullanarak varış oranlarını ölçeklendirme
                arrival_rates.(north_rate_field) = arrival_rates.(north_rate_field) * api_traffic_data.north_density * 2;
                arrival_rates.(south_rate_field) = arrival_rates.(south_rate_field) * api_traffic_data.south_density * 2;
                arrival_rates.(east_rate_field) = arrival_rates.(east_rate_field) * api_traffic_data.east_density * 2;
                arrival_rates.(west_rate_field) = arrival_rates.(west_rate_field) * api_traffic_data.west_density * 2;
                fprintf('Varış oranları API verisine göre ayarlandı - K:%.3f G:%.3f D:%.3f B:%.3f\n', ...
                    arrival_rates.(north_rate_field), arrival_rates.(south_rate_field), ...
                    arrival_rates.(east_rate_field), arrival_rates.(west_rate_field));
            end
        end
    end
catch e
    warning('TRAFFICSIM:APIDataError', 'API verisi kullanılırken hata oluştu: %s\\nVarsayılan varış oranları kullanılıyor.', e.message);
end

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